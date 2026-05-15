# Button navigation — Nutrionista balsamiq.pdf

Maintained by the `read-pdf-areas` skill. The skill loads this file before analyzing the PDF and asks the user about any button it cannot resolve here. New answers are appended as rows.

| Button label | Where it appears | Destination |
|---|---|---|
| `Avaleht` | header nav (all pages) | Page 1 — Avaleht (Home) |
| `Tooted` | header nav (all pages) | Page 6 — E-pood (Shop) |
| `Tee vitamiinitest` | hero CTA | Page 3 — Vitamiinitest (Quiz) |
| `Vaata lähemalt` | product card CTA | Page 7 — Toote detailvaade (Product Detail) |
| `Minu konto` | header nav | Page 4 — Personaalne vitamiiniprofiil (Profile) |
| `Ostukorv` | header nav | Page 8 — Ostukorv (Cart) |
| `Mine maksma` | Cart page CTA | Page 9 — Kassa (Checkout) |
| `Kinnita tellimus` | Checkout page CTA | Page 10 — Tellimus kinnitatud (Order Confirmation) |
| `Tellimuste ajalugu` | Profile page button | Page 11 — Tellimuste ajalugu (Order History) |
| `Soovikorv` | Profile page button | Page 5 — Soovikorv (Wishlist) |
| `Telli uuesti` | Profile purchased-vitamin tile | Page 8 — Ostukorv (Cart) |
| `Tagasi avalehele` | Order-confirmation CTA | Page 1 — Avaleht (Home) |
| `Logi sisse` | Login-page submit | Page 1 — Avaleht (Home) — after successful auth |

## Deferred answers

The destination for these buttons is not yet decided / not yet in the mockup. The skill should treat them as known (don't re-ask) and surface them as `→ ?  *(deferred)*` in the analysis until the row is moved up to the main table.

| Button label | Where it appears | Why deferred |
|---|---|---|
| `Loo uus konto` | Login-page secondary | Account-creation page is not yet in the mockup; user will add it to the PDF later, then resolve. After signup the user lands on Page 1 (Home). |
| `Esita vastused` | Quiz submit | Destination not yet decided; revisit later. |
| `Saada tagasiside` | Contact-form submit | Destination not yet decided; revisit later. |
