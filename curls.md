# cURLs para importar no Postman – FakeRESTApi Books

Este arquivo contém cURLs equivalentes aos requests da coleção `postman_collection.json`, mantendo a mesma funcionalidade dos scripts (pré/pós-request) por meio de valores e placeholders que podem ser usados em ambientes do Postman.

Como importar
- No Postman: Import → Raw text → cole o cURL → Import.
- Opcional: ajuste `{{baseUrl}}` em um ambiente para `https://fakerestapi.azurewebsites.net` (já definido em `postman_environment.json`).

Observações importantes
- A API FakeREST é de demonstração. Algumas operações podem não persistir recursos criados e retornarem `404` ao recuperar, ou aceitarem payloads inválidos (`200` no POST de inválido). Os cURLs abaixo seguem o comportamento coberto pela suíte.
- Os scripts da coleção geram dados dinâmicos (como `publishDate` atual). Nos cURLs, fornecemos valores concretos, que você pode adaptar se desejar.

## Grupo: Books Flow

### 1) Criar Book (POST `/api/v1/Books`)
Headers necessários: `Content-Type: application/json`
Body: JSON com dados válidos.

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

Notas (equivalência com scripts):
- Na coleção, o `publishDate` é gerado com `new Date().toISOString()`. Aqui usamos um exemplo ISO fixo.
- O teste aceita `200` ou `201` na criação.
- O `id` retornado é capturado em variável na coleção; ao importar cURL, você deve copiar manualmente o `id` para usar nos próximos requests.

### 2) Recuperar Book (GET `/api/v1/Books/{id}`)
Headers: nenhum adicional.
Path: substitua `<BOOK_ID>` pelo id retornado no POST.

```
curl --request GET "{{baseUrl}}/api/v1/Books/<BOOK_ID>"
```

Notas (equivalência com scripts):
- A coleção trata `200` (recurso encontrado) ou `404` (não persistido). Os cURLs são diretos; o Postman não incluirá os testes automaticamente.

### 3) Alterar título (PUT `/api/v1/Books/{id}`)
Headers necessários: `Content-Type: application/json`
Body: JSON mantendo dados originais e alterando apenas o `title`.

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

Notas (equivalência com scripts):
- A coleção aceita `200` ou `204` como sucesso e valida que o título contém `updated`.

### 4) Deletar ID inexistente (DELETE `/api/v1/Books/{id}`)
Headers: nenhum adicional.
Path: usar um ID inexistente (exemplo: `999999`).

```
curl --request DELETE "{{baseUrl}}/api/v1/Books/999999"
```

Notas (equivalência com scripts):
- A coleção considera resposta `200`, `400`, `404` ou `405` por ser uma API demo.

### 5) Criar Book inválido (POST `/api/v1/Books` com `pageCount: -5`)
Headers necessários: `Content-Type: application/json`
Body: JSON com `pageCount` negativo para testar validação.

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

Notas (equivalência com scripts):
- A coleção valida se há rejeição server-side (`400/422`), mas aceita `200` em APIs que não validam.

## Autenticação
- Não há autenticação especial exigida para os endpoints usados.

## Query string
- Não há parâmetros de query utilizados nesta suíte.

## Dica para encadeamento no Postman
- Após importar os cURLs, execute o `POST` de criação, copie o `id` retornado e substitua `<BOOK_ID>` nos requests de `GET`, `PUT` e (se quiser) teste de `DELETE`.