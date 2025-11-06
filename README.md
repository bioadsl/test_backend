# Suíte de Testes Automatizados – FakeRESTApi (Books)

Esta suíte usa Postman + Newman para testar o serviço de `Books` da FakeRESTApi.

## Escopo dos testes

- Criar um novo Book via `POST /api/v1/Books` com:
  - `title`: "Test Automation Advanced"
  - `description`: "Book created via automated test"
  - `pageCount`: `450`
  - `publishDate`: data atual em ISO
- Recuperar o mesmo book via `GET /api/v1/Books/{id}` e validar dados.
- Alterar apenas o título via `PUT /api/v1/Books/{id}`.
- Deletar um ID inexistente e validar retorno de erro (aceita `400`, `404` ou `405`).
- Tentar criar um book inválido com `pageCount: -5` e validar rejeição (`400` ou `422`).

Observação: a API FakeREST pode não validar todos os cenários (por ser uma API de demonstração). Caso a API aceite payloads inválidos, o teste correspondente falhará, indicando ausência de validação server-side.

## Estrutura

- `postman_environment.json`: ambiente com `baseUrl` (`https://fakerestapi.azurewebsites.net`).
- `postman_collection.json`: coleção Postman com requests e scripts de pré-execução e validação.

## Rodando com Newman

Pré-requisitos: Node.js e npm instalados.

1. Inicialize o projeto e instale o Newman:
   - `npm init -y`
   - `npm install --save-dev newman`

2. (Opcional) Adicione um script npm para facilitar:
   - `npm set-script test:newman "newman run postman_collection.json -e postman_environment.json"`

3. Execute a suíte:
- `npm run test:newman`
- ou: `npx newman run postman_collection.json -e postman_environment.json`

## Executar via cURL

Você pode executar os mesmos requests manualmente com cURL (e importá-los no Postman em Import → Raw text). Abaixo estão os comandos equivalentes aos da coleção, mantendo headers e payloads.

1) Criar Book (POST `/api/v1/Books`)

```
curl --request POST "{{baseUrl}}/api/v1/Books" \
  --header "Content-Type: application/json" \
  --data '{
    "id": 0,
    "title": "Test Automation Advanced",
    "description": "Book created via automated test",
    "pageCount": 450,
    "excerpt": "Test excerpt",
    "publishDate": "2025-11-05T12:00:00.000Z"
  }'
```

2) Recuperar Book (GET `/api/v1/Books/{id}`)

```
curl --request GET "{{baseUrl}}/api/v1/Books/<BOOK_ID>"
```

3) Alterar título (PUT `/api/v1/Books/{id}`)

```
curl --request PUT "{{baseUrl}}/api/v1/Books/<BOOK_ID>" \
  --header "Content-Type: application/json" \
  --data '{
    "id": <BOOK_ID>,
    "title": "Test Automation Advanced (updated)",
    "description": "Book created via automated test",
    "pageCount": 450,
    "excerpt": "Test excerpt",
    "publishDate": "2025-11-05T12:00:00.000Z"
  }'
```

4) Deletar ID inexistente (DELETE `/api/v1/Books/{id}`)

```
curl --request DELETE "{{baseUrl}}/api/v1/Books/999999"
```

5) Criar Book inválido (POST `/api/v1/Books` com `pageCount: -5`)

```
curl --request POST "{{baseUrl}}/api/v1/Books" \
  --header "Content-Type: application/json" \
  --data '{
    "id": 0,
    "title": "Invalid Book",
    "description": "Invalid payload test",
    "pageCount": -5,
    "excerpt": "Invalid excerpt",
    "publishDate": "2025-11-05T12:00:00.000Z"
  }'
```

Notas
- Após executar o `POST` de criação, copie o `id` retornado e substitua `<BOOK_ID>` nos requests de `GET` e `PUT`.
- A FakeRESTApi pode retornar `404` ao recuperar o livro recém-criado e aceitar payloads inválidos com `200` (comportamento de demo). Os testes e cURLs foram escritos para cobrir esses cenários.

## Variáveis de ambiente
- Configure no Postman: `baseUrl = https://fakerestapi.azurewebsites.net`.
- Ao importar os cURLs com `{{baseUrl}}`, selecione o ambiente para resolver a variável.

## Executar via .BAT
- Para usar o script: `./run_newman.bat`
- Com parâmetros (coleção, ambiente, reporters):
  - `./run_newman.bat postman_collection.json postman_environment.json cli`
  - `./run_newman.bat postman_collection.json postman_environment.json cli,htmlextra`

## Relatórios HTML (opcional)
- Instale o reporter: `npm install --save-dev newman-reporter-htmlextra`
- Gere relatório com `npx`:
  - `npx newman run postman_collection.json -e postman_environment.json -r cli,htmlextra -reporter-htmlextra-export reports/newman.html`
- Dica: crie a pasta `reports` se necessário.

## CI com GitHub Actions
- Workflow: `.github/workflows/newman.yml`
- Dispara em `push` na `main` e manualmente (`workflow_dispatch`).
- Passos:
  - Faz checkout e configura Node 18.
  - Instala dependências do projeto.
  - Instala `newman` e `newman-reporter-htmlextra` sem salvar em `package.json`.
  - Executa a coleção com ambiente e gera `reports/newman.html`.
  - Publica o relatório como artefato `newman-report`.

Como ver o relatório
- Acesse a aba `Actions` do repositório GitHub e entre na execução.
- Baixe o artefato `newman-report` para visualizar o HTML.

## Relatório online (GitHub Pages)
- Após cada execução do workflow, o relatório HTML é publicado em GitHub Pages.
- Link esperado: `https://bioadsl.github.io/test_backend/newman.html`
- Dica: acessar `https://bioadsl.github.io/test_backend/` também redireciona para `newman.html`.
- Observações:
  - A publicação pode levar alguns minutos após o push.
  - Caso o link retorne 404 inicialmente, aguarde e recarregue.

## Disparar GitHub Actions por script (.bat)
- Script: `trigger_actions.bat` na raiz do projeto.
- Requisitos: `git` e `curl` instalados.

Como usar
- Com token (recomendado):
  - Crie um Personal Access Token com escopo `repo`.
  - Execute: `trigger_actions.bat <SEU_TOKEN>`
  - Ou defina a variável `GITHUB_TOKEN` e rode sem argumentos.
  - Alternativa segura: crie um arquivo `.env.github` (não versionado) com `GITHUB_TOKEN=seu_token`.
- Sem token (fallback):
  - O script faz um `commit` vazio e `push` para `main`, disparando o workflow.

O que o script faz
- Tenta acionar o workflow `newman.yml` via API (`workflow_dispatch`).
- Se não houver token, aciona por `push` com `git commit --allow-empty`.

Observações de segurança
- Nunca versione seu token. O arquivo `.env.github` está listado no `.gitignore`.
- Revogue tokens vazados imediatamente em `Settings → Developer settings → Personal access tokens`.

## Notas técnicas

- Geração automática de dados: `uuid` e `publishDate` (ISO) são gerados via scripts no Postman.
- Encadeamento: o `id` criado no `POST` é salvo e usado nos passos seguintes.
- Fixture reutilizável: variáveis de coleção e ambiente são usadas como base e reaproveitadas entre requests.

## Referência

- Swagger UI: https://fakerestapi.azurewebsites.net/index.html