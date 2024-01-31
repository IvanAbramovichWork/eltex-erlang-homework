### Запуск
```shell
cd webRtpProject
docker build -t webrtp .
docker run -d -p 8080:8080 --init webrtp:latest
```
### Описание API
- GET http://localhost:8080/abonent/{abonent_number} - возвращает абонента с данным номером
```shell
curl http://localhost:8080/abonent/102 -H "Accept: application/json" 
```

- POST http://localhost:8080/abonent - добавляет абонентов.
#### Пример тела запроса:
```json
[
    {
        "num": 107,
        "name": "Ivan"
    },
    {
        "num": 108,
        "name": "Petr"
    }
]
```
```shell
curl -X POST http://localhost:8080/abonent -H "Content-Type: application/json" -d '[{"num": 107, "name": "Ivan"}, {"num": 108, "name": "Petr"}]'
```
- DELETE http://localhost:8080/abonent/{abonent_number} - удаляет абонента, возвращает удаленного абонента
```shell
curl -X DELETE http://localhost:8080/abonent/107 -H "Accept: application/json"
```

- GET http://localhost:8080/abonents - возвращает всех абонентов
```shell
curl http://localhost:8080/abonents -H "Accept: application/json"
```

- GET http://localhost:8080/call/abonent/{abonent_number} - совершается звонок абоненту с данным номером
```shell
curl http://localhost:8080/call/abonent/102 -H "Accept: application/json"
```

- GET http://localhost:8080/call/broadcast - совершается звонок всем абонентам из базы данных
```shell
curl http://localhost:8080/call/broadcast -H "Accept: application/json"
```


https://github.com/IvanAbramovichWork/eltex-erlang-homework/assets/110540101/fce59e22-8083-47e3-8190-a463460c0a61

