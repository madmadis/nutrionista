# Backend — Claude juhised

## Käsud

```sh
./gradlew bootRun       # Käivita server (port 8080)
./gradlew build         # Ehita projekt
./gradlew test          # Käivita testid
```

## Tehnoloogia

Spring Boot 4, Java 21, Spring Data JPA, Lombok, MapStruct, PostgreSQL, jBCrypt 0.4, Springdoc OpenAPI.

## Pakettide struktuur

```
ee/nutrionista/
├── controller/ressursipakett/dto/      # DTO-d (päringu ja vastuse objektid)
├── controller/ressursipakett/          # REST kontroller
├── infrastructure/error/               # ApiError, ErrorResponse (enum veakoodidega)
├── infrastructure/exception/           # Kohandatud erindiklassid
├── infrastructure/                     # RestExceptionHandler
├── persistence/ressursipakett/         # Entity, EntityMapper, EntityRepository
└── service/                            # Äriloogika teenused
```

## Entity konventsioonid

```java
@Getter
@Setter
@Entity
@Table(name = "tabelinimi", schema = "nutrionista")
public class Entity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id", nullable = false)
    private Integer id;  // või Long kui tabelis palju ridu

    @Size(max = 100)
    @NotNull
    @Column(name = "veeru_nimi", nullable = false)
    private String veeruNimi;
}
```

NB! `user` on PostgreSQL reserveeritud sõna — kasuta `@Table(name = "\"user\"")`.

## Repository konventsioonid

```java
public interface EntityRepository extends JpaRepository<Entity, Integer> {
    // Spring Data JPA genereerib tavalised päringud automaatselt
    // Kohandatud päringud: findByVeerg(...) või @Query(...)
    Optional<Entity> findByUsername(String username);
}
```

## Service konventsioonid

```java
@Service
@RequiredArgsConstructor
public class EntityService {

    private final EntityRepository entityRepository;
    private final EntityMapper entityMapper;

    public ResponseDto doSomething(RequestDto request) {
        // 1. Otsi andmebaasist
        // 2. Kontrolli äriloogikat, viska erind kui midagi valesti
        // 3. Teisenda Entity → DTO ja tagasta
    }
}
```

## Controller konventsioonid

```java
@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class EntityController {

    private final EntityService entityService;

    @PostMapping("/ressurss")
    @Operation(summary = "Lühikirjeldus")
    public ResponseDto doSomething(@Valid @RequestBody RequestDto body) {
        return entityService.doSomething(body);
    }
}
```

## Veahaldus

Kõik vead tagastatakse `ApiError` formaadis:
```json
{"message": "Veateade", "errorCode": 401}
```

Veakoodid on defineeritud `ErrorResponse` enum-is (`infrastructure/error/ErrorResponse.java`).

`RestExceptionHandler` (`@ControllerAdvice`) püüab erindid kinni ja teisendab need `ApiError` vastusteks.

## Paroolid

BCrypt räsimine `jbcrypt` teegiga:
```java
BCrypt.checkpw(sisestatud_parool, hash_andmebaasist)  // kontrollimine
BCrypt.hashpw(parool, BCrypt.gensalt(10))              // räsimine
```

## Keel

Kogu dokumentatsioon peab olema **eestikeelne**.