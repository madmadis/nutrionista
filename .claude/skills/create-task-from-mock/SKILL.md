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

1. Vaate nimi (nt: faili nimi: LoginView.vue)
2. API endpoint (nt: POST /api/login)
3. Kontrolleri nimi (nt: LoginController.java)
```

Oota vastust enne kui jätkad.

### 2. Parsi sisendid

Parsi kasutaja vastusest:
- **viewName** — vaate nimi ilma laiendita (nt `LoginView`)
- **httpMethod** — HTTP meetod suurtähtedega (nt `POST`)
- **apiPath** — API tee (nt `/api/login`)
- **controllerName** — kontrolleri failinimi (nt `LoginController.java`)

Moodusta **taski failinimi** endpointi põhjal: asenda `/` sidekriipsuga ja eemalda esialgne kriips.
- Näide: `POST /api/login` → `POST-api-login.md`
- Näide: `GET /api/user/{userId}/portfolio` → `GET-api-user-userId-portfolio.md`

### 3. Loe PDF-ist vaate info

Loe PDF fail otse `Read` tööriistaga:
- Fail: `docs/mock/IJ mock.pdf`

PDF-is on 10 lehekülge. Leia õige lehekülg vaate nime järgi — igal lehel on päises faili nimi (nt `LoginView.vue`).

Lehekülgede järjekord:
1. HomeView
2. LoginView
3. LogoutModal
4. RegisterView
5. DashboardView
6. TradeLog
7. WatchlistView
8. PortfolioView
9. DetailsView
10. MALL (mall/template)

Kogu vastavalt lehekülje sisule:

**API teenuse post-it note** (otsid märgistust "API teenus" + kontrolleri nimi + sinu endpoint):
- HTTP meetod ja tee
- RequestBody: DTO nimi ja väljad
- ResponseBody: DTO nimi ja väljad
- Veaolukorrad: Enum nimi, HTTP staatus, message

**Muud API teenused samal lehel** — vaata kõiki teisi "API teenus" märgistusega post-it note'e, et mõista lehe konteksti (mis andmeid kuvatakse, mis on seotud).

**Frontend info** — vaata vaate üldist kirjeldust (route URL, navigation, components, behaviour notes), et mõista kasutaja voogu.

Kui PDF lugemine annab ebaselge tulemuse mõne välja osas, küsi kasutajalt täpsustust enne jätkamist.

### 4. Loe andmebaasi skeem

Loe fail: `database/2_create.sql`

Tuvasta, millised tabelid on seotud selle endpointiga (põhinedes DTO väljade nimedel ja domeeni kontekstil).

### 5. Kontrolli olemasolevaid DTO skeeme

Vaata kaustas `docs/dtos/schema/` olemasolevaid faile.

Iga DTO kohta, mida endpoint kasutab (RequestBody ja ResponseBody):
- Kui **schema fail puudub** → loo see (vt samm 6)
- Kui **schema fail olemas** → kasuta seda, aga kontrolli, kas väljad klapivad PDF infoga

### 6. Loo puuduvad DTO schema ja example failid

#### Schema fail (`docs/dtos/schema/`)

Failinimi: `NimiDto_schema.json` (nt `LoginDto_schema.json`)

Formaat — lihtsad tüübid, null andmeid:
```json
{
  "email": "string",
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

Failinimi: `NimiDto_VaateNimi_example.json` (nt `LoginDto_LoginView_example.json`)
Kui vastus on massiiv: `NimiDto_VaateNimi_Array_example.json`

Formaat — realistlikud näidisandmed:
```json
{
  "email": "john.smith@email.com",
  "password": "password123"
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

## Kontekst

<2–4 lauset: mis lehekülg, mis probleemi see endpoint lahendab, kuidas see sobib kasutaja voogu. Viita teistele sama lehe endpointidele kui seosed on olulised.>

## Mocki vaade

![<VaateNimi> mock](../../mock/pictures/<VaateNimi>.png)

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
| <Mock-is mainitud viga> | `<ExceptionKlass>` | `<ENUM_NIMI>` | <404 / 403 / 409 / 500> |
| <Ise lisatud viga> | `<ExceptionKlass>` | `<ENUM_NIMI>` | <staatus> |

> **Märkus veahalduse kohta:**
> Kontrolli, kas vajalikud `ErrorResponse` enum kirjed ja exception klassid juba eksisteerivad:
> - `backend/src/main/java/ee/valiit/ijournal/infrastructure/error/ErrorResponse.java`
> - `backend/src/main/java/ee/valiit/ijournal/infrastructure/exception/`
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
- [ ] Kontrolleri meetodil on `@Operation` ja `@ApiResponses` annotatsioonid (sh veavastused `ApiError` skeemiga)
- [ ] Swagger UI kaudu on endpoint nähtav ja testitav
```

---

### 8. Teavita kasutajat

Näita lühidalt:
- Loodud taski faili tee
- Loodud/uuendatud DTO failid (schema + examples)
- Kui mõni asi jäi ebaselgeks ja eeldus tehti, maini seda selgelt

Kui mistahes sammul esineb ebaselgust (DTO väljad, seotud tabelid, vea HTTP kood, auth nõue), **küsi kasutajalt enne faili loomist täpsustust**.
