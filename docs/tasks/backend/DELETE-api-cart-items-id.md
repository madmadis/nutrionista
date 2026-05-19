# DELETE /api/cart-items/{id}

**Kontroller:** `CartController.java`
**Tüüp:** Backend
**Staatus:** To Do

## Mockup

![CartView](../../mock/pictures/CartView.png)

## Kontekst

CartView (leht 8) kuvab kasutaja ostukorvi koos toodete, koguste ja koguhinnaga. See endpoint eemaldab ühe ostukorvi rea (`cart_item`) ID järgi. Frontend kutsub seda välja, kui kasutaja vajutab „Eemalda" nuppu või lohistab koguse alla 1. Sama lehe teised endpointid: `GET /api/users/{userId}/cart` (korvi laadimine), `POST /api/carts/{cartId}/items` (toote lisamine), `PUT /api/cart-items/{id}` (koguse muutmine), `DELETE /api/carts/{cartId}/items` (korvi tühjendamine).

## API leping

| Väli | Väärtus |
|------|---------|
| Meetod | `DELETE` |
| Tee | `/api/cart-items/{id}` |
| Auth | Jah — sisselogitud kasutaja |

### Request Body

Puudub — path parameetri kaudu (`{id}` on `cart_item.id`)

### Response Body

Puudub — HTTP 204 No Content

## Veahaldus

| Olukord | Exception klass | ErrorResponse enum | HTTP staatus |
|---------|----------------|-------------------|--------------|
| Ostukorvi rida ei leita antud ID-ga | `CartItemNotFoundException` | `CART_ITEM_NOT_FOUND` | 404 |

> **Märkus veahalduse kohta:**
> Kontrolli, kas vajalikud `ErrorResponse` enum kirjed ja exception klassid juba eksisteerivad:
> - `backend/src/main/java/ee/nutrionista/infrastructure/error/ErrorResponse.java`
> - `backend/src/main/java/ee/nutrionista/infrastructure/exception/`
>
> Puuduvate enum kirjete puhul lisa need `ErrorResponse`-i. Puuduvate exception klasside puhul loo uus klass `exception/` paketti (järgi olemasolevate klasside mustrit) ja registreeri see `RestExceptionHandler`-is.

## Andmebaas

Seotud tabelid: `cart_item`, `cart`

Endpoint kustutab ühe rea tabelist `cart_item` primaarvõtme (`id`) järgi. Enne kustutamist kontrollitakse, kas rida eksisteerib — kui mitte, visatakse `CartItemNotFoundException`. `cart_item` sisaldab FK-d `cart.id`-le ja `nutrient.id`-le, kuid kustutamisel neid ei puututa.

## Vastuvõtu kriteeriumid

- [ ] `DELETE /api/cart-items/{id}` olemasoleva ID-ga tagastab `204 No Content`
- [ ] `DELETE /api/cart-items/{id}` mitteolemasoleva ID-ga tagastab `404` koos `CART_ITEM_NOT_FOUND` veaga
- [ ] Kustutatud rida ei ole pärast päringut `cart_item` tabelis
- [ ] `CartItemNotFoundException` on loodud `exception/` paketti ja registreeritud `RestExceptionHandler`-is
- [ ] `CART_ITEM_NOT_FOUND` kirje on lisatud `ErrorResponse` enum-i
- [ ] Controller, Service, Repository kihid on eraldatud
- [ ] Kontrolleri meetodil on `@Operation` annotatsioon
- [ ] Swagger UI kaudu on endpoint nähtav ja testitav