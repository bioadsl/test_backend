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

## Notas técnicas

- Geração automática de dados: `uuid` e `publishDate` (ISO) são gerados via scripts no Postman.
- Encadeamento: o `id` criado no `POST` é salvo e usado nos passos seguintes.
- Fixture reutilizável: variáveis de coleção e ambiente são usadas como base e reaproveitadas entre requests.

## Referência

- Swagger UI: https://fakerestapi.azurewebsites.net/index.html