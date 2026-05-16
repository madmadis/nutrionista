## Page 1
**Label:** LANDING PAGE/HOME
**filename:** HomeView.vue
**url:** /home
**API:** _(empty)_
**DTO:** _(empty)_
**Response:** _(empty)_
**Veateated:** _(empty)_

**Title (left sidebar):** Avaleht
**Description:** Kuvatakse Nutrionista logo, navigeerimismenüü ja esiletõstetud vitamiinid või toitumisalane teave.

**Mockup content:**
- Nutrionista
- Avaleht
- Tooted
- Minu konto
- Ostukorv
- Avasta parimad vitamiinid ja toidulisandid oma tervise toetamiseks.
- Tere tulemast Nutrionistasse!
- Esiletõstetud Tooted
- Vitamiin A
- Vitamiin C
- Vitamiin D
- B-kompleks
- Oluline nägemisele 
- ja immuunsüsteemile.
- Tugevdab 
- immuunsüsteemi.
- Hea luudele ja meeleolule.
- Energiaks ja 
- närvisüsteemile
- .
- 18.75 €
- 15.00 €
- 12.99 €
- 9.50 €
- Vaata lähemalt
- Vaata lähemalt
- Vaata lähemalt
- Vaata lähemalt
- © 2023 Nutrionista

**Image placeholders:**
- (214.4, 358.5) 324.0×6.7 — near "Avasta parimad vitamiinid ja toidulisandid oma tervise toetamiseks."
- (215.0, 407.1) 54.7×58.1 — near "Vitamiin A"
- (297.6, 407.1) 54.7×58.1 — near "Vitamiin C"
- (380.3, 407.1) 54.7×58.1 — near "Vitamiin D"
- (463.0, 407.1) 54.7×58.1 — near "B-kompleks"

_HTML page id: `main`_

**Structure (HTML):**
- <header>
  - <nav>
    - <a> "Avaleht" → main.vue
    - <a> "Tooted" → shop.vue
    - <a> "Minu konto" → login.vue
    - <a> "Ostukorv" → cart.vue
- <main>
  - <section>
    - h1: "Tere tulemast Nutrionistasse!"
    - p: "Avasta parimad vitamiinid ja toidulisandid oma tervise toetamiseks."
    - <button> "Tee vitamiinitest" → quiz.vue
  - <section>
    - h2: "Esiletõstetud Tooted"
    - [img] Vitamiin A
    - h3: "Vitamiin A"
    - p: "Oluline nägemisele ja immuunsüsteemile."
    - <button> "Vaata lähemalt"
    - [img] Vitamiin C
    - h3: "Vitamiin C"
    - p: "Tugevdab immuunsüsteemi."
    - <button> "Vaata lähemalt"
    - [img] Vitamiin D
    - h3: "Vitamiin D"
    - p: "Hea luudele ja meeleolule."
    - <button> "Vaata lähemalt"
    - [img] B-kompleks
    - h3: "B-kompleks"
    - p: "Energiaks ja närvisüsteemile."
    - <button> "Vaata lähemalt"
- <footer>
  - <a> "Blogi" → blog.vue
  - <a> "KKK" → faq.vue
  - <a> "Kontakt" → contact.vue

**Navigation (out):**
- nav: "Avaleht" → main.vue
- nav: "Tooted" → shop.vue
- nav: "Minu konto" → login.vue
- nav: "Ostukorv" → cart.vue
- button: "Tee vitamiinitest" → quiz.vue
- card: "Vitamiin A" → product_detail.vue
- card: "Vitamiin C" → product_detail.vue
- card: "Vitamiin D" → product_detail.vue
- card: "B-kompleks" → product_detail.vue
- link: "Blogi" → blog.vue
- link: "KKK" → faq.vue
- link: "Kontakt" → contact.vue

## Page 2
**Label:** LOGIN PAGE
**filename:** LoginView.vue
**url:** /login
**API:** POST /api/login
**DTO:**
```
LoginDto.java
{
"email":"tarmo.tamm@mail.ee",
"password":"*********"
}
```
**Response:**
```
LoginResponseDto.java
{
"userId": 1,
"firstName": "Tarmo",
"middleName": null,
"lastName": "Tamm",
"role": "ADMIN"
}
```
**Veateated:**
```
200 OK — sisselogimine õnnestus
401 Unauthorized — vale email või parool
→ kasutajale: "Vale email või parool"
400 Bad Request — email või parool puudub
→ kasutajale: "Palun täitke kõik väljad"
```

**Title (left sidebar):** Sisselogimine/R egistreerimine
**Description:** Võimaldab kasutajatel sisse logida olemasoleva kontoga või luua uue konto.

**Mockup content:**
- Nutrionista
- Avaleht
- Sisselogimine / Registreerimine
- E-posti aadress
- Parool
- Logi sisse
- või
- Loo uus konto
- © 2023 Nutrionista

_HTML page id: `login`_

**Structure (HTML):**
- <header>
  - <a> "Avaleht" → main.vue
- <main>
  - h1: "Sisselogimine / Registreerimine"
  - <form>
    - input: E-posti aadress (text)
    - input: Parool (password)
    - <button> "Logi sisse" → profile.vue
  - <button> "Loo uus konto" → profile.vue
- <footer>

**Navigation (out):**
- logo: "Nutrionista" → main.vue
- link: "Avaleht" → main.vue
- button: "Logi sisse" → profile.vue
- button: "Loo uus konto" → profile.vue

**Form fields:**
- E-posti aadress (text)
- Parool (password)

## Page 3
**Label:** QUIZ PAGE
**filename:** QuizView.vue
**url:** /quiz
**API:** _(empty)_
**DTO:** _(empty)_
**Response:** _(empty)_
**Veateated:** _(empty)_

**Title (left sidebar):** Vitamiinitest
**Description:** Interaktiivne küsimustik kasutaja elustiili, toitumise ja tervise kohta, et pakkuda personaalseid vitamiinisoovitusi .

**Mockup content:**
- Nutrionista
- Avaleht
- Tooted
- Minu konto
- Ostukorv
- Vitamiinitest
- Vasta küsimustele oma elustiili, toitumise ja tervise kohta, et saada personaalseid vitamiinisoovitusi.
- 1. Kui tihti tarbid piimatooteid?
- Iga päe
- Mitu korda nädalas
- Harva
- Ei tarbi üldse
- 2. Kas oled taimetoitlane või vegan?
- Jah, vegan
- Jah, taimetoitlane
- Ei
- 3. Kui tihti viibid päikese käes (ilma päikesekaitsekreemita)?
- Iga päe
- Mitu korda nädalas
- Harva
- Peaaegu mitte kunag
- 4. Kas tunned tihti väsimust või energiapuudust?
- Jah, väga tihti
- Mõnikord
- Harva
- Ei
- 5. Kas sul on mingeid kroonilisi haigusi või võtad regulaarselt ravimeid?
- Kirjelda lühidalt (valikuline)
- Esita vastused
- © 2023 Nutrionista

_HTML page id: `quiz`_

**Structure (HTML):**
- <header>
  - <nav>
    - <a> "Avaleht" → main.vue
    - <a> "Tooted" → shop.vue
    - <a> "Minu konto" → login.vue
    - <a> "Ostukorv" → cart.vue
- <main>
  - h1: "Vitamiinitest"
  - p: "Vasta küsimustele oma elustiili, toitumise ja tervise kohta, et saada personaalseid vitamiinisoovitusi."
  - h3: "1. Kui tihti tarbid piimatooteid?"
  - label: "Iga päev"
    - input: Iga päev (radio)
  - label: "Mitu korda nädalas"
    - input: Mitu korda nädalas (radio)
  - label: "Harva"
    - input: Harva (radio)
  - label: "Ei tarbi üldse"
    - input: Ei tarbi üldse (radio)
  - h3: "2. Kas oled taimetoitlane või vegan?"
  - label: "Jah, vegan"
    - input: Jah, vegan (radio)
  - label: "Jah, taimetoitlane"
    - input: Jah, taimetoitlane (radio)
  - label: "Ei"
    - input: Ei (radio)
  - h3: "3. Kui tihti viibid päikese käes (ilma päikesekaitsekreemita)?"
  - label: "Iga päev"
    - input: Iga päev (radio)
  - label: "Mitu korda nädalas"
    - input: Mitu korda nädalas (radio)
  - label: "Harva"
    - input: Harva (radio)
  - label: "Peaaegu mitte kunagi"
    - input: Peaaegu mitte kunagi (radio)
  - h3: "4. Kas tunned tihti väsimust või energiapuudust?"
  - label: "Jah, väga tihti"
    - input: Jah, väga tihti (radio)
  - label: "Mõnikord"
    - input: Mõnikord (radio)
  - label: "Harva"
    - input: Harva (radio)
  - label: "Ei"
    - input: Ei (radio)
  - h3: "5. Kas sul on mingeid kroonilisi haigusi või võtad regulaarselt ravimeid?"
  - input: Ei (textarea, placeholder="Kirjelda lühidalt (valikuline)")
  - <button> "Esita vastused" → profile.vue
- <footer>

**Navigation (out):**
- logo: "Nutrionista" → main.vue
- nav: "Avaleht" → main.vue
- nav: "Tooted" → shop.vue
- nav: "Minu konto" → login.vue
- nav: "Ostukorv" → cart.vue
- button: "Esita vastused" → profile.vue

**Form fields:**
- Iga päev (radio)
- Mitu korda nädalas (radio)
- Harva (radio)
- Ei tarbi üldse (radio)
- Jah, vegan (radio)
- Jah, taimetoitlane (radio)
- Ei (radio)
- Iga päev (radio)
- Mitu korda nädalas (radio)
- Harva (radio)
- Peaaegu mitte kunagi (radio)
- Jah, väga tihti (radio)
- Mõnikord (radio)
- Harva (radio)
- Ei (radio)
- Ei (textarea) — placeholder "Kirjelda lühidalt (valikuline)"

## Page 4
**Label:** (VITAMIN) PROFILE PAGE
**filename:** ProfileView.vue
**url:** /profile
**API:** _(empty)_
**DTO:** _(empty)_
**Response:** _(empty)_
**Veateated:** _(empty)_

**Title (left sidebar):** Personaalne vitamiiniprofiil
**Description:** Kuvatakse kasutaja riskid, soovitused, ostetud vitamiinid ja meeldetuletused . Ligipääs tellimuste ajaloole ja soovikorvile.

**Mockup content:**
- Nutrionista
- Avaleht
- Tooted
- Minu konto
- Ostukorv
- Personaalne vitamiiniprofiil
- Sinu riskid
- Soovitused
- Ostetud vitamiinid
- • D-vitamiini puudus (madal päikese käes 
- viibimine)
- • D-vitamiin 2000 IU päevas
- D-vitamiin 2000 IU
- Telli 
- uuesti
- • B12-vitamiin 1000 mcg nädalas
- Järgmine 
- meeldetuletus: 
- 15.11.2023
- • B12-vitamiini puudus (taimetoitlus)
- • Rauapreparaat koos C-vitamiiniga
- • Rauapuudus (rasked menstruatsioonid)
- • Magneesium õhtuti paremaks uneks
- Magneesiumtsitraat
- Telli 
- uuesti
- Järgmine 
- meeldetuletus: 
- 01.12.2023
- Tellimuste ajalugu
- Soovikorv
- Ostukorvi
- © 2023 Nutrionista

_HTML page id: `profile`_

**Structure (HTML):**
- <header>
  - <nav>
    - <a> "Avaleht" → main.vue
    - <a> "Tooted" → shop.vue
    - <a> "Minu konto" → profile.vue
    - <a> "Ostukorv" → cart.vue
- <main>
  - h1: "Personaalne vitamiiniprofiil"
  - h2: "Sinu riskid"
  - <ul> (3 items)
    - • D-vitamiini puudus (madal päikese käes viibimine)
    - • B12-vitamiini puudus (taimetoitlus)
    - • Rauapuudus (rasked menstruatsioonid)
  - <button> "Tellimuste ajalugu" → order_history.vue
  - h2: "Soovitused"
  - <ul> (4 items)
    - • D-vitamiin 2000 IU päevas
    - • B12-vitamiin 1000 mcg nädalas
    - • Rauapreparaat koos C-vitamiiniga
    - • Magneesium õhtuti paremaks uneks
  - <button> "Soovikorv" → wishlist.vue
  - h2: "Ostetud vitamiinid"
  - p: "D-vitamiin 2000 IU"
  - p: "Järgmine meeldetuletus: 15.11.2023"
  - <button> "Telli uuesti"
  - p: "Magneesiumtsitraat"
  - p: "Järgmine meeldetuletus: 01.12.2023"
  - <button> "Telli uuesti"
  - <button> "Ostukorvi" → cart.vue
- <footer>

**Navigation (out):**
- logo: "Nutrionista" → main.vue
- nav: "Avaleht" → main.vue
- nav: "Tooted" → shop.vue
- nav: "Minu konto" → profile.vue
- nav: "Ostukorv" → cart.vue
- button: "Tellimuste ajalugu" → order_history.vue
- button: "Soovikorv" → wishlist.vue
- button: "Ostukorvi" → cart.vue

## Page 5
**Label:** WISHLIST PAGE
**filename:** WishlistView.vue
**url:** /wishlist
**API:** _(empty)_
**DTO:** _(empty)_
**Response:** _(empty)_
**Veateated:** _(empty)_

**Title (left sidebar):** Soovikorv
**Description:** Kuvatakse kasutaja salvestatud tooted, mida ta soovib tulevikus osta.

**Mockup content:**
- Nutrionista
- Avaleht
- Tooted
- Minu konto
- Ostukorv
- Soovikorv
- Vitamiin Nimi 1
- Vitamiin Nimi 2
- Vitamiin Nimi 3
- Lühikirjeldus
- Lühikirjeldus
- Lühikirjeldus
- 15.99 €
- 22.50 €
- 10.00 €
- Vaata lähemalt
- Vaata lähemalt
- Vaata lähemalt
- Lisab ostukorvi
- Lisab ostukorvi
- Lisab ostukorvi
- © 2023 Nutrionista

**Image placeholders:**
- (108.9, 71.4) 63.7×9.1 — near "Vitamiin Nimi 1"
- (258.3, 71.4) 63.7×9.1 — near "Vitamiin Nimi 2"
- (408.1, 71.4) 63.7×9.1 — near "Vitamiin Nimi 3"

_HTML page id: `wishlist`_

**Structure (HTML):**
- <header>
  - <nav>
    - <a> "Avaleht" → main.vue
    - <a> "Tooted" → shop.vue
    - <a> "Minu konto" → profile.vue
    - <a> "Ostukorv" → cart.vue
- <main>
  - h1: "Soovikorv"
  - h3: "Vitamiin Nimi 1"
  - p: "Lühikirjeldus"
  - <button> "Vaata lähemalt" → product_detail.vue
  - <button> "Lisab ostukorvi"
  - h3: "Vitamiin Nimi 2"
  - p: "Lühikirjeldus"
  - <button> "Vaata lähemalt" → product_detail.vue
  - <button> "Lisab ostukorvi"
  - h3: "Vitamiin Nimi 3"
  - p: "Lühikirjeldus"
  - <button> "Vaata lähemalt" → product_detail.vue
  - <button> "Lisab ostukorvi"
- <footer>

**Navigation (out):**
- logo: "Nutrionista" → main.vue
- nav: "Avaleht" → main.vue
- nav: "Tooted" → shop.vue
- nav: "Minu konto" → profile.vue
- nav: "Ostukorv" → cart.vue
- button: "Vaata lähemalt" → product_detail.vue
- button: "Vaata lähemalt" → product_detail.vue
- button: "Vaata lähemalt" → product_detail.vue

## Page 6
**Label:** SHOP PAGE
**filename:** ShopView.vue
**url:** /shop
**API:** _(empty)_
**DTO:** _(empty)_
**Response:** _(empty)_
**Veateated:** _(empty)_

**Title (left sidebar):** E-pood
**Description:** Kuvatakse vitamiinid ja toidulisandid koos filtreerimis- ja sortimisvõimalus tega kategooria, hinna, brändi ja eesmärgi järgi. Võimalus osta tootekomplekte.

**Mockup content:**
- Nutrionista
- Avaleht
- Tooted
- Minu konto
- Ostukorv
- Vitamiinid ja Toidulisandid
- Kategooria:
- Hind:
- Bränd:
- Eesmärk:
- Sorteeri:
- Kõik
- Kõik
- Kõik
- Kõik
- Populaarsus
- Vitamiin C
- D-vitamiin
- B-kompleks
- Magneesium
- Immuunsuse toetuseks
- Luude ja hammaste heaks
- Energia ja närvisüsteem
- Lihaste ja närvide tööks
- 12.99 €
- 9.50 €
- 18.00 €
- 7.25 €
- Vaata lähemalt
- Vaata lähemalt
- Vaata lähemalt
- Vaata lähemalt
- Omega-3
- Tsink
- Kreatiin
- Kollageen
- Südame ja aju heaks
- Immuunsüsteemi tugi
- Lihaste kasv ja jõud
- Naha ja liigeste tervis
- 24.99 €
- 8.90 €
- 15.50 €
- 29.99 €
- Vaata lähemalt
- Vaata lähemalt
- Vaata lähemalt
- Vaata lähemalt
- Populaarsed tootekomplektid
- Immuunsuse Komplekt
- Energia Komplekt
- Sportlase Komplekt
- Vitamiin C, D ja Tsink
- B-kompleks, Magneesium ja Raud
- Kreatiin, Omega-3 ja Valgupulber
- 35.00 €
- 42.50 €
- 60.00 €
- Vaata komplekti
- Vaata komplekti
- Vaata komplekti
- © 2023 Nutrionista

**Image placeholders:**
- (129.9, 101.6) 75.1×71.3 — near "Vitamiin C"
- (243.3, 101.6) 75.1×71.3 — near "D-vitamiin"
- (356.8, 101.6) 75.1×71.3 — near "B-kompleks"
- (470.2, 101.6) 75.1×71.3 — near "Magneesium"
- (129.9, 183.6) 75.1×71.3 — near "Omega-3"
- (243.3, 183.6) 75.1×71.3 — near "Tsink"
- (356.8, 183.6) 75.1×71.3 — near "Kreatiin"
- (470.2, 183.6) 75.1×71.3 — near "Kollageen"
- (129.9, 288.6) 140.2×71.3 — near "Immuunsuse Komplekt"
- (280.9, 288.6) 140.2×71.3 — near "Energia Komplekt"
- (432.2, 288.6) 140.2×71.3 — near "Sportlase Komplekt"

_HTML page id: `shop`_

**Structure (HTML):**
- <header>
  - <nav>
    - <a> "Avaleht" → main.vue
    - <a> "Tooted" → shop.vue
    - <a> "Minu konto" → login.vue
    - <a> "Ostukorv" → cart.vue
- <main>
  - h1: "Vitamiinid ja Toidulisandid"
  - label: "Kategooria:"
  - label: "Hind:"
  - label: "Bränd:"
  - label: "Eesmärk:"
  - h3: "Vitamiin C"
  - p: "Immuunsuse toetuseks"
  - <button> "Vaata lähemalt" → product_detail.vue
  - h3: "D-vitamiin"
  - p: "Luude ja hammaste heaks"
  - <button> "Vaata lähemalt" → product_detail.vue
  - h3: "B-kompleks"
  - p: "Energia ja närvisüsteem"
  - <button> "Vaata lähemalt" → product_detail.vue
  - h3: "Magneesium"
  - p: "Lihaste ja närvide tööks"
  - <button> "Vaata lähemalt" → product_detail.vue
  - h2: "Populaarsed tootekomplektid"
  - h3: "Immuunsuse Komplekt"
  - p: "Vitamiin C, D ja Tsink"
  - <button> "Vaata komplekti"
  - h3: "Energia Komplekt"
  - p: "B-kompleks, Magneesium ja Raud"
  - <button> "Vaata komplekti"
  - h3: "Sportlase Komplekt"
  - p: "Kreatiin, Omega-3 ja Valgupulber"
  - <button> "Vaata komplekti"
- <footer>

**Navigation (out):**
- logo: "Nutrionista" → main.vue
- nav: "Avaleht" → main.vue
- nav: "Tooted" → shop.vue
- nav: "Minu konto" → login.vue
- nav: "Ostukorv" → cart.vue
- button: "Vaata lähemalt" → product_detail.vue
- button: "Vaata lähemalt" → product_detail.vue
- button: "Vaata lähemalt" → product_detail.vue
- button: "Vaata lähemalt" → product_detail.vue

## Page 7
**Label:** PRODUCT DETAIL PAGE
**filename:** ProductDetailView.vue
**url:** _(empty)_
**API:** _(empty)_
**DTO:** _(empty)_
**Response:** _(empty)_
**Veateated:** _(empty)_

**Title (left sidebar):** Toote detailvaade
**Description:** Esitatakse valitud vitamiini detailne kirjeldus, selle funktsioonid, imendumismeet odid, koostoimed ja puuduse sümptomid.

**Mockup content:**
- Nutrionista
- Avaleht
- Tooted
- Minu konto
- Ostukorv
- Funktsioonid
- • Toetab immuunsüsteemi
- Vitamiin Nimi
- • Aitab kaasa energia tootmisele
- Lühikirjeldus vitamiini kohta.
- • Oluline luude tervisele
- XX.XX €
- Imendumismeetodid
- Lisab ostukorvi
- • Rasvlahustuv
- • Vajab D-vitamiini
- Koostoimed
- C-vitamiin:
- Hea
- Raud:
- Neutraalne
- Tsink:
- Halb
- Puuduse sümptomid
- • Väsimus
- • Nõrk immuunsüsteem
- • Lihasnõrkus
- © 2023 Nutrionista

**Image placeholders:**
- (125.9, 50.7) 137.2×9.3 — near "Vitamiin Nimi"

_HTML page id: `product_detail`_

**Structure (HTML):**
- <header>
  - <nav>
    - <a> "Avaleht" → main.vue
    - <a> "Tooted" → shop.vue
    - <a> "Minu konto" → login.vue
    - <a> "Ostukorv" → cart.vue
- <main>
  - [img] Toote pilt
  - h1: "Vitamiin Nimi"
  - p: "Lühikirjeldus vitamiini kohta."
  - <button> "Lisab ostukorvi"
  - h2: "Funktsioonid"
  - <ul> (3 items)
    - • Toetab immuunsüsteemi
    - • Aitab kaasa energia tootmisele
    - • Oluline luude tervisele
  - h2: "Imendumismeetodid"
  - <ul> (2 items)
    - • Rasvlahustuv
    - • Vajab D-vitamiini
  - h2: "Koostoimed"
  - h2: "Puuduse sümptomid"
  - <ul> (3 items)
    - • Väsimus
    - • Nõrk immuunsüsteem
    - • Lihasnõrkus
- <footer>

**Navigation (out):**
- logo: "Nutrionista" → main.vue
- nav: "Avaleht" → main.vue
- nav: "Tooted" → shop.vue
- nav: "Minu konto" → login.vue
- nav: "Ostukorv" → cart.vue

## Page 8
**Label:** CART VIEW PAGE
**filename:** CartView.vue
**url:** /cart
**API:** _(empty)_
**DTO:** _(empty)_
**Response:** _(empty)_
**Veateated:** _(empty)_

**Title (left sidebar):** Ostukorv
**Description:** Kuvatakse valitud tooted, kogused ja koguhind, võimalusega tooteid eemaldada või koguseid muuta.

**Mockup content:**
- Nutrionista
- Avaleht
- Tooted
- Minu konto
- Ostukorv
- Ostukorv
- Vitamiin A
- Eemalda
- 12.50 € x
- 2
- Vitamiin B kompleks
- Eemalda
- 25.00 € x
- 1
- Vitamiin C
- Eemalda
- 8.75 € x
- 3
- Koguhind: 81.25 €
- Mine maksma
- © 2023 Nutrionista

_HTML page id: `cart`_

**Structure (HTML):**
- <header>
  - <nav>
    - <a> "Avaleht" → main.vue
    - <a> "Tooted" → shop.vue
    - <a> "Minu konto" → login.vue
    - <a> "Ostukorv" → cart.vue
- <main>
  - h1: "Ostukorv"
  - p: "Vitamiin A"
  - <button> "Eemalda"
  - p: "Vitamiin B kompleks"
  - <button> "Eemalda"
  - p: "Vitamiin C"
  - <button> "Eemalda"
  - <button> "Mine maksma" → checkout.vue
- <footer>

**Navigation (out):**
- logo: "Nutrionista" → main.vue
- nav: "Avaleht" → main.vue
- nav: "Tooted" → shop.vue
- nav: "Minu konto" → login.vue
- nav: "Ostukorv" → cart.vue
- button: "Mine maksma" → checkout.vue

## Page 9
**Label:** CHECKOUT PAGE
**filename:** CheckoutView.vue
**url:** /checkout
**API:** _(empty)_
**DTO:** _(empty)_
**Response:** _(empty)_
**Veateated:** _(empty)_

**Title (left sidebar):** Kassa
**Description:** Kogutakse tarne- ja makseandmed tellimuse vormistamiseks.

**Mockup content:**
- Nutrionista
- Avaleht
- Ostukorv
- Kassa
- Tarneandmed
- Täisnimi:
- Sisesta täisnimi
- Aadress:
- Sisesta aadress
- Linn:
- Sisesta linn
- Postiindeks:
- Sisesta postiindeks
- E-post:
- Sisesta e-post
- Telefon:
- Sisesta telefoninumber
- Makseandmed
- Kaardi number:
- XXXX XXXX XXXX XXXX
- Kehtivusaeg (MM/AA):
- CVV:
- MM/AA
- XXX
- Kinnita tellimus
- © 2023 Nutrionista

_HTML page id: `checkout`_

**Structure (HTML):**
- <header>
  - <nav>
    - <a> "Avaleht" → main.vue
    - <a> "Ostukorv" → cart.vue
- <main>
  - h1: "Kassa"
  - <section>
    - h2: "Tarneandmed"
    - label: "Täisnimi:"
    - input: Täisnimi: (text, placeholder="Sisesta täisnimi")
    - label: "Aadress:"
    - input: Aadress: (text, placeholder="Sisesta aadress")
    - label: "Linn:"
    - input: Linn: (text, placeholder="Sisesta linn")
    - label: "Postiindeks:"
    - input: Postiindeks: (text, placeholder="Sisesta postiindeks")
    - label: "E-post:"
    - input: E-post: (email, placeholder="Sisesta e-post")
    - label: "Telefon:"
    - input: Telefon: (tel, placeholder="Sisesta telefoninumber")
  - <section>
    - h2: "Makseandmed"
    - label: "Kaardi number:"
    - input: Kaardi number: (text, placeholder="XXXX XXXX XXXX XXXX")
    - label: "Kehtivusaeg (MM/AA):"
    - input: Kehtivusaeg (MM/AA): (text, placeholder="MM/AA")
    - label: "CVV:"
    - input: CVV: (text, placeholder="XXX")
  - <button> "Kinnita tellimus" → confirmation.vue
- <footer>

**Navigation (out):**
- logo: "Nutrionista" → main.vue
- nav: "Avaleht" → main.vue
- nav: "Ostukorv" → cart.vue
- button: "Kinnita tellimus" → confirmation.vue

**Form fields:**
- Täisnimi: (text) — placeholder "Sisesta täisnimi"
- Aadress: (text) — placeholder "Sisesta aadress"
- Linn: (text) — placeholder "Sisesta linn"
- Postiindeks: (text) — placeholder "Sisesta postiindeks"
- E-post: (email) — placeholder "Sisesta e-post"
- Telefon: (tel) — placeholder "Sisesta telefoninumber"
- Kaardi number: (text) — placeholder "XXXX XXXX XXXX XXXX"
- Kehtivusaeg (MM/AA): (text) — placeholder "MM/AA"
- CVV: (text) — placeholder "XXX"

## Page 10
**Label:** ???
**filename:** ???.vue
**url:** /???
**API:** _(empty)_
**DTO:** _(empty)_
**Response:** _(empty)_
**Veateated:** _(empty)_

**Title (left sidebar):** Nutrionista Avaleht Ostukorv
**Description:** © 2023 Nutrionista

**Mockup content:**
- Tellimus kinnitatud!
- Täname teid tellimuse eest. Teie tellimus on edukalt esitatud ja töödeldakse peagi.
- Tellimuse kokkuvõte
- Vitamiin Nimi 1
- 15.00 € x 2
- Vitamiin Nimi 2
- 25.50 € x 1
- Kogusumma:
- 55.50 €
- Tagasi avalehele

_HTML page id: `confirmation`_

**Structure (HTML):**
- <header>
  - <nav>
    - <a> "Avaleht" → main.vue
    - <a> "Ostukorv" → cart.vue
- <main>
  - h1: "Tellimus kinnitatud!"
  - p: "Täname teid tellimuse eest. Teie tellimus on edukalt esitatud ja töödeldakse peagi."
  - h2: "Tellimuse kokkuvõte"
  - p: "Vitamiin Nimi 1"
  - p: "15.00 € x 2"
  - p: "Vitamiin Nimi 2"
  - p: "25.50 € x 1"
  - <button> "Tagasi avalehele" → main.vue
- <footer>

**Navigation (out):**
- logo: "Nutrionista" → main.vue
- nav: "Avaleht" → main.vue
- nav: "Ostukorv" → cart.vue
- button: "Tagasi avalehele" → main.vue

## Page 11
**Label:** ORDER HISTORY PAGE
**filename:** OrderHistoryView.vue
**url:** /orderhistory
**API:** _(empty)_
**DTO:** _(empty)_
**Response:** _(empty)_
**Veateated:** _(empty)_

**Title (left sidebar):** Tellimuste ajalugu
**Description:** Kuvatakse kasutaja varasemad tellimused ja nende staatus.

**Mockup content:**
- Nutrionista
- Avaleht
- Tooted
- Minu konto
- Ostukorv
- Tellimuste ajalugu
- Tellimus #12345
- Kuupäev: 2023-10-26
- Staatus: Täidetud
- Tellimuse summa: 45.99 €
- Kohaletoimetamise aadress: Tänav 1, Linn, 12345
- Eeldatav tarne: 2-3 tööpäeva
- Makseviis: Krediitkaart
- Tellimuse detailid:
- Vitamiin A
- 12.99 € x 2
- 25.98 €
- Vitamiin C
- 10.00 € x 2
- 20.00 €
- Kokku: 45.99 €
- Tellimus #12344
- Kuupäev: 2023-09-15
- Staatus: Töötlemisel
- Tellimuse summa: 25.50 €
- Kohaletoimetamise aadress: Tänav 1, Linn, 12345
- Eeldatav tarne: 3-5 tööpäeva
- Makseviis: Pangaülekanne
- Tellimuse detailid:
- Vitamiin D
- 25.50 € x 1
- 25.50 €
- Kokku: 25.50 €
- © 2023 Nutrionista

_HTML page id: `order_history`_

**Structure (HTML):**
- <header>
  - <nav>
    - <a> "Avaleht" → main.vue
    - <a> "Tooted" → shop.vue
    - <a> "Minu konto" → profile.vue
    - <a> "Ostukorv" → cart.vue
- <main>
  - h1: "Tellimuste ajalugu"
  - h2: "Tellimus #12345"
  - p: "Kuupäev: 2023-10-26"
  - p: "Staatus: Täidetud"
  - p: "Tellimuse summa: 45.99 €"
  - p: "Kohaletoimetamise aadress: Tänav 1, Linn, 12345"
  - p: "Makseviis: Krediitkaart"
  - h3: "Tellimuse detailid:"
  - p: "Vitamiin A"
  - p: "12.99 € x 2"
  - p: "Vitamiin C"
  - p: "10.00 € x 2"
  - h2: "Tellimus #12344"
  - p: "Kuupäev: 2023-09-15"
  - p: "Staatus: Täidetud"
  - p: "Tellimuse summa: 25.50 €"
- <footer>

**Navigation (out):**
- logo: "Nutrionista" → main.vue
- nav: "Avaleht" → main.vue
- nav: "Tooted" → shop.vue
- nav: "Minu konto" → profile.vue
- nav: "Ostukorv" → cart.vue

## Page 12
**Label:** BLOG PAGE
**filename:** BlogView.vue
**url:** /blog
**API:** _(empty)_
**DTO:** _(empty)_
**Response:** _(empty)_
**Veateated:** _(empty)_

**Title (left sidebar):** Blogi/Artiklid
**Description:** Sisaldab informatiivseid artikleid vitamiinide, toitumise ja tervise kohta, et harida kasutajaid ja parandada SEO-d.

**Mockup content:**
- Nutrionista
- Avaleht
- Tooted
- Minu konto
- Ostukorv
- Blogi/Artiklid
- Artikli pealkiri 1
- Artikli pealkiri 2
- Artikli pealkiri 3
- Lühike kokkuvõte artikli sisust, et anda lugejale kiire
- ülevaade teemast.
- Lühike kokkuvõte artikli sisust, et anda lugejale kiire
- ülevaade teemast.
- Lühike kokkuvõte artikli sisust, et anda lugejale kiire
- ülevaade teemast.
- Loe edasi
- Loe edasi
- Loe edasi
- Artikli pealkiri 4
- Artikli pealkiri 5
- Artikli pealkiri 6
- Lühike kokkuvõte artikli sisust, et anda lugejale kiire
- ülevaade teemast.
- Lühike kokkuvõte artikli sisust, et anda lugejale kiire
- ülevaade teemast.
- Lühike kokkuvõte artikli sisust, et anda lugejale kiire
- ülevaade teemast.
- Loe edasi
- Loe edasi
- Loe edasi
- © 2023 Nutrionista

**Image placeholders:**
- (112.6, 73.0) 140.6×140.6 — near "Artikli pealkiri 1"
- (264.0, 73.0) 140.6×140.6 — near "Artikli pealkiri 2"
- (415.8, 73.0) 140.6×140.6 — near "Artikli pealkiri 3"
- (112.6, 224.4) 140.6×140.6 — near "Artikli pealkiri 4"
- (264.0, 224.4) 140.6×140.6 — near "Artikli pealkiri 5"
- (415.8, 224.4) 140.6×140.6 — near "Artikli pealkiri 6"

_HTML page id: `blog`_

**Structure (HTML):**
- <header>
  - <nav>
    - <a> "Avaleht" → main.vue
    - <a> "Tooted" → shop.vue
    - <a> "Minu konto" → profile.vue
    - <a> "Ostukorv" → cart.vue
- <main>
  - h1: "Blogi/Artiklid"
  - h3: "Artikli pealkiri 1"
  - p: "Lühike kokkuvõte artikli sisust, et anda lugejale kiire ülevaade teemast."
  - <button> "Loe edasi"
  - h3: "Artikli pealkiri 2"
  - p: "Lühike kokkuvõte artikli sisust, et anda lugejale kiire ülevaade teemast."
  - <button> "Loe edasi"
  - h3: "Artikli pealkiri 3"
  - p: "Lühike kokkuvõte artikli sisust, et anda lugejale kiire ülevaade teemast."
  - <button> "Loe edasi"
- <footer>

**Navigation (out):**
- logo: "Nutrionista" → main.vue
- nav: "Avaleht" → main.vue
- nav: "Tooted" → shop.vue
- nav: "Minu konto" → profile.vue
- nav: "Ostukorv" → cart.vue

## Page 13
**Label:** CONTACT PAGE
**filename:** ContactView.vue
**url:** /contact
**API:** _(empty)_
**DTO:** _(empty)_
**Response:** _(empty)_
**Veateated:** _(empty)_

**Title (left sidebar):** Tagasiside & Kontakt
**Description:** Võimaldab kasutajatel esitada tagasisidet, kasutada kontaktivormi või tulevikus live chati.

**Mockup content:**
- Nutrionista
- Avaleht
- Tooted
- Minu konto
- Ostukorv
- Tagasiside & Kontakt
- Saada meile tagasisidet
- Võta meiega ühendust
- Nimi:
- E-post: info@nutrionista.ee
- Telefon: +372 123 4567
- Sisesta oma nimi
- Aadress: Näidis tänav 1, Tallinn, Eesti
- E-post:
- Live Chat (tulevikus)
- Sisesta oma e-post
- Sõnum:
- Live chat funktsionaalsus on arendamisel ja lisatakse peagi!
- Sisesta oma tagasiside siia...
- Saada tagasiside
- © 2023 Nutrionista

_HTML page id: `contact`_

**Structure (HTML):**
- <header>
  - <nav>
    - <a> "Avaleht" → main.vue
    - <a> "Tooted" → shop.vue
    - <a> "Minu konto" → profile.vue
    - <a> "Ostukorv" → cart.vue
- <main>
  - h1: "Tagasiside & Kontakt"
  - h2: "Saada meile tagasisidet"
  - <form>
    - label: "Nimi:"
    - input: Nimi: (text, placeholder="Sisesta oma nimi")
    - label: "E-post:"
    - input: E-post: (email, placeholder="Sisesta oma e-post")
    - label: "Sõnum:"
    - input: Sõnum: (textarea, placeholder="Sisesta oma tagasiside siia...")
    - <button> "Saada tagasiside"
  - h2: "Võta meiega ühendust"
  - p: "E-post: info@nutrionista.ee"
  - p: "Telefon: +372 123 4567"
  - p: "Aadress: Näidis tänav 1, Tallinn, Eesti"
  - h2: "Live Chat (tulevikus)"
  - p: "Live chat funktsionaalsus on arendamisel ja lisatakse peagi!"
- <footer>

**Navigation (out):**
- logo: "Nutrionista" → main.vue
- nav: "Avaleht" → main.vue
- nav: "Tooted" → shop.vue
- nav: "Minu konto" → profile.vue
- nav: "Ostukorv" → cart.vue

**Form fields:**
- Nimi: (text) — placeholder "Sisesta oma nimi"
- E-post: (email) — placeholder "Sisesta oma e-post"
- Sõnum: (textarea) — placeholder "Sisesta oma tagasiside siia..."

## Page 14
**Label:** FAQ PAGE
**filename:** FaqView.vue
**url:** /faq
**API:** _(empty)_
**DTO:** _(empty)_
**Response:** _(empty)_
**Veateated:** _(empty)_

**Title (left sidebar):** KKK
**Description:** Korduma kippuvate küsimuste paneel vitamiinide, annuste, raseduse ja tellimise kohta.

**Mockup content:**
- Nutrionista
- Avaleht
- Tooted
- Minu konto
- Ostukorv
- Korduma Kippuvad Küsimused
- Vitamiinide kohta
- K: Mis on vitamiinid ja miks need on olulised?
- V: Vitamiinid on orgaanilised ühendid, mida organism vajab normaalseks kasvuks ja toimimiseks. Need on olulised ainevahetuses, 
- immuunsüsteemi toetamisel ja rakkude kaitsmisel.
- K: Kuidas valida õigeid vitamiine?
- V: Õigete vitamiinide valik sõltub teie individuaalsetest vajadustest, toitumisest ja elustiilist. Soovitame 
- konsulteerida arsti või toitumisnõustajaga.
- Annuste kohta
- K: Millised on soovitatavad vitamiiniannused?
- V: Soovitatavad annused varieeruvad sõltuvalt vitamiinist, vanusest, soost ja tervislikust seisundist. Järgige alati toote etiketil olevaid juhiseid või 
- konsulteerige spetsialistiga.
- K: Kas vitamiine on võimalik üle doseerida?
- V: Jah, teatud vitamiinide (eriti rasvlahustuvate) liigne tarbimine võib olla kahjulik. Olge ettevaatlik ja ärge 
- ületage soovitatud annuseid.
- Raseduse ja imetamise ajal
- K: Milliseid vitamiine on raseduse ajal vaja?
- V: Raseduse ajal on eriti olulised foolhape, raud, kaltsium ja D-vitamiin. Enne vitamiinide võtmist konsulteerige 
- kindlasti oma arstiga.
- K: Kas imetamise ajal on vitamiinide võtmine ohutu?
- V: Enamik vitamiine on imetamise ajal ohutud, kuid alati on soovitatav konsulteerida arstiga, et tagada nii ema 
- kui ka lapse heaolu.
- Tellimise kohta
- K: Kuidas ma saan tellimust esitada?
- V: Saate tellimuse esitada meie veebipoes, lisades soovitud tooted ostukorvi ja järgides maksejuhiseid.
- K: Millised on tarneajad ja -kulud?
- V: Tarneajad ja -kulud sõltuvad teie asukohast ja valitud tarneviisist. Täpsema info leiate meie tarneinfo lehelt.
- © 2023 Nutrionista

_HTML page id: `faq`_

**Structure (HTML):**
- <header>
  - <nav>
    - <a> "Avaleht" → main.vue
    - <a> "Tooted" → shop.vue
    - <a> "Minu konto" → profile.vue
    - <a> "Ostukorv" → cart.vue
- <main>
  - h1: "Korduma Kippuvad Küsimused"
  - h2: "Vitamiinide kohta"
  - p: "K: Mis on vitamiinid ja miks need on olulised?"
  - p: "V: Vitamiinid on orgaanilised ühendid, mida organism vajab normaalseks kasvuks ja toimimiseks. Need on olulised ainevahetuses, immuunsüsteemi toetamisel ja rakkude kaitsmisel."
  - p: "K: Kuidas valida õigeid vitamiine?"
  - p: "V: Õigete vitamiinide valik sõltub teie individuaalsetest vajadustest, toitumisest ja elustiilist. Soovitame konsulteerida arsti või toitumisnõustajaga."
  - h2: "Annuste kohta"
  - p: "K: Millised on soovitatavad vitamiiniannused?"
  - p: "V: Soovitatavad annused varieeruvad sõltuvalt vitamiinist, vanusest, soost ja tervislikust seisundist. Järgige alati toote etiketil olevaid juhiseid või konsulteerige spetsialistiga."
  - p: "K: Kas vitamiine on võimalik üle doseerida?"
  - p: "V: Jah, teatud vitamiinide (eriti rasvlahustuvate) liigne tarbimine võib olla kahjulik. Olge ettevaatlik ja ärge ületage soovitatud annuseid."
  - h2: "Raseduse ja imetamise ajal"
  - p: "K: Milliseid vitamiine on raseduse ajal vaja?"
  - p: "V: Raseduse ajal on eriti olulised foolhape, raud, kaltsium ja D-vitamiin. Enne vitamiinide võtmist konsulteerige kindlasti oma arstiga."
- <footer>

**Navigation (out):**
- logo: "Nutrionista" → main.vue
- nav: "Avaleht" → main.vue
- nav: "Tooted" → shop.vue
- nav: "Minu konto" → profile.vue
- nav: "Ostukorv" → cart.vue

