# cURLs para importar no Postman – FakeRESTApi Books

Cole os comandos abaixo em Postman → Import → Raw text.

## 1) Criar Book (POST)

```
curl -X POST "https://fakerestapi.azurewebsites.net/api/v1/Books" \
  -H "Content-Type: application/json" \
  -d '{
    "id": 0,
    "title": "Test Automation Advanced",
    "description": "Book created via automated test",
    "pageCount": 450,
    "excerpt": "Test excerpt",
    "publishDate": "2025-11-04T12:00:00.000Z"
  }'
```

## 2) Recuperar Book (GET)
Substitua `<BOOK_ID>` pelo id retornado no POST.

```
curl -X GET "https://fakerestapi.azurewebsites.net/api/v1/Books/<BOOK_ID>"
```

## 3) Alterar título (PUT)
Substitua `<BOOK_ID>` e mantenha os demais dados.

```
curl -X PUT "https://fakerestapi.azurewebsites.net/api/v1/Books/<BOOK_ID>" \
  -H "Content-Type: application/json" \
  -d '{
    "id": <BOOK_ID>,
    "title": "Test Automation Advanced (updated)",
    "description": "Book created via automated test",
    "pageCount": 450,
    "excerpt": "Test excerpt",
    "publishDate": "2025-11-04T12:00:00.000Z"
  }'
```

## 4) Deletar ID inexistente (DELETE)
Exemplo usando um ID grande.

```
curl -X DELETE "https://fakerestapi.azurewebsites.net/api/v1/Books/999999"
```

## 5) Criar Book inválido (POST com pageCount -5)

```
curl -X POST "https://fakerestapi.azurewebsites.net/api/v1/Books" \
  -H "Content-Type: application/json" \
  -d '{
    "id": 0,
    "title": "Invalid Book",
    "description": "Invalid payload test",
    "pageCount": -5,
    "excerpt": "Invalid excerpt",
    "publishDate": "2025-11-04T12:00:00.000Z"
  }'
```

> Dica: se preferir variáveis do Postman, troque a URL por `{{baseUrl}}/api/v1/Books` e configure `baseUrl = https://fakerestapi.azurewebsites.net` no ambiente.