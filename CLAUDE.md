# Nutrionista — Claude juhised

## Projekti ülevaade

Nutrionista on vitamiinide ja toidulisandite e-pood. Backend: Spring Boot (Java), Frontend: Vue 3, Andmebaas: PostgreSQL.

## Kaustade struktuur

```
nutrionista/
├── backend/                            # Spring Boot REST API
├── frontend/                           # Vue 3 rakendus
└── docs/
    ├── database/                       # SQL skriptid (1_reset, 2_create, 3_import)
    └── tasks/                          # Leheülesannete kirjeldused (task_page_N.md)
```

## Backendi struktuur

```
backend/src/main/java/ee/nutrionista/
├── controller/                         # REST kontrollerid
│   └── ressursipakett/                 # nt auth/, nutrient/
│       ├── dto/                        # Päringu ja vastuse DTO-d
│       └── SomeController.java
├── infrastructure/                     # Globaalne veahaldus
│   ├── error/                          # ApiError.java, ErrorResponse.java
│   ├── exception/                      # Kohandatud erindiklassid
│   └── RestExceptionHandler.java
├── persistence/                        # Andmebaasi entiteedid ja repositooriumid
│   └── ressursipakett/                 # nt role/, user/
│       ├── Entity.java
│       ├── EntityMapper.java
│       └── EntityRepository.java
└── service/                            # Äriloogika
```

## Andmebaas

- Andmebaas: `nutrionista`
- Skeem: `nutrionista`
- Kasutajanimi: `postgres`
- Parool: `student123`

SQL skriptid käivitada järjest:
1. `1_reset_database.sql` — kustutab ja loob skeemi uuesti
2. `2_create.sql` — loob tabelid
3. `3_import.sql` — lisab algsed andmed

## Tehnoloogiad

| Osa | Tehnoloogia |
|-----|-------------|
| Backend | Spring Boot 4, Java 21, JPA, Bean Validation, Lombok, MapStruct, Springdoc OpenAPI, p6spy |
| Ehitustööriist | Gradle (wrapper: `./gradlew bootRun`, `./gradlew build`) |
| Frontend | Vue 3 (Options API), Pinia, Vue Router, Tailwind, Axios |
| Andmebaas | PostgreSQL |
| Paroolid | BCrypt (jbcrypt 0.4) |

## Keel

Kogu dokumentatsioon (`CLAUDE.md`, `docs/`) peab olema **eestikeelne**, välja arvatud disainispec (`docs/2026-05-06-nutrionista-design_REV4.1.md`), mis on ingliskeelne.