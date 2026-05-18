---
name: skill-loo-backend-task
description: Koosta uus backend taski fail docs/tasks/backend kausta, kasutades mock PDF-i ja andmebaasi skeemi.
---

# Koosta uus backend task

Koosta põhjalik backend taski fail eesti keeles, tuginedes projekti mock-disainile ja andmebaasi skeemile.

## Sammud

### 1. Kogu kolm sisendit

Küsi kasutajalt kolm sisendit **ühes sõnumis**:

```
Palun anna mulle kolm sisendit:

1. filename: LoginView.vue
2. API endpoint (nt: POST /api/login)
3. Kontrolleri nimi (nt: AuthController.java)
```

Oota vastust enne kui jätkad.

### 2. Parsi sisendid

Parsi kasutaja vastusest:
- **viewName** — vaate nimi ilma laiendita (nt `LoginView`)
- **httpMethod** — HTTP meetod suurtähtedega (nt `POST`)
- **apiPath** — API tee (nt `/api/login`)
- **controllerName** — kontrolleri failinimi (nt `AuthController.java`)

Moodusta **taski failinimi** endpointi põhjal: asenda `/` sidekriipsuga ja eemalda esialgne kriips.
- Näide: `POST /api/login` → `POST-api-login.md`
- Näide: `GET /api/nutrient/{id}` → `GET-api-nutrient-id.md`

### 3. Loe PDF-ist vaate info

Loe PDF fail otse `Read` tööriistaga:
- Fail: `docs/mock/nutrionista_balsamiq.pdf`

Leia õige lehekülg vaate nime järgi — igal lehel on päises faili nimi (nt `LoginView.vue`). Vaadete loend ja lehekülgede järjekord leiad `docs/tasks/` kaustast (task_page_N.md failid).

Kogu vastavalt lehekülje sisule:

**Post-it note formaat PDF-is näeb välja nii:**
```
LOGIN PAGE
filename: LoginView.vue
url: /login
API: POST /api/login
{DTO: LoginDto.java
  "email": "tarmo.tamm@mail.ee",
  "password": "*********"
}
{Response: LoginResponseDto.java
  "userId": 1,
  "firstName": "Tarmo",
  "middleName": null,
  "lastName": "Tamm",
  "role": "ADMIN"
}
Veateated:
200 OK — sisselogimine õnnestus
401 Unauthorized — vale email või parool
  → kasutajale: "Vale email või parool"
400 Bad Request — email või parool puudub
  → kasutajale: "Palun täitke kõik väljad"
```

Kogu sellest:
- `API:` — HTTP meetod ja tee
- `DTO:` — request body DTO nimi ja väljad
- `Response:` — response body DTO nimi ja väljad
- `Veateated:` — HTTP staatused ja kasutajale kuvatavad teated

**Muud API teenused samal lehel** — vaata kõiki teisi "API teenus" märgistusega post-it note'e, et mõista lehe konteksti (mis andmeid kuvatakse, mis on seotud).

**Frontend info** — vaata vaate üldist kirjeldust (route URL, navigation, components, behaviour notes), et mõista kasutaja voogu.

Kui PDF lugemine annab ebaselge tulemuse mõne välja osas, küsi kasutajalt täpsustust enne jätkamist.

**Mockup PNG** — kontrolli, et fail `docs/mock/pictures/<VaateNimi>.png` eksisteerib. See lisatakse taski faili päisesse visuaalse kontekstina (vt samm 7).

### 4. Loe andmebaasi skeem

Loe fail: `docs/database/2_create.sql`

Tuvasta, millised tabelid on seotud selle endpointiga (põhinedes DTO väljade nimedel ja domeeni kontekstil).

### 5. Kontrolli olemasolevaid DTO skeeme

Vaata kaustas `docs/dtos/schema/` olemasolevaid faile.

Iga DTO kohta, mida endpoint kasutab (RequestBody ja ResponseBody):
- Kui **schema fail puudub** → loo see (vt samm 6)
- Kui **schema fail olemas** → kasuta seda, aga kontrolli, kas väljad klapivad PDF infoga

### 6. Loo puuduvad DTO schema ja example failid

#### Schema fail (`docs/dtos/schema/`)

Failinimi: `NimiDto_schema.json` (nt `LoginRequestDto_schema.json`)

Formaat — lihtsad tüübid, null andmeid:
```json
{
  "username": "string",
  "password": "string"
}
```

Tüübid:
- Tekst → `"string"`
- Täisarv → `0`
- Kümnendarv → `0.0`
- Tõeväärtus → `false`
- Kuupäev → `"2000-01-01"`
- Massiiv → `[]` või `[{ ... }]`

#### Example fail (`docs/dtos/examples/`)

Failinimi: `NimiDto_VaateNimi_example.json` (nt `LoginRequestDto_LoginView_example.json`)
Kui vastus on massiiv: `NimiDto_VaateNimi_Array_example.json`

Formaat — realistlikud näidisandmed:
```json
{
  "username": "rain",
  "password": "demo"
}
```

### 7. Koosta taski fail

Loo fail: `docs/tasks/backend/<taski-failinimi>.md`

Kasuta järgmist struktuuri:

---

```markdown
# <HTTP meetod> <API tee>

**Kontroller:** `<KontrolleriNimi>.java`
**Tüüp:** Backend
**Staatus:** To Do

## Mockup

![<VaateNimi>](../../mock/pictures/<VaateNimi>.png)

## Kontekst

<2–4 lauset: mis lehekülg, mis probleemi see endpoint lahendab, kuidas see sobib kasutaja voogu. Viita teistele sama lehe endpointidele kui seosed on olulised.>

## API leping

| Väli | Väärtus |
|------|---------|
| Meetod | `<HTTP_MEETOD>` |
| Tee | `<API_TEE>` |
| Auth | <Kas token nõutav? Jah / Ei> |

### Request Body — `<RequestDtoNimi>.java`

> Schema: [`<RequestDtoNimi>_schema.json`](../../dtos/schema/<RequestDtoNimi>_schema.json)
> Näidis: [`<RequestDtoNimi>_<VaateNimi>_example.json`](../../dtos/examples/<RequestDtoNimi>_<VaateNimi>_example.json)

| Väli | Tüüp | Kirjeldus |
|------|------|-----------|
| `väljanimi` | `String` | Lühike selgitus |

*(Kui endpoint ei kasuta Request Body-t, kirjuta: "Puudub — GET päring")*

### Response Body — `<ResponseDtoNimi>.java`

> Schema: [`<ResponseDtoNimi>_schema.json`](../../dtos/schema/<ResponseDtoNimi>_schema.json)
> Näidis: [`<ResponseDtoNimi>_<VaateNimi>_example.json`](../../dtos/examples/<ResponseDtoNimi>_<VaateNimi>_example.json)

| Väli | Tüüp | Allikas (DB tabel.veerg) |
|------|------|--------------------------|
| `väljanimi` | `Long` | `tabel.veerg` |

*(Kui endpoint ei tagasta keha, kirjuta: "Puudub — HTTP 200/204 tühi vastus")*

## Veahaldus

| Olukord | Exception klass | ErrorResponse enum | HTTP staatus |
|---------|----------------|-------------------|--------------|
| <Mock-is mainitud viga> | `<ExceptionKlass>` | `<ENUM_NIMI>` | <404 / 401 / 409 / 500> |
| <Ise lisatud viga> | `<ExceptionKlass>` | `<ENUM_NIMI>` | <staatus> |

> **Märkus veahalduse kohta:**
> Kontrolli, kas vajalikud `ErrorResponse` enum kirjed ja exception klassid juba eksisteerivad:
> - `backend/src/main/java/ee/nutrionista/infrastructure/error/ErrorResponse.java`
> - `backend/src/main/java/ee/nutrionista/infrastructure/exception/`
>
> Puuduvate enum kirjete puhul lisa need `ErrorResponse`-i. Puuduvate exception klasside puhul loo uus klass `exception/` paketti (järgi olemasolevate klasside mustrit) ja registreeri see `RestExceptionHandler`-is.

## Andmebaas

Seotud tabelid: `<tabel1>`, `<tabel2>`

<Lühike selgitus: milliseid välju loetakse/kirjutatakse ja millistest tabelitest. Lisa tähelepanekud unikaalsuspiirangute, foreign key-de või muu olulise DB loogika kohta.>

## Vastuvõtu kriteeriumid

- [ ] `<HTTP_MEETOD> <API_TEE>` tagastab <oodatav HTTP kood> ja õige response body
- [ ] <Veaolukord mock-ist>: tagastab <HTTP staatus> koos `<ENUM_NIMI>` veaga
- [ ] <Ise lisatud veaolukord>: tagastab <HTTP staatus> koos `<ENUM_NIMI>` veaga
- [ ] Kõik DTO klassid on loodud Java klassidena õigesse paketti
- [ ] Controller, Service, Repository kihid on eraldatud
- [ ] Kontrolleri meetodil on `@Operation` annotatsioon
- [ ] Swagger UI kaudu on endpoint nähtav ja testitav
```

---

### 8. Teavita kasutajat

Näita lühidalt:
- Loodud taski faili tee
- Loodud/uuendatud DTO failid (schema + examples)
- Kui mõni asi jäi ebaselgeks ja eeldus tehti, maini seda selgelt

Kui mistahes sammul esineb ebaselgust (DTO väljad, seotud tabelid, vea HTTP kood, auth nõue), **küsi kasutajalt enne faili loomist täpsustust**.
