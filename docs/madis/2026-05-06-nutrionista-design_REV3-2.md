# Nutrionista — Design Spec

**Date:** 2026-05-06 (initial), 2026-05-08 (rev. 2 — pivoted to e-commerce), 2026-05-14 (rev. 3 — schema aligned to DB model XML, authentication removed, project renamed), 2026-05-14 (rev. 3.1 — minimal login restored as a UI-only role hint; backend still has no security enforcement)
**Type:** School project, team of 3, 2-week MVP
**Status:** Rev. 3.1. Schema is the canonical reference defined in `docs/nutrionista_2026-05-14_09_09.xml`. **Commerce tables (`orders`, `order_items`) are not yet modelled and will be added in the first post-revision task.** A single `POST /api/login` endpoint exists for UI role-gating; the backend has no security filter and `/api/admin/**` remains openly accessible.

---

## 1. Project Overview

Nutrionista is a web-based **vitamin and supplement online store** that combines a product catalog with rich educational content. Each product is a nutrient (vitamin, mineral, supplement) and each product detail page doubles as an encyclopedia entry — describing:

1. What the nutrient is for (biological functions)
2. How the body absorbs it (mechanisms and influencing factors)
3. How it interacts with other nutrients
4. What deficiency symptoms it addresses

A visitor can browse the catalog, read nutrient information, and (once the commerce tables land) add products to a cart and complete a checkout. There is **no admin login** — admin pages live at known URLs and are not access-controlled in the MVP.

The project is built by a 3-person student team. The primary success criteria are:

- The end-to-end purchase flow works (browse → product detail → cart → checkout → confirmation) **once `orders` / `order_items` are added**.
- The educational content is preserved on each product page (functions, absorption, interactions, deficiencies — all modelled through the generalized `properties` table).
- The codebase is organized and clearly understandable.
- The result is presentable in a class demo.

**Scope discipline.** The full UI mockup at `docs/nutrionista-mockup.html` shows additional features (vitamin quiz with personal recommendations, wishlist, bundles, blog, FAQ, reorder reminders, brand/goal filters, live chat). These are **out of scope for the MVP** — see §14.

## 2. Constraints

- **Team size:** 3 students collaborating via GitHub.
- **Schema size:** 8 tables as defined in `docs/nutrionista_2026-05-14_09_09.xml` (canonical DB model). The schema generalizes the original 12 educational tables into a `properties` + `nutrient_properties` pair, dropping the per-domain junction tables. `orders` and `order_items` will be added in a follow-up revision.
- **Deadline:** 2 weeks from spec approval. Scope cuts in §14 are non-negotiable inside this window.
- **Hosting:** Free tiers only — Render (backend + database) and Vercel (frontend).
- **Each student works on their own PC** but the deployed app is the demo target.

## 3. Stack

| Layer    | Technology                            | Hosting           |
| -------- | ------------------------------------- | ----------------- |
| Frontend | Vue 3 SPA + Tailwind CSS + Axios + Pinia (cart store) + Vue Router | Vercel (free)     |
| Backend  | Java 21 + Spring Boot 3 + Spring Data JPA + Springdoc OpenAPI + Lombok | Render (free)     |
| Database | PostgreSQL                            | Render (free)     |
| Migrations | Flyway (built into Spring Boot)     | Runs on app start |

**No authentication library.** `jBCrypt` and Spring Security are deliberately omitted — see §6.

## 4. Architecture

```
   ┌──────────────────────────────┐
   │  Public visitor (or admin)   │
   └──────────────┬───────────────┘
                  │ HTTPS
                  ▼
   ┌──────────────────────────────┐
   │  Vue 3 SPA on Vercel         │
   │  - Public catalog pages      │
   │  - Admin CMS pages (open)    │
   └──────────────┬───────────────┘
                  │ Axios → REST/JSON (CORS)
                  ▼
   ┌──────────────────────────────┐
   │  Spring Boot API on Render   │
   │  - All endpoints open        │
   │  - No auth filter            │
   │  - Flyway runs on startup    │
   └──────────────┬───────────────┘
                  │ JDBC
                  ▼
   ┌──────────────────────────────┐
   │  PostgreSQL on Render        │
   │  - 8 tables (per XML model)  │
   │  - + orders/order_items TBD  │
   │  - Seeded via Flyway         │
   └──────────────────────────────┘
```

**Key flows:**

- **Login (UI role-gating):** Vue → `POST /api/login` with `{username, password}` → Spring Boot looks up `users.username`, BCrypt-checks the password against `users.password_hash` → returns `{username, role}` (no token). Vue stores the response in a Pinia `authStore` and shows admin UI when `role === 'ADMIN'`. The backend has **no enforcement** on top of this — `/api/admin/**` stays openly accessible (see §6).
- **Public browse:** Vue → `GET /api/nutrients` → Spring Boot → PostgreSQL → JSON. Same for `GET /api/nutrients/{id}` (product detail with full educational content joined from `properties` and `nutrient_properties`).
- **Cart:** Cart lives **in the browser** (Pinia store, persisted to `localStorage`). Adding/removing items never touches the backend until checkout. A guest can fill a cart at any time.
- **Checkout (planned, depends on `orders`/`order_items`):** Vue posts cart contents + shipping form to `POST /api/orders`. Backend creates an `orders` row + N `order_items` rows in a single transaction, snapshots `unit_price` from the current `nutrients.price`, and returns the new `order_id`. Vue clears the cart and shows the confirmation page. **This flow lights up once the commerce migration lands.**
- **Admin write:** Admin pages (`/admin/*` in the SPA, `/api/admin/**` in the API) are openly accessible — there is no login. Anyone who knows the URL can edit catalog data. This is an explicit MVP trade-off (see §6) and must be addressed before any real deployment beyond the demo.
- **Cold-start mitigation:** A free cron-job.org job pings `/actuator/health` every 14 minutes, keeping the Render free-tier backend warm.

## 5. Database Schema (8 tables, per DB model XML)

The schema is the one defined in `docs/nutrionista_2026-05-14_09_09.xml`. Compared to the original 12-table educational spec, the team generalized the four lookup tables (functions, absorption methods, absorption factors, deficiency symptoms) into a single `properties` table with a `type` discriminator, and their per-domain junctions into the single `nutrient_properties` table. `interaction_types` was replaced by `color_codes` so the UI color is part of the lookup itself. Images move from a URL string on `nutrients` into a dedicated `nutrient_image` table that stores binary data.

Highlights:

- **Generalized lookups.** `properties` holds rows of every educational property (function / absorption method / absorption factor / deficiency symptom). The `type` column (`varchar(3)`) discriminates which kind of property each row is — e.g. `FN`, `AM`, `AF`, `DS`. The team will fix the exact codes in the seed migration.
- **Generalized junction.** `nutrient_properties` (id, nutrients_id, properties_id, effect_type) links nutrients to any property. `effect_type` is always set (NOT NULL); rows for absorption-factor properties carry `ENHANCE` or `INHIBIT`, all other rows carry `NEUTRAL`.
- **Color-coded interactions.** `color_codes` is the interaction-quality lookup — each row has a label (`GOOD`, `NEUTRAL`, `BAD`) plus the hex/CSS color the UI should render for that label. `nutrient_interactions` references `color_codes` directly through `interaction_type_id`. The three labels match the mockup's `Hea` / `Neutraalne` / `Halb` user-facing wording; the previous four-category set (ENHANCES/SYNERGISTIC/REQUIRES/INHIBITS) was simplified to fit what the product page actually shows.
- **Binary images.** `nutrient_image.image_data` is `bytea`. `nutrients.image_id` is a non-nullable foreign key, so every nutrient must have an image row — a placeholder image must be seeded for nutrients without artwork.
- **`users` exists, but is unused in the MVP.** §6 explains: no login is implemented. The table is kept so future revisions can add auth without a schema change.
- **`orders` + `order_items` are intentionally not in this revision.** They will be added as a follow-up; the SPA's checkout flow stays a `cart.clear() + alert()` placeholder until then.

### Tables (as defined in the XML)

```sql
-- 1. categories
CREATE TABLE categories (
  id          SERIAL PRIMARY KEY,
  name        VARCHAR(100) UNIQUE NOT NULL,
  description TEXT
);

-- 2. nutrients
CREATE TABLE nutrients (
  id          SERIAL PRIMARY KEY,
  name        VARCHAR(100) UNIQUE NOT NULL,
  description VARCHAR(500),
  category_id INTEGER NOT NULL REFERENCES categories(id),
  price       NUMERIC(8,2) NOT NULL DEFAULT 0 CHECK (price >= 0),  -- € amount
  in_stock    BOOLEAN NOT NULL DEFAULT true,
  created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  image_id    INTEGER NOT NULL REFERENCES nutrient_image(id)
);

-- 3. properties  (generalized lookup for functions / absorption / factors / deficiencies)
CREATE TABLE properties (
  id          SERIAL PRIMARY KEY,
  type        VARCHAR(3)  NOT NULL,   -- discriminator: FN | AM | AF | DS (exact codes finalised at seed time)
  name        VARCHAR(150) NOT NULL,
  description VARCHAR(150)
);

-- 4. nutrient_properties  (generalized junction)
CREATE TABLE nutrient_properties (
  id            SERIAL PRIMARY KEY,
  nutrients_id  INTEGER NOT NULL REFERENCES nutrients(id),
  properties_id INTEGER NOT NULL REFERENCES properties(id),
  effect_type   VARCHAR(10) NOT NULL DEFAULT 'NEUTRAL'
                 CHECK (effect_type IN ('ENHANCE','INHIBIT','NEUTRAL'))
);

-- 5. color_codes  (interaction-type lookup, includes the UI color)
CREATE TABLE color_codes (
  id          SERIAL PRIMARY KEY,
  name        VARCHAR(10) UNIQUE NOT NULL,   -- GOOD | NEUTRAL | BAD
  color_code  VARCHAR(10) NOT NULL           -- e.g. "#22c55e" or a Tailwind token
);

-- 6. nutrient_interactions  (directional A → B with an interaction type)
CREATE TABLE nutrient_interactions (
  id                  SERIAL PRIMARY KEY,
  nutrient_id         INTEGER NOT NULL REFERENCES nutrients(id) ON DELETE CASCADE,
  related_nutrient_id INTEGER NOT NULL REFERENCES nutrients(id) ON DELETE CASCADE,
  interaction_type_id INTEGER NOT NULL REFERENCES color_codes(id),
  description         VARCHAR(200),
  CHECK (nutrient_id <> related_nutrient_id)
);

-- 7. users  (kept for future auth; not used in the MVP — see §6)
CREATE TABLE users (
  id            SERIAL PRIMARY KEY,
  username      VARCHAR(50) UNIQUE NOT NULL,
  password_hash VARCHAR(60) NOT NULL,
  role          VARCHAR(10) NOT NULL CHECK (role IN ('ADMIN','USER')),
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 8. nutrient_image  (binary image data; linked from nutrients.image_id)
CREATE TABLE nutrient_image (
  id           SERIAL PRIMARY KEY,
  image_data   BYTEA   NOT NULL
);
-- The link between a nutrient and its image is owned by nutrients.image_id.
-- We deliberately do NOT include a back-pointer (nutrients_id) on nutrient_image:
-- it would create a circular FK with nutrients.image_id (chicken-and-egg insert problem)
-- and would also be redundant — every image is reached through nutrients.image_id.
-- One nutrient → one image. If a future revision needs multiple images per nutrient,
-- drop nutrients.image_id and add a back-pointer here instead.
```

### Schema notes

- **Property discrimination.** `properties.type` is a 3-character code, NOT a CHECK-constrained enum in the XML. Pick the codes once (e.g. `FN`, `AM`, `AF`, `DS`) and document them in the seed migration's comment block. Application code must filter by `type` to render the right section of the product detail page.
- **`nutrient_properties.effect_type`.** Always set (NOT NULL, default `'NEUTRAL'`). For absorption-factor rows (`properties.type='AF'`) the UI presents `ENHANCE` / `INHIBIT` / `NEUTRAL`; for all other property kinds (functions, absorption methods, deficiency symptoms) the row is stored as `'NEUTRAL'` and the UI hides the field. Using `'NEUTRAL'` instead of NULL keeps every row explicit and removes the "is this field actually missing or just N/A?" ambiguity.
- **`nutrient_interactions` is directional** — `(A, B, BAD)` means "taking A together with B is bad for B". Inserting the inverse pair would make a different (possibly incorrect) claim, so admin UI must label the two dropdowns clearly.
- **`color_codes` is what the dot panel reads.** The frontend's colored-dot component looks up the color via `interaction_type_id`. Putting the color in the DB row means the UI doesn't need a hard-coded mapping.
- **`nutrients.image_id` is NOT NULL** and `nutrient_image` has no back-pointer to `nutrients` (see comment in the SQL above). Migration order is therefore: V`<n>`__create_nutrient_image.sql creates the image table first, V`<m>`__create_nutrients.sql adds the `nutrients` table with its FK pointing at the already-existing image table. The seed migration inserts a placeholder image row (id=1) before inserting any nutrients, so the NOT NULL constraint is satisfiable for nutrients without artwork.
- **`ON DELETE CASCADE`** is set on `nutrient_interactions.nutrient_id` and `nutrient_interactions.related_nutrient_id` only. The other FKs (`nutrient_properties.*`, `nutrients.image_id`, `nutrients.category_id`) are `ON DELETE NONE`, meaning admin deletes will fail until dependents are cleared first. This is conservative and acceptable for the MVP.
- **No timestamps on lookup or junction tables.** Only `nutrients` and `users` have `created_at` / `updated_at`. The lookup tables (`categories`, `properties`, `color_codes`) and the binary `nutrient_image` table are seeded and rarely edited.
- **Cart is not in the schema** and never will be — cart state lives in the browser (Pinia store + `localStorage`). It only becomes rows in the future `orders` / `order_items` tables at checkout.

#### Explanatory: why a single generalized `properties` table

The original spec defined four separate lookup tables (`functions`, `absorption_methods`, `absorption_factors`, `deficiency_symptoms`) plus four matching junctions. The XML collapses them into one `properties` table + one `nutrient_properties` junction. The trade-off:

| Aspect | Separate tables (old spec) | Single `properties` (XML) |
|---|---|---|
| Migrations | 4 lookup migrations + 4 junctions | 1 lookup migration + 1 junction |
| Admin CRUD | 4 admin screens | 1 admin screen with a `type` filter |
| Query for "all functions of nutrient X" | `JOIN nutrient_functions` | `JOIN nutrient_properties WHERE properties.type='FN'` |
| Risk | Lots of near-identical boilerplate | A single misclassified `type` value contaminates the whole catalog |

Both designs work; the XML choice trades a small ongoing query-filter overhead for a much smaller code surface in a 2-week sprint. The team agreed to live with the `type` column's discipline.

#### Explanatory: directional interactions

`nutrient_interactions` has two columns referencing `nutrients`:

- `nutrient_id` — the "actor"
- `related_nutrient_id` — the recipient
- `interaction_type_id` — what kind of interaction (FK to `color_codes`)

A row reads like a sentence: **"`nutrient_id` is `interaction_type` with `related_nutrient_id`"**. Example: `(Vitamin C, Iron, GOOD)` = "Vitamin C is GOOD with Iron" (it helps iron absorption); `(Calcium, Iron, BAD)` = "Calcium is BAD with Iron" (it inhibits iron absorption). Swapping the two nutrient columns produces a different (and not necessarily correct) claim, so the admin form must label the dropdowns as **"Nutrient"** and **"Related to"** so the order is entered on purpose. `CHECK (nutrient_id <> related_nutrient_id)` is a backstop preventing rows like "Iron is GOOD with iron".

`color_codes` carries the UI color directly (`color_code` column), so the dot panel renders by looking up `interaction_type_id → color_codes.color_code`. No hard-coded mapping in the frontend.

#### Explanatory: timestamps only on `nutrients` and `users`

`nutrients` is the table admins edit most often (names, descriptions, prices, in-stock flag), so `created_at` / `updated_at` earn their keep. `users` carries only `created_at` for account-audit purposes; passwords change so rarely that `updated_at` is overhead. Lookup tables (`categories`, `properties`, `color_codes`) are seeded once and don't need audit columns.

## 6. Authentication

**The MVP has no security enforcement, but it does have a UI-only login for role-gating.**

There is a single `POST /api/login` endpoint. It looks up `users.username`, BCrypt-checks the password against the seeded `password_hash`, and returns `{username, role}`. The SPA stores this in a Pinia `authStore` (persisted to `localStorage`) and uses `auth.isAdmin` (`role === 'ADMIN'`) to gate the admin UI: the NavBar admin dropdown, the `/admin/*` route guards (`meta: { requiresAdmin: true }`), and the "Edit" / "Delete" buttons on the public catalog pages.

That is the entire mechanism. There is no token, no session, no `Authorization` header, no server-side admin filter, no `register` endpoint, and no `logout` endpoint. **The role is a UI hint, not a security boundary.**

### Concretely:

- `POST /api/login` exists. Body: `{username, password}`. On success: `{username, role}` (200). On mismatch: 401. No cookie set, no token returned.
- The `users` table is seeded with the team's admin accounts (`madis` / `kaili` / `rain`, all role `ADMIN`) plus a fallback `admin@nutrionista.ee`. Passwords are bcrypt hashes in `V8__seed_admins.sql`.
- `jbcrypt` stays in `backend/pom.xml` — it's what `AuthService` uses to verify the seeded hashes (`BCrypt.checkpw`).
- `/api/**` endpoints (including `/api/admin/**`) are openly accessible. Anyone hitting them directly with `curl` succeeds regardless of role. The SPA's role-gate is cosmetic.
- The Vue SPA maintains an `authStore` with `{username, role}` but **no token**. The cart and any future order submission are still anonymous from the backend's perspective.

### Why this minimal model (and not full auth)

This is a 2-week school project that will be torn down or rewritten after the demo. The two weeks are better spent on:

1. Filling out the educational schema (`properties`, `nutrient_properties`, `nutrient_interactions`, `color_codes`).
2. Building the catalog + product detail experience that proves Nutrionista is more than a generic store.
3. Adding the `orders` / `order_items` tables and the checkout flow.

A real auth subsystem (sessions, password reset, CSRF awareness, admin-vs-user split, lockout policy, refresh tokens) is a meaningful amount of code and presents little to a class demo audience that cannot inspect the security model live. The minimal login keeps the demo's "log in as Madis → admin buttons appear" moment without the dead-weight subsystem.

### Risk acknowledgement

- **Anyone hitting `/api/admin/**` with `curl` can edit your catalog.** The SPA's role-gate stops casual visitors who use the UI, not anyone who reads this spec. Do not seed real product data you care about; treat the demo content as throwaway.
- **Future revisions can upgrade to real auth** without a schema change for `users`. The previous "users + sessions + BCrypt + custom filter" design (in the git history of this spec, before commit `a93ed1b`) is the reference implementation when that revision arrives.

### `users` table retention rationale

The XML keeps `users`. Rev. 3.1 actively uses it (login lookups). The seed (`V8__seed_admins.sql`) stays as the source of demo credentials. **Treat the `users` table as a credential store for the login UI, not as a security boundary** — the backend never asks "who is this request from?" beyond the explicit login call.

## 7. API Surface (high level)

REST endpoints follow standard CRUD conventions. Detailed request/response shapes will be defined in the implementation plan.

**All endpoints below are open — there is no security enforcement. `POST /api/login` exists for UI role-gating only (see §6).**

**Auth (UI role-gating only, see §6):**

```
POST   /api/login                        ← body: {username, password}; response: {username, role}
                                            BCrypt-checks against users.password_hash; returns 401 on
                                            mismatch. No token, no session — SPA uses the role to gate
                                            admin UI client-side.
```

**Public catalog:**

```
GET  /api/categories
GET  /api/categories/{id}
GET  /api/nutrients                      ← shop grid; supports ?category={id} filter
GET  /api/nutrients/{id}                 ← product detail page payload: nutrient + price + in_stock
                                            + properties (filtered by type: FN/AM/AF/DS) + interactions
GET  /api/nutrients/search?q={query}
GET  /api/nutrients/highlights           ← home page "Esiletõstetud Tooted" — the 4 newest in-stock nutrients
                                            (no `featured` column; selection is by `created_at DESC + in_stock = true LIMIT 4`)
GET  /api/color-codes                    ← interaction-type lookup (id, name, color_code)
GET  /api/nutrient-image/{id}            ← returns image_data bytes for a nutrient image row
GET  /actuator/health                    ← keep-alive endpoint
```

**Admin catalog (open — no server-side auth, UI-gated by `auth.isAdmin`, see §6):**

```
POST   /api/admin/nutrients
PUT    /api/admin/nutrients/{id}         ← edit name, description, category, price, in_stock, image
DELETE /api/admin/nutrients/{id}         ← refuses if dependent rows still reference it (no ON DELETE CASCADE
                                            on nutrient_properties or nutrient_image — clear them first)
POST   /api/admin/categories
PUT    /api/admin/categories/{id}
DELETE /api/admin/categories/{id}
POST   /api/admin/properties             ← create/edit/delete property rows; admin UI filters by type
PUT    /api/admin/properties/{id}
DELETE /api/admin/properties/{id}
POST   /api/admin/nutrient-properties    ← link a nutrient ↔ property (with effect_type for AF rows)
PUT    /api/admin/nutrient-properties/{id} ← edit an existing link (typically to change effect_type)
DELETE /api/admin/nutrient-properties/{id}
POST   /api/admin/nutrient-interactions  ← nutrient → related_nutrient + interaction_type (color_codes id)
PUT    /api/admin/nutrient-interactions/{id}
DELETE /api/admin/nutrient-interactions/{id}
POST   /api/admin/color-codes            ← rarely edited; seeded once
PUT    /api/admin/color-codes/{id}
DELETE /api/admin/color-codes/{id}
POST   /api/admin/nutrient-image         ← upload a new image (multipart bytea)
```

**Orders (TBD — `orders` + `order_items` will be added in the next revision):**

```
POST   /api/orders                       ← create order from cart contents; planned shape:
                                            {items:[{nutrientId, quantity}], full_name, address,
                                            city, postal_code, email, phone}
GET    /api/admin/orders                 ← list all orders, supports ?status= filter
GET    /api/admin/orders/{id}            ← single order detail
PUT    /api/admin/orders/{id}/status     ← body: {status: 'PAID'|'SHIPPED'|'CANCELLED'}
```

CORS: Spring Boot is configured to allow requests from `http://localhost:5173` (dev) and the Vercel frontend domain (prod). Update `CorsConfig` to include the deployed Vercel URL before the demo.

### 7.1 Why no `/api/cart` endpoints

The cart is **client-side only** (Pinia store + `localStorage`). Adding/removing items, changing quantities, and computing the running total are pure frontend operations. The first time the cart touches the backend is at checkout, when its contents become a `POST /api/orders` body.

**Trade-offs of this decision:**

- **Saves time.** No `cart`/`cart_items` tables, no cart endpoints, no session/cart sync logic. For a 2-week build, this is the single biggest scope cut available without sacrificing the demo flow.
- **Cart does not follow the user across devices.** A user adding items on their phone won't see them on their laptop. Acceptable for a school demo.
- **Cart can be lost.** If the user clears browser storage, their cart vanishes. Acceptable; no real money at stake.
- **Easier to demo offline.** The cart works even if the backend is asleep (Render free-tier cold start) — items add instantly because no API call is made.

### 7.2 API Documentation (Swagger / OpenAPI)

The backend uses **springdoc-openapi** to auto-generate interactive API documentation from the Spring Boot controllers.

- Dependency added to `backend/pom.xml`:
  ```xml
  <dependency>
      <groupId>org.springdoc</groupId>
      <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
      <version>2.3.0</version>
  </dependency>
  ```
- OpenAPI 3 spec available at: `http://localhost:8080/v3/api-docs` (JSON).
- Swagger UI available at: `http://localhost:8080/swagger-ui.html` (interactive HTML).
- Regenerates automatically on app startup; no separate documentation file to maintain.
- Optional `@Operation` / `@ApiResponse` annotations on controllers enrich the docs but are not required.

#### Explanatory: what Swagger does and why we use it

OpenAPI is a standardised format for describing REST APIs — endpoints, methods, request bodies, response shapes, status codes. **Swagger** is the historical name and most common name for the tooling around it (the spec was renamed OpenAPI in 2017; in practice both names are used interchangeably).

In Spring Boot, the `springdoc-openapi` library scans every `@RestController` at startup, reads the request mappings, path variables, request bodies, and return types, and produces:

1. A machine-readable JSON specification at `/v3/api-docs`.
2. An interactive web page at `/swagger-ui.html` that lists every endpoint with "Try it out" buttons that send real requests.

**Why this benefits us:**

- **Cross-team coordination.** When Kaili finishes the absorption endpoints, Rain can open Swagger UI, see the exact JSON shape returned, and write the Axios call against the real contract. No "ask in Discord what the response looks like" step.
- **Testing without Postman.** Click "Try it out" → fill in parameters → execute → see the response. No jumping between tools during development.
- **Catches inconsistencies.** Seeing every endpoint listed in one place makes naming or casing drift across controllers obvious early.
- **Strong demo asset.** Showing Swagger UI in the presentation demonstrates that the backend is a real, documented, testable API — not a hand-wave.

**Security note.** Swagger UI exposes the list of all endpoints to anyone who visits the URL. For a school project this is acceptable and arguably useful (the professor can poke at the API). In a production deployment with sensitive data, the URL would normally be gated behind authentication or disabled outside development.

## 8. Frontend (Vue SPA)

The frontend is a Vue 3 SPA using **Vue Router** for navigation, **Pinia** for cart state, **Axios** for HTTP, and **Tailwind CSS** for styling. The visual design (colors, typography, layout proportions) follows the mockup at `docs/nutrionista-mockup.html`, which also uses Tailwind. Tailwind tokens are defined in `frontend/tailwind.config.js` — components should use them (`bg-primary`, `text-text-muted`) rather than hard-coding the hex values inline.

### Visual design tokens (from mockup)

| Token | Value | Use |
|---|---|---|
| Primary | `#e6007a` (pink) | CTAs (Add to cart, Checkout), prices, key headings |
| Secondary | `#90ee90` (light green) | Secondary buttons ("View" / "Add to cart" / "Cancel" actions) |
| Header/footer band | `#e0ffe0` (very light green) | Top header strip and footer strip |
| Surface | `#ffffff` | Cards, panels |
| Background | `#f8f8f8` | Page background |
| Text main | `#000000` / `#333333` | Body text |
| Text muted | `#666666` | Secondary captions |
| Border | `#dddddd` / `#eeeeee` | Card borders, dividers |

### Public routes

| Route                | Purpose                                                  |
| -------------------- | -------------------------------------------------------- |
| `/`                  | **Avaleht** — welcome message + "Esiletõstetud Tooted" grid showing the 4 newest in-stock nutrients (`GET /api/nutrients/highlights`) |
| `/shop`              | **Tooted** — full product grid + category filter          |
| `/product/:id`       | **Toote leht** — encyclopedia content + price + Add to cart. Interactions shown as colored dots; the color comes from `color_codes.color_code` for each `interaction_type_id`. |
| `/cart`              | **Ostukorv** — cart contents (from Pinia), quantities, remove, total, "Mine maksma" button |
| `/checkout`          | **Kassa** — shipping form. Submits cart + form via `POST /api/orders` once the orders endpoint lands. Until then the page should clearly say "Tellimine peagi" rather than fake a success. |
| `/confirmation/:id`  | **Tellimus kinnitatud** — order summary; lit up by the future orders endpoint |
| `/login`             | **Sisselogimine** — username + password form; submits to `POST /api/login`. On success, stores `{username, role}` in the Pinia `authStore` and redirects to `/admin` if `role === 'ADMIN'`, otherwise to `/`. On 401, shows an "Invalid credentials" message. |

There is **no `/register` route** — the `users` table is seeded once via `V8__seed_admins.sql`, not opened to the public.

### Auth store (Pinia)

A `authStore` keyed on `{username, role}` (never a token):

- `login(username, password)` posts to `/api/login`, stores the response on success.
- `logout()` clears the store (no backend call — there's no session to invalidate).
- Computed `isAdmin` returns `role === 'ADMIN'`.
- Persisted to `localStorage` so the role survives page refreshes.

The Axios instance in `frontend/src/api.js` does **not** send an `Authorization` header — there is no token to send. The NavBar admin dropdown and `/admin/*` route guards (`meta: { requiresAdmin: true }`) both check `auth.isAdmin` client-side.

### Admin routes (gated client-side by `auth.isAdmin`)

| Route                       | Purpose                                                |
| --------------------------- | ------------------------------------------------------ |
| `/admin`                    | Dashboard with links to catalog CRUD pages (route guard checks `auth.isAdmin`) |
| `/admin/nutrients`          | List + create + edit + delete nutrients (name, description, category, price, in_stock, image upload) |
| `/admin/categories`         | List + create + edit + delete categories |
| `/admin/properties`         | List + create + edit + delete educational properties (with type filter: FN/AM/AF/DS) |
| `/admin/nutrient-properties`| Link/unlink properties to nutrients; set `effect_type` for AF rows |
| `/admin/nutrient-interactions` | Create/edit `nutrient_interactions` rows (Nutrient → Related to → color_codes type, description) |
| `/admin/color-codes`        | Edit interaction-type labels + colors (rarely used after seed) |
| `/admin/orders`             | List orders + change status (depends on the commerce migration) |

The route guards `meta: { requiresAdmin: true }` check `auth.isAdmin` and redirect to `/login` if the user isn't an admin. **This is purely client-side** — anyone bypassing the SPA (typing `/api/admin/**` directly into `curl`) can still write. See §6.

### UI input pattern for fixed-value fields

Fixed-value fields use Vue `<select>` dropdowns rather than free-text inputs:

- `effect_type` in `nutrient_properties` → dropdown with three options: `ENHANCE` / `INHIBIT` / `NEUTRAL`. The dropdown only appears when the linked property's `type` is `AF` (absorption factor); for other property kinds the row is created with `effect_type = 'NEUTRAL'` and the field is hidden.
- `interaction_type_id` in `nutrient_interactions` → dropdown populated from `GET /api/color-codes`.
- `properties.type` → dropdown of the agreed codes (FN/AM/AF/DS), set at row creation time.
- `orders.status` (admin-only, once orders ship) → dropdown: `PENDING` / `PAID` / `SHIPPED` / `CANCELLED`.

This eliminates typo and casing inconsistencies at the UI level. The DB `CHECK` constraints are defense in depth.

### Cart state (Pinia)

A single `cartStore` with:

- `items: { nutrientId, name, unitPrice, imageUrl, quantity }[]`
- `addItem(nutrient)`, `removeItem(nutrientId)`, `setQuantity(nutrientId, qty)`, `clear()`
- Computed `totalAmount`
- **A watcher persists `items` to `localStorage` on every change and the store rehydrates on app boot.** Today's `cart.js` has neither — needs fixing.

Cart never touches the backend until `POST /api/orders` is called (future).

## 9. Repository Structure

**GitHub repository:** [`github.com/luhtmakaili/nutrionista-full`](https://github.com/luhtmakaili/nutrionista-full). Single monorepo with two top-level project folders.

### Target layout (the spec describes the *desired* layout — see "Migration note" below)

```
nutrionista-full/
├── backend/
│   ├── pom.xml
│   ├── src/main/java/com/nutrionista/
│   │   ├── NutrionistaApplication.java
│   │   ├── controller/
│   │   ├── entity/
│   │   ├── repository/
│   │   └── service/
│   └── src/main/resources/
│       ├── application.properties
│       └── db/migration/
│           ├── V1__create_categories.sql
│           ├── V2__create_nutrients.sql
│           ├── … (one V<n> file per table + relationships)
│           └── V100__seed_data.sql
├── frontend/
│   ├── package.json
│   ├── vite.config.js
│   └── src/
│       ├── api.js
│       ├── components/
│       ├── router/
│       ├── stores/
│       └── views/
└── docs/
    ├── 2026-05-06-nutrionista-design_REV3-2.md  ← this file
    ├── nutrionista-mockup.html             ← Balsamiq mockup
    └── nutrionista_2026-05-14_09_09.xml      ← canonical DB model
```

- **Java base package:** `com.nutrionista`
- **Maven artifact:** `groupId=com.nutrionista`, `artifactId=nutrionista-backend`

### Migration note (current code does NOT match this layout)

As of Rev. 3.1, the backend code lives at `backend/category/src/demo/src/main/java/com/example/demo/` with `groupId=com.example`, `artifactId=demo`. That nesting and naming is an accident of how Spring Initializr was run; it does not reflect the intended structure. **Relocating the backend to the target layout above is on the team's punch list** — done by whoever picks up the catalog cleanup. Until that move, every backend path in the rest of this spec should be read as the target — not the current state.

### Branching strategy

```
main (default, deployable)
  ├── design-docs                        ← documentation work
  ├── feature/orders-api                 ← orders/order_items migration + endpoints
  ├── feature/properties-schema          ← properties + nutrient_properties + nutrient_interactions
  └── feature/admin-pages                ← admin CRUD UI
```

- `main` — what gets deployed. PRs into `main` after at least one teammate review.
- `feature/<name>` — short-lived; one branch per task; merged via PR.
- The spec previously referenced a `dev`/`front` integration branch. The team has been working directly off `main` so far; if/when integration churn justifies it, introduce `dev` and update this section. Until then, branch off `main`, PR into `main`.

PR title format: `[area] description` — e.g. `[backend] orders endpoint`, `[frontend] interaction-dots component`.

## 10. Database Migrations (Flyway)

- Schema files live in `backend/src/main/resources/db/migration/`.
- Flyway runs automatically on Spring Boot startup, applying any new versioned migrations in order.
- Once a migration is committed and merged, it is **never edited** — changes are made via new migration files (e.g., `V13__add_color_to_categories.sql`).
- The team's `sample_data.sql` is shipped as `V100__seed_data.sql`, so a fresh database boots up fully seeded.

### Local development setup

**Each teammate runs PostgreSQL locally — there is no H2 profile.** Dev and prod use the same database engine so Flyway migrations, `bytea` image storage, and PostgreSQL-specific SQL behave identically in both environments.

- Install PostgreSQL on your laptop (any 14+ version).
- Create a local database (e.g., `nutrionista_dev`) and a user with full rights on it.
- Point `backend/src/main/resources/application.properties` at it via `spring.datasource.url` / `username` / `password`.
- On first `./mvnw spring-boot:run`, Flyway will create all tables and seed data automatically.

The codebase currently carries a redundant `application-postgres.properties` and a commented-out H2 block in `application.properties` — both are slated for removal in the §12 foundation cleanup. There is one canonical `application.properties`.

### Explanatory: what is Flyway and why we use it

#### The problem migrations solve

The 3 of us each have our own PostgreSQL running on our own laptop. We all need:

- The same 8 tables (+ `orders` / `order_items` once they're added)
- The same columns and constraints
- The same seed data

Without a tool to manage this, schema changes happen like:

1. Madis writes the SQL for a new table, runs it on his PC.
2. Madis pastes the SQL in Discord; Kaili runs it on her PC.
3. Rain misses the message. His database doesn't have the table.
4. A week later, Madis adds a column to that table. Sends new SQL. Some apply it, some don't, some apply it twice and get errors, someone has a typo.
5. All three databases drift apart. Code that runs on Madis's machine breaks on Rain's. Hours are wasted figuring out why.

This is called **schema drift**, and it is the most common source of "but it works on my machine" bugs in team projects.

#### What a migration is

A **migration** is just a single SQL file in the repo that represents one step of database change. Example:

```sql
-- V1__create_categories.sql
CREATE TABLE categories (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) UNIQUE NOT NULL,
  description TEXT
);
```

The file lives in the repo, gets committed in git, gets reviewed in PRs — exactly like Java code.

#### What Flyway does

Flyway is a small tool that runs automatically when the Spring Boot app starts. On startup it:

1. Connects to the local PostgreSQL.
2. Looks in `backend/src/main/resources/db/migration/` for files named `V<number>__<name>.sql`.
3. Checks a tracking table called `flyway_schema_history` to see which migrations have already been applied to *this* database.
4. Runs any **new** migrations, in version-number order.
5. Records each one in `flyway_schema_history`.
6. Hands control over to Spring Boot, which then starts the app.

#### File naming convention

The format is **`V` + number + `__` (two underscores) + descriptive name + `.sql`**:

```
V1__create_categories.sql       ← runs first
V2__create_nutrient_image.sql   ← must run before nutrients (nutrients.image_id references it)
V3__create_nutrients.sql
V4__create_properties.sql
V5__create_nutrient_properties.sql
V6__create_color_codes.sql
V7__create_nutrient_interactions.sql
V8__create_users.sql
... (further V<n> files for orders / order_items once Madis adds them)
V100__seed_data.sql             ← runs after all schema is in place
```

The number determines run order. The name after `__` is for humans. We use `V100` for the seed data so it's well after the schema files; the exact number doesn't matter as long as it's higher than the last schema migration.

#### Daily workflow

**Day 1, Madis:**

- Adds `V1__create_categories.sql` to `db/migration/`.
- Commits, pushes, opens a PR.
- A teammate reviews and merges into `main`.

**Day 1, Kaili (later):**

- `git pull` — picks up the new migration file.
- Starts the Spring Boot app (via `./mvnw spring-boot:run` or the IDE's Run button).
- Flyway sees that `V1` has not been applied to Kaili's database, runs it automatically, creates the `categories` table.
- Kaili's database now matches Madis's. No Discord copy-paste, no manual SQL.

**Day 5, someone needs to add a column:**

- They write a new file: `V13__add_color_to_categories.sql` containing `ALTER TABLE categories ADD COLUMN color VARCHAR(20);`.
- Commit, push, merge.
- Everyone else `git pull`s and restarts the app — Flyway applies V13 to their local database automatically.

#### The "never edit a committed migration" rule

Once a migration file has been merged into `main`, it must **never be modified**. If a change is needed, create a new migration file with a new version number.

The reason: Flyway records a checksum of every applied migration. If a teammate has already applied `V1` and someone else later edits `V1`, Flyway will refuse to start the app — it sees that the file no longer matches what was originally applied.

The correct way to make a change is therefore always: **add a new `V<n>__...` file** (e.g., `V14__rename_categories_column.sql`).

#### Recovery if a database gets corrupted

Because all schema and seed data live in versioned migration files, recovering a broken local database is straightforward:

1. Drop the local database (or all tables in it).
2. Restart the Spring Boot app.
3. Flyway re-applies V1 through V100 from scratch — schema and seed data both rebuild automatically.

#### Why this matters for the team

- No more manual SQL pastes in Discord. The schema is in git, like the rest of the code.
- Schema drift becomes impossible — everyone's database matches `main`.
- History: every change is a versioned file with a commit author and date.
- Recovery is one command (drop + restart).

This is the standard way Java + PostgreSQL teams manage schema in 2026; learning it once will be useful well beyond this project.

## 11. Deployment

| Component | Provider     | Plan          | Notes                                     |
| --------- | ------------ | ------------- | ----------------------------------------- |
| Frontend  | Vercel       | Free          | `git push` → auto-deploy from `frontend/` |
| Backend   | Render       | Free Web Service | Sleeps after 15 min idle               |
| Database  | Render       | Free Postgres | Free tier expires after 90 days          |
| Keep-alive | cron-job.org | Free          | Pings `/actuator/health` every 14 min     |

**Vercel monorepo setup.** Because this is a monorepo, Vercel needs explicit configuration — the default settings build the repo root and fail (no `package.json` there). In Vercel project settings:

- **Root Directory:** `frontend/`
- **Build Command:** `npm run build`
- **Output Directory:** `dist`

Set these once at project creation; afterwards `git push` to `main` auto-deploys.

## 12. Team Task Split

The team is three students — **Rain**, **Kaili**, and **Madis** — collaborating via `github.com/luhtmakaili/nutrionista-full`. **There are no pre-assigned task owners.** Whoever has time picks up the next item on the punch list; everyone is expected to work across the stack as needed. Standups (in whatever form the team uses) decide who takes what.

### Work to do (no specific owner — pick what's free)

The remaining work, grouped by area:

**Foundation cleanup**
- Relocate the backend out of `backend/category/src/demo/` into the target layout in §9.
- Rename the Java package `com.example.demo` → `com.nutrionista`.
- **DONE** (commits `7530110`, `a93ed1b`) — Trim the backend auth code to the minimal login: deleted `AuthFilter`, `Session`, `SessionRepository`, `V6__create_sessions.sql`. Rewrote `AuthController` + `AuthService` to a single `POST /api/login` returning `{username, role}`. Dropped `LoginResponse.token`. **Kept** `jbcrypt` in `pom.xml` — it verifies the seeded BCrypt hashes.
- **DONE** (commit `7530110`) — Deleted the cut-feature backend code: `BlogPost*`, `FaqItem*` entities/repos/controllers + the V3/V4 migrations.
- Delete the cut features' frontend: `BlogView`, `AdminBlogView`, `AdminFaqView`, `QuizView`, `WishlistView`, `OrderHistoryView`, `ContactView`, plus their router entries. `FaqView` stays as a static page (content typed in code, no DB).
- Trim the frontend auth code to match the new minimal model: rewire `LoginView` to `POST /api/login`; rewire `stores/auth.js` to hold `{username, role}` from the response (no token); delete the bearer interceptor in `api.js` (no token to send). **Keep** the `meta: { requiresAdmin: true }` route guards — they now check `role === 'ADMIN'` client-side.
- Clean up: garbage files in `frontend/` (`a.price`, `b.price`, `n.category.id`, `{`), commit a top-level `.gitignore` covering `.idea/` and `node_modules/`, fix `frontend/README.md` reference to `src/services/`.
- Delete the redundant `backend/src/main/resources/application-postgres.properties` and remove the commented-out H2 block from `application.properties` — there is one canonical Postgres config (see §10 "Local development setup").

**Backend catalog (per XML schema)**
- Flyway migrations V1–V8 for the 8 XML tables (rewrite the current ones to match the XML column-by-column).
- Seed migration: at least the `color_codes` rows (`GOOD` = `#22c55e` green, `NEUTRAL` = `#eab308` yellow, `BAD` = `#ef4444` red), the `properties.type` codes (FN/AM/AF/DS), a placeholder `nutrient_image` row so `nutrients.image_id NOT NULL` is satisfiable.
- Entities + repositories for `Category`, `Nutrient`, `Property`, `NutrientProperty`, `ColorCode`, `NutrientInteraction`, `User`, `NutrientImage`.
- Public catalog endpoints (see §7): `/api/categories`, `/api/nutrients` (with `?category=`, `/search`, `/highlights`, `/{id}`), `/api/color-codes`, `/api/nutrient-image/{id}`.
- Admin catalog endpoints (open, see §7): nutrients / categories / properties / nutrient-properties / nutrient-interactions / color-codes / nutrient-image CRUD.
- Swagger UI verified at `/swagger-ui.html`, CORS updated to include the Vercel domain.

**Commerce (the next revision)**
- Design `orders` + `order_items` tables (column types, FKs, CHECKs) and write the migrations.
- Entities + repositories + service.
- `POST /api/orders` (creates order + items in one transaction, snapshots `unit_price`).
- `GET /api/admin/orders` (list + `?status=` filter) and `PUT /api/admin/orders/{id}/status`.
- Document the JSON body shape so the frontend checkout form lines up.

**Frontend**
- Cart store: add the `localStorage` watcher + correct the field shape to `{ nutrientId, name, unitPrice, imageUrl, quantity }`.
- Public pages on live data: Home highlights grid (4 newest in-stock), Shop grid + filters, ProductDetail rendering the educational properties + colored-dot interactions panel.
- Checkout page wired to `POST /api/orders` (once the endpoint exists), and a `/confirmation/:id` page.
- Admin pages: Nutrients / Categories / Properties / Nutrient-properties / Interactions / Color codes / Orders.
- Tailwind tokens: replace inline `bg-[#e6007a]` hex with `bg-primary` etc., or commit to inline hex everywhere — pick one.

**Deployment**
- Render web service for the backend, Render Postgres, Vercel for the frontend.
- cron-job.org keep-alive ping every 14 minutes to `/actuator/health`.
- End-to-end smoke test on the deployed URLs before the demo.

### Suggested 14-day rhythm (no person tags — claim what's free at standup)

```
Day 1-3   Foundation cleanup (relocation, rename, drop auth code, delete cut features)
Day 4-6   Catalog backend + Frontend public pages on live data
Day 7-9   Commerce (orders/order_items) + admin pages
Day 10-11 Deployment + end-to-end smoke test
Day 12-13 Polish, bug fixes, demo rehearsal — no new features
Day 14    Demo
```

### Pair points (these always need a quick chat before someone starts)

- **Order DTO shape** (before commerce work begins): whoever takes the backend endpoint and whoever takes the checkout form must agree on the JSON body.
- **Interaction-dots data** (before the dot panel work begins): the JSON shape returned by `GET /api/nutrients/{id}` for interactions must match what `<InteractionDot>` consumes. `color_codes.color_code` should arrive on the client without a hardcoded mapping.
- **Property type codes** (before any property seed migration is written): the team picks the values for `properties.type` (suggested: `FN`/`AM`/`AF`/`DS`) and writes them down here once decided.

### Branch strategy reminder (from §9)

All work on feature branches off `main`, merged via PR with one teammate review. PR title format: `[area] description`, e.g. `[backend] orders endpoint`, `[frontend] interaction dots`.

## 13. Demo Plan

> **Status: on hold.** Project completion is not yet certain; revisit this section once the MVP is built. Until then, treat the flow below as a sketch — it assumes `orders` / `order_items` have shipped (steps 4-6) and may need rewriting once the actual feature set is known.

- The application is deployed on Render (backend + Postgres) + Vercel (frontend); the demo URL is the Vercel domain.
- The backend is kept warm by the cron-job.org keep-alive ping, so requests respond quickly during the presentation.

### Demo flow (the critical path that must work)

1. **Browse.** Open the home page; show the 4 newest in-stock nutrients ("Esiletõstetud Tooted"). Click "Tooted" → product grid; filter by category.
2. **Read.** Click a product (e.g., "Iron"). Show the full educational content sourced from `properties` (functions, absorption methods, absorption factors with enhance/inhibit) and **the colored-dot interactions panel** (Vitamin C 🟢 Hea, Magnesium 🟡 Neutraalne, Calcium 🔴 Halb) sourced from `nutrient_interactions` + `color_codes` — proving that this is more than a generic store.
3. **Add to cart.** From the detail page, click "Lisa ostukorvi". Click another product, add it. Open the cart (Ostukorv). Adjust a quantity. Total updates live (Pinia, persisted to `localStorage`).
4. **Checkout.** Click "Mine maksma" — no login required (there is no login). Fill the shipping form. Submit. The backend creates an `orders` row + `order_items` rows (assumes the commerce migration has landed). Confirmation page shows the order number, items, total.
5. **Admin.** Open `/admin/nutrients` directly (no login). Edit Iron's price or `in_stock` flag, save. Open `/admin/orders`, find the order just placed, change status `PENDING → PAID`.
6. **Verify.** Reload the public product page → new price visible. The flow is end-to-end.
7. **Swagger.** Open `/swagger-ui.html`. Show the API surface (catalog, orders, admin). Run a "Try it out" on `GET /api/nutrients/highlights` → live JSON response. Demonstrates that the backend is real, documented, and inspectable.

### What to say, not show

If anyone in Q&A asks **"how is the admin section protected?"**, answer honestly: it isn't, in the MVP. Explain that re-introducing auth is the obvious follow-up (the `users` table is already in place), but the team chose to spend the two weeks on the catalog depth and commerce flow rather than a security model that can't be meaningfully reviewed live.

If the **vitamin quiz**, **personalized recommendations**, **wishlist**, **order history page**, or **product bundles** come up: acknowledge them as part of the longer-term vision (visible in the Balsamiq mockup) and explain that the team prioritized a working end-to-end commerce flow over breadth for the 2-week MVP. The schema and architecture are designed to extend for those features without breaking changes.

### Explanatory: cron-job.org and the cold-start problem

#### The cold-start problem

Render's free tier for backends has a cost-saving behaviour: **if the backend receives no requests for ~15 minutes, Render puts the application to sleep.** The container is unloaded from memory, freeing resources for other free-tier users.

When the next request arrives, Render has to **wake the container back up**. For a Spring Boot app this typically takes **30–60 seconds**:

- The container starts.
- Spring Boot initialises (loading the JVM, scanning beans, connecting to the database, running Flyway).
- Only then does the first request finally get answered.

For us during the live presentation, this is a serious problem. If the backend has been idle while the previous group presented, the moment our professor clicks our first button the page hangs for almost a minute. It looks broken even though it isn't.

#### What cron-job.org does for us

[cron-job.org](https://cron-job.org) is a free service that runs **scheduled HTTP requests on our behalf** — basically a cron job hosted in the cloud. We give it:

- A URL: `https://<our-render-app>.onrender.com/actuator/health`
- A schedule: **every 14 minutes**

That's all. cron-job.org then hits the URL on its schedule, 24 hours a day. Each ping counts as a request to our backend, which **resets Render's 15-minute idle timer**. Because we ping every 14 minutes (one minute *before* Render's 15-minute threshold), the backend never has time to fall asleep.

The endpoint being pinged — `/actuator/health` — is provided by Spring Boot Actuator (a dependency we add to `pom.xml`). It returns a tiny `{"status":"UP"}` JSON response: cheap to serve, suitable for monitoring.

#### Why this benefits us

- **No cold starts during the demo.** Whatever the professor clicks responds immediately — the backend has been kept warm for hours.
- **No need to remember to "warm up" beforehand.** The cron-job runs continuously, so we are protected even if our presentation slot moves or starts unexpectedly.
- **Free.** cron-job.org has a generous free tier; one job pinging every 14 minutes is well within it.
- **No code changes other than the Actuator dependency.** Five lines in `pom.xml`, no logic to write.

#### The one trade-off to be aware of

Render's free backend plan also includes a **750 hours of compute per month** cap (roughly the number of hours in a 31-day month). A backend that is kept warm 24/7 by our keep-alive ping uses about **720 hours per month** — comfortably under the cap, but worth knowing.

If we were running multiple keep-alive backends on the same free Render account, we would risk hitting the 750-hour ceiling. With just our single Nutrionista backend, we have ~30 hours of slack.

#### Setup checklist

1. Add `spring-boot-starter-actuator` to `backend/pom.xml`.
2. Deploy the backend to Render and copy the public URL.
3. Sign up for cron-job.org (free, email only).
4. Create a cron job:
   - **URL:** `https://<our-app>.onrender.com/actuator/health`
   - **Schedule:** every 14 minutes
   - **Title:** `Nutrionista keep-alive`
5. Verify that the dashboard shows green/200 OK responses.

## 14. Out of Scope

The Balsamiq mockup at `docs/nutrionista-mockup.html` shows substantially more functionality than the MVP commits to. The features below are **explicitly cut** for the 2-week MVP. They are listed here so the team has a single source of truth on what *not* to build, and so future iterations have a clear backlog.

### Cut from the mockup (deliberate, do not implement)

| Feature | Reason for cut |
|---|---|
| **Vitamin quiz (Vitamiinitest)** + **personalized vitamin profile (Vitamiiniprofiil)** | Requires question/option/result tables, recommendation rules engine, profile UI. ~20–30 hours. |
| **Wishlist (Soovikorv)** | Adds 1 table + 2 endpoints + 1 page for a feature that doesn't change the demo's wow factor. Doubly out of scope without auth. |
| **Product bundles (Tootekomplektid)** | Requires `bundles` + `bundle_products` tables and bundle detail pages. |
| **Order history page (Tellimuste ajalugu)** | Requires a per-user "my orders" listing — meaningless without login, which is out of scope. |
| **Reorder reminders** | Requires scheduled job + reminder table + email/notification dispatch — fully separate subsystem. |
| **Brand filter, Goal filter** in the shop | Requires `brands` + `product_goals` tables and many-to-many joins. Category filter alone is enough for the demo. |
| **Blog (Blogi/Artiklid)** | Cut entirely from the data model (the existing `blog_posts` table + `BlogPostController` + `/blog` route should be deleted in Rev. 3 cleanup). |
| **FAQ (KKK)** | Cut from the data model (the existing `faq_items` table + `FaqItemController` + `/faq` route should be deleted in Rev. 3 cleanup). A static FAQ Vue component is acceptable as a Day 12–13 stretch goal. |
| **Contact / feedback form (Tagasiside & Kontakt)** | Cut. Show a static contact-info page only as a stretch. |
| **Live chat** | Already labeled "tulevikus" (in the future) in the mockup. Cut. |
| **Real payments** | The checkout collects shipping info only — no card capture, no payment provider. |
| **Authentication & user accounts** | See §6. The `users` table stays in the schema for future use; no login/register pages, no admin role enforcement. |

### Cut from the original encyclopedia spec

| Feature | Reason for cut |
|---|---|
| **Foods + food-nutrient amounts** | Doubles content authoring work. |
| **Recommended daily intake** | Not visible on the e-commerce product detail page in the current mockup. |
| **Body systems and academic source citations** | Out of scope for the commerce focus. |
| **Separate per-domain lookup tables** (functions, absorption_methods, absorption_factors, deficiency_symptoms) | Replaced by the generalized `properties` table + `type` discriminator per the XML schema. |

### In scope but not yet modelled (no pre-assigned owner)

| Item | Status |
|---|---|
| `orders` + `order_items` tables, entities, migration | First task after spec freeze (2026-05-14) |
| `POST /api/orders` endpoint | Depends on tables above |
| Checkout page wired to a real backend | Depends on endpoint above |
| `/confirmation/:id` page | Depends on endpoint above |
| Backend relocation out of `backend/category/src/demo/` | Foundation cleanup, Day 1-3 |

### Backlog-ready extensions (the schema already permits them)

If post-demo work continues, these features fit cleanly:

- Re-add `sessions` + login → the `users` table already has the columns to support it.
- Wishlist → add `wishlist_items (user_id, nutrient_id)` (5-minute migration once auth exists).
- Order status workflow → `orders.status` becomes a CHECK-constrained string, easy to extend with `'REFUNDED'`, etc.
- Per-user order history → the page just renders `GET /api/orders/me` once auth + user_id-on-orders are in place.
