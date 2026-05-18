# Nutrionista — Design Spec

**Date:** 2026-05-06 (initial), 2026-05-08 (rev. 2 — pivoted to e-commerce), 2026-05-14 (rev. 3 — schema aligned to DB model XML, authentication removed, project renamed), 2026-05-14 (rev. 3.1 — minimal login restored as a UI-only role hint; backend still has no security enforcement), 2026-05-15 (rev. 4 — tables singularized, `role` lookup table added, build tool switched to Gradle, backend bumped to Spring Boot 4, MapStruct + p6spy added, manual init-scripts replace Flyway as the current local-DB workflow, repository moved to `github.com/madmadis/nutrionista`), 2026-05-16 (rev. 4.1 — schema realigned to `docs/nutrionista_data_model_v2.xml` / `docs/nutrionista_data_model_v2.pdf`; 16 tables; commerce tables `order` + `order_item` now modelled; `cart` + `cart_item` moved into the DB; `billing` + `courier` split out of the order DTO; `contact` table added for feedback; `nutrient.in_stock` replaced by `nutrient.stock_quantity`; image link inverted to `nutrient_image.nutrient_id`)
**Type:** School project, team of 3, 2-week MVP
**Status:** Rev. 4.1. Canonical data model is the v2 pair `docs/nutrionista_data_model_v2.xml` (Redgate model) + `docs/nutrionista_data_model_v2.pdf` (rendered ERD). `docs/database/2_create.sql` is **out of date** versus v2 (it still describes the Rev. 4 9-table singular schema with `in_stock` + owned `nutrient.image_id`) — regenerating it from the v2 model is the first post-revision task. The Rev. 4 Redgate file `docs/madis/nutrionista_2026-05-14_09_09.xml` is **superseded** by the v2 model and should not be edited further. Backend exists as a Spring Boot skeleton only (`NutrionistaApplication` plus configuration); no controllers, entities, repositories, or auth endpoints are implemented yet. §6 still describes the intended minimal login but Rev. 4.1 introduces a real tension: v2 makes `cart.user_id` and `contact.user_id` NOT NULL, so those flows now require an authenticated user (see §6 for how the team will handle this without bringing back real sessions).

---

## 1. Project Overview

Nutrionista is a web-based **vitamin and supplement online store** that combines a product catalog with rich educational content. Each product is a nutrient (vitamin, mineral, supplement) and each product detail page doubles as an encyclopedia entry — describing:

1. What the nutrient is for (biological functions)
2. How the body absorbs it (mechanisms and influencing factors)
3. How it interacts with other nutrients
4. What deficiency symptoms it addresses

A logged-in visitor can browse the catalog, read nutrient information, add products to their server-side cart, and complete a checkout that captures billing details and a courier choice. There is **no admin login** — admin pages live at known URLs and are not access-controlled in the MVP. The public side does require login for cart use (because `cart.user_id` is NOT NULL in v2); this is treated as a usability tax, not a security boundary — see §6.

The project is built by a 3-person student team. The primary success criteria are:

- The end-to-end purchase flow works: browse → product detail → cart (server-persisted) → checkout (billing + courier) → confirmation.
- The educational content is preserved on each product page (functions, absorption, interactions, deficiencies — all modelled through the generalized `property` table).
- The codebase is organized and clearly understandable.
- The result is presentable in a class demo.

**Scope discipline.** The full UI mockup at `docs/nutrionista-mockup.html` shows additional features (vitamin quiz with personal recommendations, wishlist, bundles, blog, FAQ, reorder reminders, brand/goal filters, live chat). These are **out of scope for the MVP** — see §14. The `contact` table now in the schema covers the basic feedback form; everything else stays cut.

## 2. Constraints

- **Team size:** 3 students collaborating via GitHub.
- **Schema size:** 16 tables as defined in `docs/nutrionista_data_model_v2.xml` / `.pdf` (canonical DB model). The schema generalizes the original 12 educational tables into a `property` + `nutrient_property` pair; commerce is modelled across `order` / `order_item` / `cart` / `cart_item` / `billing` / `courier`; user-side feedback uses a `contact` table.
- **Deadline:** 2 weeks from spec approval. Scope cuts in §14 are non-negotiable inside this window.
- **Hosting:** Free tiers only — Render (backend + database) and Vercel (frontend).
- **Each student works on their own PC** but the deployed app is the demo target.

## 3. Stack

| Layer        | Technology                            | Hosting           |
| ------------ | ------------------------------------- | ----------------- |
| Frontend     | Vue 3 SPA (Options API) + Tailwind CSS + Axios + Pinia (cart + auth) + Vue Router | Vercel (free)     |
| Backend      | Java 21 + Spring Boot 4.0.6 + Spring Data JPA + Bean Validation + Springdoc OpenAPI 3.0.3 + Lombok + MapStruct 1.6.3 + p6spy 3.9.1 | Render (free)     |
| Build tool   | Gradle (wrapper checked in: `./gradlew bootRun`, `./gradlew build`) | n/a               |
| Database     | PostgreSQL                            | Render (free)     |
| DB workflow  | Manual init scripts in `docs/database/` (`1_reset_database.sql` → `2_create.sql` → `3_import.sql`). Flyway is **not yet adopted** — see §10. | Run manually on each laptop |

**Passwords:** BCrypt via `jBCrypt 0.4` (already on the classpath). The full login flow is **TBD** — see §6.

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
   │  - 16 tables (v2 model)      │
   │  - Seeded via init scripts   │
   └──────────────────────────────┘
```

**Key flows:**

- **Login (UI role-gating + cart owner):** Vue → `POST /api/login` with `{username, password}` → Spring Boot looks up `user.username`, BCrypt-checks the password against `user.password_hash` → returns `{userId, username, role}` (no token). Vue stores the response in a Pinia `authStore` and shows admin UI when `role === 'ADMIN'`. The backend has **no enforcement** beyond the login lookup — `/api/admin/**` and `/api/cart` stay openly accessible to any client willing to send a `userId` (see §6). The login is required *in the SPA* before adding to cart, because `cart.user_id` is NOT NULL.
- **Public browse:** Vue → `GET /api/nutrients` → Spring Boot → PostgreSQL → JSON. Same for `GET /api/nutrients/{id}` (product detail with full educational content joined from `property` and `nutrient_property`).
- **Cart (server-side):** On first add, Vue calls `POST /api/users/{userId}/cart` to lazily create the user's `cart` row, then `POST /api/carts/{cartId}/items` to add a `cart_item`. Subsequent reads use `GET /api/users/{userId}/cart`. The SPA mirrors the server-side cart into a Pinia store for fast reads but the source of truth is the DB — clearing browser storage no longer drops the cart.
- **Checkout:** Vue posts the shipping form (`first_name`, `last_name`, `address`, `courier_id`) to `POST /api/billings`, receives `billing_id`, then `POST /api/orders` with `{billing_id, collect_from_store, items: [{nutrientId, quantity}]}`. Backend creates one `order` row + N `order_item` rows in a single transaction, snapshots `order_item.price` from the current `nutrient.price`, computes `order_item.total_sum = price * quantity` and `order.total_sum = SUM(order_item.total_sum)`, sets `order.status = 'P'` (PENDING), deletes the source `cart_item` rows, and returns the new `order_id`. Vue navigates to `/confirmation/:id`.
- **Admin write:** Admin pages (`/admin/*` in the SPA, `/api/admin/**` in the API) are openly accessible — there is no login. Anyone who knows the URL can edit catalog data, change order status, or read contact submissions. This is an explicit MVP trade-off (see §6) and must be addressed before any real deployment beyond the demo.
- **Cold-start mitigation:** A free cron-job.org job pings `/actuator/health` every 14 minutes, keeping the Render free-tier backend warm.

## 5. Database Schema (16 tables — v2 model)

The canonical data model is the pair `docs/nutrionista_data_model_v2.xml` (Redgate source) + `docs/nutrionista_data_model_v2.pdf` (rendered ERD). `docs/database/2_create.sql` currently reflects the older Rev. 4 9-table schema and **must be regenerated** to match v2 — that's the first post-revision task (see §12). The SQL in this section is the v2 schema translated to plain Postgres DDL; the Redgate file is authoritative for column order, constraint IDs, and diagram layout.

Compared to the Rev. 4 schema, v2 keeps the generalized `property` + `nutrient_property` pair and the `color_code` interaction lookup, but adds the full commerce surface (`order`, `order_item`, `cart`, `cart_item`, `billing`, `courier`), introduces a `contact` table for feedback, and changes three things on `nutrient` / `nutrient_image`: stock becomes numeric, the image FK direction flips, and a nutrient can now have many images.

**Rev. 4.1 changes vs. Rev. 4:**

- **Cart now lives in the DB.** `cart (id, user_id)` + `cart_item (id, cart_id, nutrient_id, quantity)`. `cart.user_id` is NOT NULL, so a user must be logged in to add to cart (see §6 for how this is reconciled with "no real auth").
- **Commerce tables exist.** `order (id, billing_id, total_sum, status CHAR(1), collect_from_store BOOLEAN)` + `order_item (id, order_id, nutrient_id, price, quantity, total_sum)`. No more "TBD".
- **Order status is a `CHAR(1)` code**, not a string enum. The team picks the codes once in the seed script. Suggested: `P` = PENDING, `A` = PAID (anglicism of *Apaid*; the team can pick a different letter), `S` = SHIPPED, `C` = CANCELLED. The UI maps codes → labels on render.
- **Billing + courier split out of the order row.** `billing (id, first_name, last_name, address, courier_id)` holds the customer's shipping form; `courier (id, name, type, api_key, endpoint_url)` holds the configured carriers. `order.billing_id → billing.id` is NOT NULL; `billing.courier_id → courier.id` is nullable (free-text/pickup orders skip the carrier).
- **`nutrient.stock_quantity INT NOT NULL`** replaces `nutrient.in_stock BOOLEAN`. The catalog grid renders "in stock / out of stock" by `stock_quantity > 0`; admin edits the integer directly.
- **Image FK direction flipped.** `nutrient.image_id` is **gone**; `nutrient_image (id, nutrient_id, image_data)` has a NOT NULL `nutrient_id` back-pointer. A nutrient can now own **many** images. The product detail page picks the first (`MIN(id)`) or all of them — to be decided when the gallery UI is wired up.
- **`contact (id, user_id, first_name, last_name)`** is now in the schema for the basic feedback form. Like cart, it makes `user_id` NOT NULL — only logged-in users can submit feedback.
- **`order` has no direct `user_id` FK.** The model links order → billing only. Order history "my orders" therefore can't be implemented without an additional FK or a query that joins through `cart` (which is deleted at checkout). Treat order history as future work — see §14.
- **Bug carried forward from the v2 model:** `nutrient_property` has a CHECK constraint `nutrient_property_effect_ck` that references `effect_type IN ('ENHANCE','INHIBIT')`, but the `effect_type` column itself is **missing** from the table definition. The team must either (a) add `effect_type VARCHAR(10)` back to the column list when generating `2_create.sql`, or (b) drop the check. Recommended: (a) — the absorption-factor UI needs the column.

**Highlights:**

- **Generalized lookups.** `property` holds rows of every educational property (function / absorption method / absorption factor / deficiency symptom). The `type` column (`varchar(3)`) discriminates which kind of property each row is — e.g. `FN`, `AM`, `AF`, `DS`. The team will fix the exact codes in the seed script.
- **Generalized junction.** `nutrient_property` (id, nutrient_id, property_id, **effect_type**) links nutrients to any property. `effect_type` is constrained to `ENHANCE` / `INHIBIT` only — the row exists only when there's something to say (absence of a row = neutral).
- **Color-coded interactions.** `color_code` is the interaction-quality lookup — each row has a label (`GOOD`, `NEUTRAL`, `BAD`) plus the hex/CSS color the UI should render for that label. `nutrient_interaction` references `color_code` directly through `interaction_type_id`. The three labels match the mockup's `Hea` / `Neutraalne` / `Halb` user-facing wording.
- **Binary images, many per nutrient.** `nutrient_image.image_data BYTEA` stores the bytes; `nutrient_image.nutrient_id INT NOT NULL REFERENCES nutrient(id)` is the back-pointer. Deleting a nutrient cascades to its images.
- **`role` + `"user"` exist, but the login flow isn't wired yet.** §6 describes the intended minimal-login behaviour; neither the backend `AuthController` nor the frontend `authStore` exists today.
- **Courier is configurable, not hard-coded.** The `api_key` / `endpoint_url` columns suggest the team intended to plug into a real shipping provider's API; for the MVP a single seeded `courier` row ("Local pickup" or "Omniva") is enough.

### Tables (will become `docs/database/2_create.sql` after regeneration)

```sql
-- ─── Catalog (foundation) ──────────────────────────────────────────────────

-- 1. category
CREATE TABLE category (
  id          SERIAL PRIMARY KEY,
  name        VARCHAR(100) UNIQUE NOT NULL,
  description TEXT
);

-- 2. nutrient
CREATE TABLE nutrient (
  id             SERIAL PRIMARY KEY,
  name           VARCHAR(100) UNIQUE NOT NULL,
  description    VARCHAR(500),
  category_id    INTEGER NOT NULL REFERENCES category(id),
  price          NUMERIC(8,2) NOT NULL DEFAULT 0 CHECK (price >= 0),  -- € amount
  stock_quantity INTEGER NOT NULL,
  created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 3. nutrient_image  (many per nutrient — back-pointer FK)
CREATE TABLE nutrient_image (
  id          SERIAL PRIMARY KEY,
  nutrient_id INTEGER NOT NULL REFERENCES nutrient(id) ON DELETE CASCADE,
  image_data  BYTEA NOT NULL
);

-- 4. property  (generalized lookup for functions / absorption / factors / deficiencies)
CREATE TABLE property (
  id          SERIAL PRIMARY KEY,
  type        VARCHAR(3)  NOT NULL,   -- discriminator: FN | AM | AF | DS (exact codes finalised at seed time)
  name        VARCHAR(150) NOT NULL,
  description VARCHAR(150)
);

-- 5. nutrient_property  (generalized junction)
-- NOTE: the v2 XML omits the effect_type column but keeps a CHECK that references it.
-- The column is restored here so the constraint resolves and the absorption-factor UI works.
CREATE TABLE nutrient_property (
  id          SERIAL PRIMARY KEY,
  nutrient_id INTEGER NOT NULL REFERENCES nutrient(id) ON DELETE CASCADE,
  property_id INTEGER NOT NULL REFERENCES property(id),
  effect_type VARCHAR(10),
  CONSTRAINT nutrient_property_effect_ck CHECK (effect_type IN ('ENHANCE','INHIBIT'))
);

-- 6. color_code  (interaction-type lookup, includes the UI color)
CREATE TABLE color_code (
  id         SERIAL PRIMARY KEY,
  name       VARCHAR(10) UNIQUE NOT NULL,   -- GOOD | NEUTRAL | BAD
  color_code VARCHAR(10) NOT NULL           -- e.g. "#22c55e" or a Tailwind token
);

-- 7. nutrient_interaction  (directional A → B with an interaction type)
CREATE TABLE nutrient_interaction (
  id                  SERIAL PRIMARY KEY,
  nutrient_id         INTEGER NOT NULL REFERENCES nutrient(id) ON DELETE CASCADE,
  related_nutrient_id INTEGER NOT NULL REFERENCES nutrient(id) ON DELETE CASCADE,
  interaction_type_id INTEGER NOT NULL REFERENCES color_code(id),
  description         VARCHAR(200),
  CONSTRAINT nutrient_interaction_self_ck CHECK (nutrient_id <> related_nutrient_id)
);

-- ─── Identity ──────────────────────────────────────────────────────────────

-- 8. role
CREATE TABLE role (
  id   SERIAL PRIMARY KEY,
  name VARCHAR(10) UNIQUE NOT NULL   -- ADMIN | USER, seeded once
);

-- 9. "user"  (quoted because `user` is a reserved word in PostgreSQL)
CREATE TABLE "user" (
  id            SERIAL PRIMARY KEY,
  username      VARCHAR(50) UNIQUE NOT NULL,
  password_hash VARCHAR(60) NOT NULL,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  role_id       INTEGER NOT NULL REFERENCES role(id)
);

-- ─── Shipping & billing ────────────────────────────────────────────────────

-- 10. courier
CREATE TABLE courier (
  id           SERIAL PRIMARY KEY,
  name         VARCHAR(255) NOT NULL,
  type         CHAR(1) NOT NULL,           -- e.g. P = parcel-locker, H = home delivery, S = in-store (codes set at seed time)
  api_key      VARCHAR(255),
  endpoint_url VARCHAR(255)
);

-- 11. billing
CREATE TABLE billing (
  id         SERIAL PRIMARY KEY,
  first_name VARCHAR(255) NOT NULL,
  last_name  VARCHAR(255) NOT NULL,
  address    VARCHAR(255) NOT NULL,
  courier_id INTEGER REFERENCES courier(id)
);

-- ─── Commerce ──────────────────────────────────────────────────────────────

-- 12. cart  (per-user — must be logged in)
CREATE TABLE cart (
  id      SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES "user"(id) ON DELETE CASCADE
);

-- 13. cart_item
CREATE TABLE cart_item (
  id          SERIAL PRIMARY KEY,
  cart_id     INTEGER NOT NULL REFERENCES cart(id) ON DELETE CASCADE,
  nutrient_id INTEGER NOT NULL REFERENCES nutrient(id),
  quantity    INTEGER NOT NULL
);

-- 14. "order"  (quoted — `order` is a reserved word)
CREATE TABLE "order" (
  id                 SERIAL PRIMARY KEY,
  billing_id         INTEGER NOT NULL REFERENCES billing(id),
  total_sum          NUMERIC(8,2) NOT NULL,
  status             CHAR(1) NOT NULL,    -- P | A | S | C (codes set at seed time)
  collect_from_store BOOLEAN NOT NULL
);

-- 15. order_item  (line totals are denormalized — price * quantity stored as total_sum for audit)
CREATE TABLE order_item (
  id          SERIAL PRIMARY KEY,
  order_id    INTEGER NOT NULL REFERENCES "order"(id) ON DELETE CASCADE,
  nutrient_id INTEGER NOT NULL REFERENCES nutrient(id),
  price       NUMERIC(8,2) NOT NULL,  -- snapshot of nutrient.price at checkout
  quantity    INTEGER NOT NULL,
  total_sum   NUMERIC(8,2) NOT NULL   -- = price * quantity, computed in the service
);

-- ─── Feedback ──────────────────────────────────────────────────────────────

-- 16. contact  (user feedback form — minimal in v2)
CREATE TABLE contact (
  id         SERIAL PRIMARY KEY,
  user_id    INTEGER NOT NULL REFERENCES "user"(id),
  first_name VARCHAR(255) NOT NULL,
  last_name  VARCHAR(255) NOT NULL
);
```

### Schema notes

- **Property discrimination.** `property.type` is a 3-character code, NOT a CHECK-constrained enum. Pick the codes once (e.g. `FN`, `AM`, `AF`, `DS`) and document them in the seed script. Application code filters by `type` to render the right section of the product detail page.
- **`nutrient_property.effect_type`.** Only set for absorption-factor rows (`property.type='AF'`). For other property kinds the column stays `NULL` and the UI hides the field. The v2 XML's missing-column bug must be fixed when generating `2_create.sql` (see Rev. 4.1 changes above).
- **`nutrient_interaction` is directional** — `(A, B, BAD)` means "taking A together with B is bad for B". Inserting the inverse pair would make a different (possibly incorrect) claim, so admin UI must label the two dropdowns clearly.
- **`color_code` is what the dot panel reads.** The frontend's colored-dot component looks up the color via `interaction_type_id`. Putting the color in the DB row means the UI doesn't need a hard-coded mapping.
- **`nutrient_image.nutrient_id` is NOT NULL** — an image row can't exist without a nutrient. Cascade-delete is appropriate because the image is intrinsic to its nutrient.
- **`order.status` is `CHAR(1)`** — no DB-level CHECK constraint is enforced by v2, so the application layer must validate the code on every write. A follow-up migration could add `CHECK (status IN ('P','A','S','C'))` once the codes are agreed.
- **`order_item.total_sum` is denormalized.** The service must compute `price * quantity` and write it on insert; admin updates that change either column must rewrite `total_sum` in the same transaction.
- **No FK from `order` to `user`.** The model links order → billing only; the customer's identity lives in the `billing` row (first_name + last_name). A logged-in user's userId is *not* persisted on the order — so "my orders" listings are not implementable without an additional column, which is deferred to a post-MVP migration.
- **Cart deletion at checkout.** When `POST /api/orders` succeeds, the service deletes the source `cart_item` rows (and optionally the `cart` row). `cart_item.cart_id` is `ON DELETE CASCADE` so deleting the cart wipes the items.
- **`ON DELETE CASCADE`** is set on: `nutrient_interaction.*` FKs, `nutrient_property.nutrient_id`, `nutrient_image.nutrient_id`, `cart.user_id`, `cart_item.cart_id`, `order_item.order_id`. Other FKs stay restrictive (deleting a category / property / nutrient / billing / courier with references should fail loudly).
- **No timestamps on lookup, junction, or commerce tables.** Only `nutrient` and `"user"` have `created_at` — v2 carries this forward from Rev. 4. `order.created_at` would be useful for sorting in `/admin/orders` and is the most likely first addition in a future revision.

#### Explanatory: why a single generalized `property` table

The original spec defined four separate lookup tables (`functions`, `absorption_methods`, `absorption_factors`, `deficiency_symptoms`) plus four matching junctions. The schema collapses them into one `property` table + one `nutrient_property` junction. The trade-off:

| Aspect | Separate tables (old spec) | Single `property` (current) |
|---|---|---|
| Schema files | 4 lookup tables + 4 junctions | 1 lookup table + 1 junction |
| Admin CRUD | 4 admin screens | 1 admin screen with a `type` filter |
| Query for "all functions of nutrient X" | `JOIN nutrient_function` | `JOIN nutrient_property WHERE property.type='FN'` |
| Risk | Lots of near-identical boilerplate | A single misclassified `type` value contaminates the whole catalog |

Both designs work; the current choice trades a small ongoing query-filter overhead for a much smaller code surface in a 2-week sprint. The team agreed to live with the `type` column's discipline.

#### Explanatory: directional interactions

`nutrient_interaction` has two columns referencing `nutrient`:

- `nutrient_id` — the "actor"
- `related_nutrient_id` — the recipient
- `interaction_type_id` — what kind of interaction (FK to `color_code`)

A row reads like a sentence: **"`nutrient_id` is `interaction_type` with `related_nutrient_id`"**. Example: `(Vitamin C, Iron, GOOD)` = "Vitamin C is GOOD with Iron" (it helps iron absorption); `(Calcium, Iron, BAD)` = "Calcium is BAD with Iron" (it inhibits iron absorption). Swapping the two nutrient columns produces a different (and not necessarily correct) claim, so the admin form must label the dropdowns as **"Nutrient"** and **"Related to"** so the order is entered on purpose. `CHECK (nutrient_id <> related_nutrient_id)` is a backstop preventing rows like "Iron is GOOD with iron".

`color_code` carries the UI color directly (`color_code` column), so the dot panel renders by looking up `interaction_type_id → color_code.color_code`. No hard-coded mapping in the frontend.

#### Explanatory: timestamps only on `nutrient` and `"user"`

`nutrient` is the table admins edit most often (names, descriptions, prices, stock quantity), so `created_at` / `updated_at` earn their keep. `"user"` carries only `created_at` for account-audit purposes; passwords change so rarely that `updated_at` is overhead. Lookup tables (`category`, `property`, `color_code`, `role`, `courier`) are seeded once and don't need audit columns. The commerce tables (`order`, `order_item`, `cart`, `cart_item`, `billing`) lack timestamps in v2 — `order.created_at` is the most likely first addition in a future revision.

#### Explanatory: the order ↔ billing ↔ courier triangle

The v2 model splits the checkout form across three tables rather than fattening the `order` row:

- **`billing`** holds *who* the order is for and *where* it's going — `first_name`, `last_name`, `address`. One billing row per checkout submission. (Future revisions could deduplicate by user, but for the MVP each order gets its own billing row.)
- **`courier`** holds *how* the parcel gets there — seeded once with the carriers the team supports. The `api_key` + `endpoint_url` columns suggest an eventual integration with a real shipping provider (Omniva, Smartpost, DPD); for the MVP one row is enough.
- **`order`** holds the commerce state — `total_sum`, `status`, `collect_from_store` flag — and points at the billing row via `billing_id`.

The flow at checkout is therefore: insert one `billing` row → take its id → insert one `order` row with `billing_id` → insert N `order_item` rows. If `collect_from_store = true`, `billing.courier_id` is left NULL.

## 6. Authentication

**Status: TBD.** Passwords are stored as BCrypt hashes using `jBCrypt 0.4` (already on the backend classpath). The full login flow — endpoint shape, token vs. tokenless, server-side enforcement, role-gating semantics — is **deferred** and will be designed in a follow-up revision.

What's fixed today:

- **Password storage:** BCrypt via `jBCrypt 0.4`. Seeded passwords in `3_import.sql` are bcrypt hashes; new passwords go through `BCrypt.hashpw` on write and `BCrypt.checkpw` on verify.
- **`user` + `role` tables exist** in the v2 schema and are seeded with the team's admin accounts (`madis` / `kaili` / `rain` as `ADMIN`) plus at least one `USER`-role demo account.
- **`cart.user_id` and `contact.user_id` are NOT NULL** in v2 — these flows therefore *do* require some notion of "who's logged in" before they can be completed end-to-end. How that user identity is established (a client-supplied `userId`, a token, a session cookie, etc.) is part of the deferred design.

> **Cross-section follow-up.** Other parts of this spec still describe an earlier auth model (a UI-only role hint, a `POST /api/login` returning `{userId, username, role}`, a Pinia `authStore`, route guards keyed on `auth.isAdmin`, etc.). Specifically: §7 (`POST /api/login` in the API surface), §8 (`/login` route + auth store), §12 (the "Write the minimal-login backend" task), §13 (the "Log in as a regular user" demo step), and §14 ("Real authentication enforcement" out-of-scope row). These references are kept for context but should be re-read as **placeholders until §6 is finalized**.

## 7. API Surface (high level)

REST endpoints follow standard CRUD conventions. Detailed request/response shapes will be defined in the implementation plan.

**URI convention.** Even though tables are singular (`nutrient`, `category`, `color_code` …), collection URIs stay **plural** in line with common REST practice: `GET /api/nutrients`, `POST /api/categories`, etc. The plural in the URI refers to "the collection of nutrient resources", not the table name.

**All endpoints below are open — there is no security enforcement. `POST /api/login` exists for UI role-gating + cart/contact ownership only (see §6).**

**Auth (UI role-gating + ownership hint, see §6):**

```
POST   /api/login                        ← body: {username, password}; response: {userId, username, role}
                                            BCrypt-checks against "user".password_hash; returns 401 on
                                            mismatch. No token, no session — SPA uses the role to gate
                                            admin UI and the userId to own cart/contact rows.
```

**Public catalog:**

```
GET  /api/categories
GET  /api/categories/{id}
GET  /api/nutrients                      ← shop grid; supports ?category={id} filter
GET  /api/nutrients/{id}                 ← product detail page payload: nutrient + price + stock_quantity
                                            + properties (filtered by property.type: FN/AM/AF/DS) + interactions
GET  /api/nutrients/search?q={query}
GET  /api/nutrients/highlights           ← home page "Esiletõstetud Tooted" — the 4 newest in-stock nutrients
                                            (no `featured` column; selection is by `created_at DESC
                                            + stock_quantity > 0 LIMIT 4`)
GET  /api/color-codes                    ← interaction-type lookup (id, name, color_code)
GET  /api/couriers                       ← carrier dropdown for the checkout form (id, name, type)
GET  /api/nutrient-images/{id}           ← returns image_data bytes for a single nutrient_image row
GET  /api/nutrients/{id}/images          ← list image ids for a nutrient (since a nutrient can have many)
GET  /actuator/health                    ← keep-alive endpoint
```

**Cart (open — SPA passes the logged-in userId):**

```
GET    /api/users/{userId}/cart          ← returns the user's cart + items; lazily creates the cart row
                                            if none exists. Response shape:
                                            {id, userId, items: [{id, nutrientId, name, price, quantity}]}
POST   /api/carts/{cartId}/items         ← body: {nutrientId, quantity}; adds a cart_item row.
                                            If a row for that nutrient already exists, the quantity is
                                            incremented instead of inserting a duplicate.
PUT    /api/cart-items/{id}              ← body: {quantity}; update line quantity
DELETE /api/cart-items/{id}              ← remove one line
DELETE /api/carts/{cartId}/items         ← clear the cart (used at logout / after order placement)
```

**Checkout (open):**

```
POST   /api/billings                     ← body: {first_name, last_name, address, courier_id}; returns {id}
POST   /api/orders                       ← body: {billing_id, collect_from_store, cart_id}
                                            (server reads cart_item rows for cart_id, snapshots each
                                             nutrient.price into order_item.price, computes total_sum,
                                             inserts order + order_item rows, deletes cart_item rows,
                                             returns {orderId, total_sum, status})
GET    /api/orders/{id}                  ← order summary for the confirmation page (joins billing + items)
```

**Admin catalog (open — no server-side auth, UI-gated by `auth.isAdmin`, see §6):**

```
POST   /api/admin/nutrients
PUT    /api/admin/nutrients/{id}         ← edit name, description, category, price, stock_quantity
DELETE /api/admin/nutrients/{id}         ← cascades to nutrient_property + nutrient_interaction +
                                            nutrient_image rows (all those FKs are ON DELETE CASCADE)
POST   /api/admin/categories
PUT    /api/admin/categories/{id}
DELETE /api/admin/categories/{id}
POST   /api/admin/properties             ← create/edit/delete property rows; admin UI filters by type
PUT    /api/admin/properties/{id}
DELETE /api/admin/properties/{id}
POST   /api/admin/nutrient-properties    ← link a nutrient ↔ property (with effect_type for AF rows)
PUT    /api/admin/nutrient-properties/{id} ← edit an existing link (typically to change effect_type)
DELETE /api/admin/nutrient-properties/{id}
POST   /api/admin/nutrient-interactions  ← nutrient → related_nutrient + interaction_type (color_code id)
PUT    /api/admin/nutrient-interactions/{id}
DELETE /api/admin/nutrient-interactions/{id}
POST   /api/admin/color-codes            ← rarely edited; seeded once
PUT    /api/admin/color-codes/{id}
DELETE /api/admin/color-codes/{id}
POST   /api/admin/nutrient-images        ← upload a new image (multipart bytea + nutrient_id)
DELETE /api/admin/nutrient-images/{id}
POST   /api/admin/couriers               ← rarely edited after seed; included for completeness
PUT    /api/admin/couriers/{id}
DELETE /api/admin/couriers/{id}
```

**Admin commerce (open):**

```
GET    /api/admin/orders                 ← list all orders, supports ?status= filter (P|A|S|C)
GET    /api/admin/orders/{id}            ← single order detail (with billing + items joined)
PUT    /api/admin/orders/{id}/status     ← body: {status: 'P'|'A'|'S'|'C'} (CHAR(1) codes — see §5)
GET    /api/admin/billings/{id}          ← single billing row (admin can correct address mistakes)
PUT    /api/admin/billings/{id}
```

**Feedback (contact form):**

```
POST   /api/contacts                     ← body: {userId, first_name, last_name}; inserts a contact row.
                                            (The v2 schema doesn't carry the message body itself; the team
                                             must either add a `message TEXT` column in a follow-up
                                             revision or accept that the form only captures who reached
                                             out, not what they said.)
GET    /api/admin/contacts               ← list submissions for the admin inbox
```

CORS: Spring Boot is configured to allow requests from `http://localhost:5173` (dev) and the Vercel frontend domain (prod). Update `CorsConfig` to include the deployed Vercel URL before the demo.

### 7.1 Why the cart is now server-side

The v2 data model puts the cart in the DB (`cart` + `cart_item`) and ties it to a user (`cart.user_id` NOT NULL). The Rev. 4 plan of keeping cart state purely in the browser is no longer available without diverging from the canonical model. The new flow is: log in → SPA fetches `/api/users/{userId}/cart` (creating the row if needed) → add/remove/update items via `/api/carts/{cartId}/items` and `/api/cart-items/{id}`. The Pinia `cartStore` keeps a hot copy for fast reads but the source of truth is PostgreSQL.

**Trade-offs of the v2 server-side cart:**

- **Cart follows the user across devices.** Logging in on a different laptop shows the same items. Good for the demo, even if it costs us a login step.
- **Login is now required to add to cart.** A visitor who lands on the shop and hits "Lisa ostukorvi" gets bounced to `/login`. This raises the cost of the public catalog flow — the seed must include at least one non-admin demo account so the public path is presentable.
- **More moving parts.** Adding an item now makes an HTTP call instead of mutating a local store. The SPA needs loading / error UI for every cart mutation, and a Render cold start delays the first add by ~30–60s if the backend is asleep. The keep-alive ping (§4) mitigates this.
- **Schema clarity.** The order shape is cleaner — checkout passes `cart_id` and the server materialises `order` + `order_item` rows from the existing `cart_item` rows, instead of trusting a client-built JSON cart.

### 7.2 API Documentation (Swagger / OpenAPI)

The backend uses **springdoc-openapi** to auto-generate interactive API documentation from the Spring Boot controllers.

- Dependency added to `backend/build.gradle`:
  ```groovy
  implementation 'org.springdoc:springdoc-openapi-starter-webmvc-ui:3.0.3'
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
| `/product/:id`       | **Toote leht** — encyclopedia content + price + Add to cart. "Lisa ostukorvi" calls `POST /api/carts/{cartId}/items`; if the user is not logged in, the SPA redirects to `/login?next=/product/:id`. Interactions shown as colored dots; the color comes from `color_code.color_code` for each `interaction_type_id`. |
| `/cart`              | **Ostukorv** — cart contents fetched from `GET /api/users/{userId}/cart`, line-quantity edits via `PUT /api/cart-items/{id}`, remove via `DELETE`. Total computed client-side from line prices for fast UX. "Mine maksma" button → `/checkout`. |
| `/checkout`          | **Kassa** — shipping form (first name, last name, address, courier dropdown from `GET /api/couriers`, "Collect from store" checkbox). Submits `POST /api/billings` then `POST /api/orders` with the returned `billing_id` and the current `cart_id`. |
| `/confirmation/:id`  | **Tellimus kinnitatud** — fetches `GET /api/orders/{id}` and shows the order summary (items, total, billing address, status). |
| `/contact`           | **Kontakt** — simple feedback form (first name, last name) that posts to `/api/contacts` for the logged-in user. Requires login (same redirect-to-`/login` pattern as cart). |
| `/login`             | **Sisselogimine** — username + password form; submits to `POST /api/login`. On success, stores `{userId, username, role}` in the Pinia `authStore` and redirects to `?next=...` if present, otherwise `/admin` for `ADMIN` or `/` for `USER`. On 401, shows an "Invalid credentials" message. |

There is **no `/register` route** — the `user` table is seeded once via the init scripts (or a future `Vn__seed_users.sql` migration), not opened to the public.

### Auth store (Pinia)

An `authStore` keyed on `{userId, username, role}` (never a token):

- `login(username, password)` posts to `/api/login`, stores the response on success.
- `logout()` clears the store (no backend call — there's no session to invalidate).
- Computed `isAdmin` returns `role === 'ADMIN'`.
- Persisted to `localStorage` so the role survives page refreshes.

The Axios instance in `frontend/src/api.js` does **not** send an `Authorization` header — there is no token to send. The NavBar admin dropdown and `/admin/*` route guards (`meta: { requiresAdmin: true }`) both check `auth.isAdmin` client-side.

### Admin routes (gated client-side by `auth.isAdmin`)

| Route                       | Purpose                                                |
| --------------------------- | ------------------------------------------------------ |
| `/admin`                    | Dashboard with links to catalog CRUD pages (route guard checks `auth.isAdmin`) |
| `/admin/nutrients`          | List + create + edit + delete nutrients (name, description, category, price, stock_quantity, image upload — supports many images per nutrient) |
| `/admin/categories`         | List + create + edit + delete categories |
| `/admin/properties`         | List + create + edit + delete educational properties (with type filter: FN/AM/AF/DS) |
| `/admin/nutrient-properties`| Link/unlink properties to nutrients; set `effect_type` for AF rows |
| `/admin/nutrient-interactions` | Create/edit `nutrient_interaction` rows (Nutrient → Related to → color_code type, description) |
| `/admin/color-codes`        | Edit interaction-type labels + colors (rarely used after seed) |
| `/admin/couriers`           | Edit courier rows (name, type code, api_key, endpoint_url). Rarely used after seed. |
| `/admin/orders`             | List orders + change status (`P` → `A` → `S`; or `C` to cancel). Shows joined billing + items per row. |
| `/admin/contacts`           | List feedback submissions from the `contact` table. |

The route guards `meta: { requiresAdmin: true }` check `auth.isAdmin` and redirect to `/login` if the user isn't an admin. **This is purely client-side** — anyone bypassing the SPA (typing `/api/admin/**` directly into `curl`) can still write. See §6.

### UI input pattern for fixed-value fields

Fixed-value fields use Vue `<select>` dropdowns rather than free-text inputs:

- `effect_type` in `nutrient_property` → dropdown with two options: `ENHANCE` / `INHIBIT`. The dropdown only appears when the linked property's `type` is `AF` (absorption factor); for other property kinds the field is hidden and the column is left `NULL`.
- `interaction_type_id` in `nutrient_interaction` → dropdown populated from `GET /api/color-codes`.
- `property.type` → dropdown of the agreed codes (FN/AM/AF/DS), set at row creation time.
- `order.status` (admin-only) → dropdown showing labels `PENDING` / `PAID` / `SHIPPED` / `CANCELLED`, persisting the `P` / `A` / `S` / `C` code. The mapping lives in a single `frontend/src/lookups/orderStatus.js` constant so the labels and codes stay in lockstep.
- `courier_id` in the checkout billing form → dropdown populated from `GET /api/couriers`.
- `courier.type` (admin form) → dropdown of the agreed CHAR(1) codes (set at seed time, e.g. `P` parcel-locker / `H` home / `S` in-store).

This eliminates typo and casing inconsistencies at the UI level. The DB `CHECK` constraints (where present) are defense in depth.

### Cart state (Pinia)

A single `cartStore` that mirrors the server-side cart:

- `cartId: number | null` — set after the first fetch / lazy-create.
- `items: { id, nutrientId, name, price, imageUrl, quantity }[]` — `id` is the `cart_item.id`, needed for `PUT` / `DELETE`.
- `fetch(userId)` — `GET /api/users/{userId}/cart`, populates the store.
- `addItem(nutrient)` — `POST /api/carts/{cartId}/items` then re-fetch (or merge the response).
- `updateQuantity(itemId, qty)` — `PUT /api/cart-items/{id}`.
- `removeItem(itemId)` — `DELETE /api/cart-items/{id}`.
- `clear()` — `DELETE /api/carts/{cartId}/items`; also called on logout.
- Computed `totalAmount` — summed locally from `items[].price * items[].quantity`.

The store **does not** persist to `localStorage` in Rev. 4.1 — the source of truth is the DB. The only thing kept in `localStorage` is the auth store, so on page reload the SPA can immediately re-fetch the cart for the known `userId`.

## 9. Repository Structure

**GitHub repository:** [`github.com/madmadis/nutrionista`](https://github.com/madmadis/nutrionista). Single monorepo with two top-level project folders.

### Actual layout (Rev. 4.1)

```
nutrionista/
├── backend/
│   ├── build.gradle
│   ├── settings.gradle
│   ├── gradlew, gradlew.bat, gradle/wrapper/
│   └── src/main/
│       ├── java/ee/nutrionista/
│       │   ├── NutrionistaApplication.java
│       │   ├── controller/                   ← REST controllers, one sub-package per resource
│       │   │   └── <resource>/               ← e.g. auth/, nutrient/, category/
│       │   │       ├── dto/                  ← request + response DTOs
│       │   │       └── SomeController.java
│       │   ├── infrastructure/               ← global error handling
│       │   │   ├── error/                    ← ApiError.java, ErrorResponse.java
│       │   │   ├── exception/                ← custom exception classes
│       │   │   └── RestExceptionHandler.java
│       │   ├── persistence/                  ← JPA entities + repositories, one sub-package per resource
│       │   │   └── <resource>/               ← e.g. role/, user/, nutrient/
│       │   │       ├── Entity.java
│       │   │       ├── EntityMapper.java
│       │   │       └── EntityRepository.java
│       │   └── service/                      ← business logic
│       └── resources/
│           ├── application.properties
│           └── spy.properties                ← p6spy SQL logging config
├── frontend/
│   ├── package.json
│   ├── vite.config.js
│   ├── tailwind.config.js, postcss.config.js
│   └── src/
│       ├── api.js
│       ├── main.js, App.vue
│       ├── components/   (NavBar, FooterBar)
│       ├── router/index.js
│       ├── stores/       (auth.js, cart.js)
│       ├── views/        (HomeView, ShopView, ProductDetailView, … see §8)
│       └── assets/main.css
└── docs/
    ├── database/
    │   ├── 1_reset_database.sql
    │   ├── 2_create.sql                      ← Rev. 4 9-table schema; needs regeneration to match v2
    │   └── 3_import.sql                      ← seed data (currently empty)
    ├── 2026-05-06-nutrionista-design_REV4.1.md       ← this file
    ├── nutrionista_data_model_v2.xml                 ← Redgate DB model — CANONICAL (Rev. 4.1)
    ├── nutrionista_data_model_v2.pdf                 ← rendered ERD for the v2 model
    ├── Nutrionista balsamiq.pdf                      ← Balsamiq source export
    ├── vue-komponendi-struktuur.md                   ← Vue component conventions (Estonian)
    └── madis/
        ├── nutrionista-mockup.html                   ← Balsamiq HTML export
        ├── Nutrionista balsamiq-analysis.md
        ├── Nutrionista balsamiq-navigation.md
        └── nutrionista_2026-05-14_09_09.xml          ← Rev. 4 Redgate model — SUPERSEDED by v2
```

- **Java base package:** `ee.nutrionista`
- **Gradle settings:** `rootProject.name = 'backend'`, `group = 'ee'`, `version = '0.0.1-SNAPSHOT'`
- **Run locally:** `./gradlew bootRun` (or the IDE Run button on `NutrionistaApplication`)
- **Build a fat jar:** `./gradlew build` → `backend/build/libs/backend-0.0.1-SNAPSHOT.jar`

### Branching strategy

```
main (default, deployable)
  ├── design-docs                        ← documentation work
  ├── feature/schema-v2                  ← regenerate 2_create.sql from v2 (16 tables, fix effect_type bug)
  ├── feature/cart-and-checkout          ← server-side cart endpoints + checkout flow (billing + courier)
  ├── feature/properties-schema          ← property + nutrient_property + nutrient_interaction CRUD
  └── feature/admin-pages                ← admin CRUD UI (catalog, orders, contacts, couriers)
```

- `main` — what gets deployed. PRs into `main` after at least one teammate review.
- `feature/<name>` — short-lived; one branch per task; merged via PR.
- The spec previously referenced a `dev`/`front` integration branch. The team has been working directly off `main` so far; if/when integration churn justifies it, introduce `dev` and update this section. Until then, branch off `main`, PR into `main`.

PR title format: `[area] description` — e.g. `[backend] orders endpoint`, `[frontend] interaction-dots component`.

## 10. Database Schema & Seeding

### Current workflow (Rev. 4.1): manual init scripts (v2 regeneration pending)

The current setup is **deliberately simple** — three SQL scripts in `docs/database/` that each teammate runs by hand against their local PostgreSQL when the schema changes:

```
docs/database/
├── 1_reset_database.sql   ← DROP SCHEMA nutrionista CASCADE; CREATE SCHEMA nutrionista; grants
├── 2_create.sql           ← target: all 16 tables + FKs + CHECKs from v2 (currently the Rev. 4 schema)
└── 3_import.sql           ← seed data — currently empty, to be filled in
```

The Rev. 4.1 first-task list (§12) calls for regenerating `2_create.sql` from `docs/nutrionista_data_model_v2.xml`. Until that's done, the SQL above does **not** match the spec — teammates running it locally will get the 9-table Rev. 4 schema, not the v2 16-table one.

To (re)build a local database:

```bash
psql -U postgres -f docs/database/1_reset_database.sql
psql -U postgres -f docs/database/2_create.sql
psql -U postgres -f docs/database/3_import.sql
./gradlew bootRun
```

`backend/src/main/resources/application.properties` is set to:

- `spring.jpa.hibernate.ddl-auto=none` — Hibernate never touches the schema.
- `spring.sql.init.mode=always` — Spring Boot's built-in init reads `schema.sql` / `data.sql` from the classpath if present (we don't currently ship either, so this is a no-op safety net).
- `spring.datasource.url=jdbc:p6spy:postgresql://localhost/postgres` — JDBC traffic goes through **p6spy** so logged SQL has parameter values inlined (handy for debugging). The "normal" Postgres driver line is kept commented underneath in case you want to bypass p6spy.

**Each teammate runs PostgreSQL locally — there is no H2 profile.** Dev and prod use the same database engine so `bytea` image storage and PostgreSQL-specific SQL behave identically in both environments.

### Planned: switch to Flyway

The manual-script workflow works, but only because the schema is small and the team is three people in close communication. As the schema grows and people work in parallel branches, the standard answer is **Flyway** — versioned, append-only migration files run automatically on app startup. The rest of this section explains what that would look like; it's the direction we'll move once the catalog code is in place and schema churn slows down.

### Explanatory: what is Flyway and why we'll move to it

#### The problem migrations solve

The 3 of us each have our own PostgreSQL running on our own laptop. We all need:

- The same 16 tables (per the v2 model)
- The same columns and constraints
- The same seed data

Without a tool to manage this, schema changes happen like:

1. Madis writes the SQL for a new table, runs it on his PC.
2. Madis pastes the SQL in Discord; Kaili runs it on her PC.
3. Rain misses the message. His database doesn't have the table.
4. A week later, Madis adds a column to that table. Sends new SQL. Some apply it, some don't, some apply it twice and get errors, someone has a typo.
5. All three databases drift apart. Code that runs on Madis's machine breaks on Rain's. Hours are wasted figuring out why.

This is called **schema drift**, and it is the most common source of "but it works on my machine" bugs in team projects. Today we work around it by all running the same three SQL files; once changes get less coordinated, we'll switch to Flyway.

#### What a migration is

A **migration** is just a single SQL file in the repo that represents one step of database change. Example:

```sql
-- V1__create_category.sql
CREATE TABLE category (
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
V1__create_category.sql              ← runs first
V2__create_nutrient.sql              ← creates nutrient (no image_id column in v2)
V3__create_nutrient_image.sql        ← back-pointer FK references nutrient.id
V4__create_property.sql
V5__create_nutrient_property.sql     ← includes effect_type column (fixes v2 XML bug)
V6__create_color_code.sql
V7__create_nutrient_interaction.sql
V8__create_role.sql
V9__create_user.sql
V10__create_courier.sql
V11__create_billing.sql              ← references courier
V12__create_cart.sql                 ← references "user"
V13__create_cart_item.sql            ← references cart + nutrient
V14__create_order.sql                ← references billing
V15__create_order_item.sql           ← references order + nutrient
V16__create_contact.sql              ← references "user"
V100__seed_data.sql                  ← runs after all schema is in place
```

The number determines run order. The name after `__` is for humans. We use `V100` for the seed data so it's well after the schema files; the exact number doesn't matter as long as it's higher than the last schema migration.

#### The "never edit a committed migration" rule

Once a migration file has been merged into `main`, it must **never be modified**. If a change is needed, create a new migration file with a new version number.

The reason: Flyway records a checksum of every applied migration. If a teammate has already applied `V1` and someone else later edits `V1`, Flyway will refuse to start the app — it sees that the file no longer matches what was originally applied.

The correct way to make a change is therefore always: **add a new `V<n>__...` file** (e.g., `V14__rename_category_column.sql`).

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

The team is three students — **Rain**, **Kaili**, and **Madis** — collaborating via [`github.com/madmadis/nutrionista`](https://github.com/madmadis/nutrionista). **There are no pre-assigned task owners.** Whoever has time picks up the next item on the punch list; everyone is expected to work across the stack as needed. Standups (in whatever form the team uses) decide who takes what.

### Work to do (no specific owner — pick what's free)

The remaining work, grouped by area:

**Schema alignment (do this first — everything else depends on it)**
- Regenerate `docs/database/2_create.sql` from `docs/nutrionista_data_model_v2.xml`. Use Redgate's "Generate Script" feature, or hand-translate; the SQL block in §5 of this spec is the reference. Add the missing `effect_type VARCHAR(10)` column on `nutrient_property` so the `nutrient_property_effect_ck` constraint resolves.
- Pick and document the agreed CHAR(1) codes for `order.status` (suggested: `P` PENDING, `A` PAID, `S` SHIPPED, `C` CANCELLED) and `courier.type` (suggested: `P` parcel-locker, `H` home, `S` in-store). Drop these into §5 and §8.
- Fill `3_import.sql`: `role` rows (`ADMIN`, `USER`), `color_code` rows (`GOOD` = `#22c55e`, `NEUTRAL` = `#eab308`, `BAD` = `#ef4444`), `property.type` codes (FN/AM/AF/DS), at least one seeded `courier`, the team's admin users, and at least one regular `USER` for demoing the cart flow.

**Foundation cleanup**
- **DONE (Rev. 4)** — Backend is in the target layout: `backend/src/main/java/ee/nutrionista/`. The earlier `backend/category/src/demo/` nesting is gone.
- **DONE (Rev. 4)** — Java base package is `ee.nutrionista`. Gradle: `group=ee`, `rootProject.name=backend`.
- **DONE (Rev. 4)** — Switched build tool from Maven to Gradle with the wrapper checked in.
- Write the minimal-login backend: `AuthController` + `AuthService` + `POST /api/login` returning `{userId, username, role}`. `jbcrypt` on the classpath to verify seeded hashes.
- Delete the cut features' frontend: `BlogView`, `AdminBlogView`, `AdminFaqView`, `QuizView`, `WishlistView`, `OrderHistoryView`, `ProfileView`, plus their router entries in `frontend/src/router/index.js`. `FaqView` stays as a static page (content typed in code, no DB). `ContactView` stays — feedback is now in scope (see "Feedback" below).
- Write the frontend auth: `LoginView` posts to `POST /api/login`; `stores/auth.js` holds `{userId, username, role}`; `api.js` does not send an Authorization header. `meta: { requiresAdmin: true }` route guards check `role === 'ADMIN'` client-side.
- Clean up: garbage files in `frontend/` (`a.price`, `b.price`, `n.category.id`, `{`), commit a top-level `.gitignore` covering `.idea/` and `node_modules/`, fix `frontend/README.md` reference to `src/services/`.
- Resolve `frontend/package.json` duplicates if they ever come back. Cross-check `vite ^8.0.3` and `eslint ^10.1.0` pins — they're suspiciously high; if `npm install` fails, drop to the latest published versions.
- Retire / archive the Rev. 4 Redgate file `docs/madis/nutrionista_2026-05-14_09_09.xml`; the v2 model is canonical.

**Backend catalog**
- Move `docs/database/{1_reset_database, 2_create, 3_import}.sql` into a workflow the whole team uses consistently — either commit to manual psql runs or adopt Flyway as described in §10.
- Entities + repositories for the 16 tables: `Category`, `Nutrient`, `NutrientImage`, `Property`, `NutrientProperty`, `ColorCode`, `NutrientInteraction`, `Role`, `User`, `Courier`, `Billing`, `Cart`, `CartItem`, `Order` (entity name `OrderEntity` because `Order` is a JPA-reserved word in some setups), `OrderItem`, `Contact`. Java type names stay PascalCase + singular.
- DTOs + MapStruct mappers (MapStruct 1.6.3 is already on the classpath; `@Mapper(componentModel="spring")`).
- Public catalog endpoints (see §7): `/api/categories`, `/api/nutrients` (with `?category=`, `/search`, `/highlights`, `/{id}`, `/{id}/images`), `/api/color-codes`, `/api/couriers`, `/api/nutrient-images/{id}`.
- Admin catalog endpoints (see §7): nutrients / categories / properties / nutrient-properties / nutrient-interactions / color-codes / nutrient-images / couriers CRUD.
- Swagger UI verified at `/swagger-ui.html` (Springdoc 3.0.3 is on the classpath), CORS updated to include the Vercel domain.

**Commerce (cart + checkout) — modelled in v2; needs to be built**
- Cart endpoints: `GET /api/users/{userId}/cart` (lazy-create), `POST /api/carts/{cartId}/items`, `PUT /api/cart-items/{id}`, `DELETE /api/cart-items/{id}`, `DELETE /api/carts/{cartId}/items`.
- Billing endpoint: `POST /api/billings` (returns `{id}` for the order body).
- Order endpoint: `POST /api/orders` — single transaction: validate cart contents, snapshot `nutrient.price` into `order_item.price`, compute `order_item.total_sum` and `order.total_sum`, set `status='P'`, delete the source `cart_item` rows. Return `{orderId, total_sum, status}`.
- Admin order endpoints: `GET /api/admin/orders` (with `?status=` filter), `GET /api/admin/orders/{id}` (with billing + items joined), `PUT /api/admin/orders/{id}/status`.
- Document the JSON body shapes in §7 so the frontend checkout form lines up — done above.

**Feedback (contact form)**
- `POST /api/contacts` + `GET /api/admin/contacts`. Decide whether to add a `message TEXT` column in a follow-up migration; the v2 schema as-is captures only `user_id`, `first_name`, `last_name`.
- Frontend `ContactView` posts to `/api/contacts` for the logged-in user; admin `AdminContactsView` lists submissions.

**Frontend**
- Cart store (Pinia): mirrors the server-side cart per §8 — `fetch / addItem / updateQuantity / removeItem / clear` all hit `/api/cart...`.
- Public pages on live data: Home highlights grid (4 newest with `stock_quantity > 0`), Shop grid + category filter, ProductDetail rendering the educational properties + colored-dot interactions panel + (multiple) images from `/api/nutrients/{id}/images`.
- Checkout page: two-step submit — `POST /api/billings` then `POST /api/orders` with the returned `billing_id` and the current `cart_id`. Then navigate to `/confirmation/:id`.
- Admin pages: Nutrients / Categories / Properties / Nutrient-properties / Interactions / Color codes / Couriers / Orders / Contacts.
- Status code lookup: `frontend/src/lookups/orderStatus.js` mapping `P`/`A`/`S`/`C` ↔ labels.
- Tailwind tokens: replace inline `bg-[#e6007a]` hex (currently in `NavBar.vue`, `FooterBar.vue`, etc.) with named tokens in `tailwind.config.js`.
- Component conventions (Options API only, `event-` event prefix, axios via `this.$axios`, data loading in `beforeMount`) are documented in `frontend/CLAUDE.md` and `docs/vue-komponendi-struktuur.md`.

**Deployment**
- Render web service for the backend, Render Postgres, Vercel for the frontend.
- cron-job.org keep-alive ping every 14 minutes to `/actuator/health`.
- End-to-end smoke test on the deployed URLs before the demo.

### Suggested 14-day rhythm (no person tags — claim what's free at standup)

```
Day 1-2   Schema alignment: regenerate 2_create.sql, fix effect_type bug, seed lookups
Day 3-5   Backend catalog (entities, repos, public endpoints) + Frontend public pages
Day 6-8   Cart + checkout (backend endpoints, frontend store, checkout/confirmation pages)
Day 9-10  Admin pages (catalog CRUD, orders, contacts) + feedback form wiring
Day 11    Deployment + end-to-end smoke test
Day 12-13 Polish, bug fixes, demo rehearsal — no new features
Day 14    Demo
```

### Pair points (these always need a quick chat before someone starts)

- **Order status codes** (before commerce work begins): confirm `P`/`A`/`S`/`C` (or other letters) so the backend service, the admin UI dropdown, and the seed all agree.
- **Cart-to-order conversion semantics** (before checkout work begins): confirm that `POST /api/orders` deletes the source `cart_item` rows (and optionally the `cart` row) inside the same transaction. The frontend `cartStore` must refetch after.
- **Interaction-dots data** (before the dot panel work begins): the JSON shape returned by `GET /api/nutrients/{id}` for interactions must match what `<InteractionDot>` consumes. `color_code.color_code` should arrive on the client without a hardcoded mapping.
- **Property type codes** (before `3_import.sql` is filled in): the team picks the values for `property.type` (suggested: `FN`/`AM`/`AF`/`DS`) and writes them down here once decided.
- **`contact.message` column** (before the feedback form is built): decide whether to add `message TEXT` in a v2.1 migration or accept the truncated schema.

### Branch strategy reminder (from §9)

All work on feature branches off `main`, merged via PR with one teammate review. PR title format: `[area] description`, e.g. `[backend] orders endpoint`, `[frontend] interaction dots`.

## 13. Demo Plan

> **Status: on hold.** Project completion is not yet certain; revisit this section once the MVP is built. The flow below assumes the v2 schema is live and the cart + checkout endpoints work end-to-end.

- The application is deployed on Render (backend + Postgres) + Vercel (frontend); the demo URL is the Vercel domain.
- The backend is kept warm by the cron-job.org keep-alive ping, so requests respond quickly during the presentation.
- A seeded `USER`-role demo account is used for the public flow (cart requires login in v2); the admin accounts (`madis`, `kaili`, `rain`) are used for the admin flow.

### Demo flow (the critical path that must work)

1. **Browse.** Open the home page; show the 4 newest in-stock nutrients ("Esiletõstetud Tooted"). Click "Tooted" → product grid; filter by category.
2. **Read.** Click a product (e.g., "Iron"). Show the full educational content sourced from `property` (functions, absorption methods, absorption factors with enhance/inhibit) and **the colored-dot interactions panel** (Vitamin C 🟢 Hea, Magnesium 🟡 Neutraalne, Calcium 🔴 Halb) sourced from `nutrient_interaction` + `color_code` — proving that this is more than a generic store.
3. **Log in as a regular user.** Click "Sisselogimine", enter the seeded demo user, click submit. The auth pill in the NavBar shows the username.
4. **Add to cart.** From the detail page, click "Lisa ostukorvi" → `POST /api/carts/{cartId}/items`. Click another product, add it. Open the cart (Ostukorv) — items load from `GET /api/users/{userId}/cart`. Adjust a quantity (`PUT /api/cart-items/{id}`). Total updates live.
5. **Checkout.** Click "Mine maksma". Fill the shipping form (first name, last name, address, courier dropdown, "collect from store" checkbox). Submit. The SPA posts `/api/billings`, then `/api/orders` with the returned `billing_id` and the current `cart_id`. Confirmation page shows the order number, items, total, and the billing/courier chosen.
6. **Admin.** Open a new tab, log in as Madis. Open `/admin/nutrients`. Edit Iron's price or `stock_quantity`, save. Open `/admin/orders`, find the order just placed, change status `P` (PENDING) → `A` (PAID). Open `/admin/contacts` to show the feedback inbox.
7. **Verify.** Reload the public product page → new price visible. The flow is end-to-end.
8. **Swagger.** Open `/swagger-ui.html`. Show the API surface (catalog, cart, orders, billing, admin). Run a "Try it out" on `GET /api/nutrients/highlights` → live JSON response. Demonstrates that the backend is real, documented, and inspectable.

### What to say, not show

If anyone in Q&A asks **"how is the admin section protected?"**, answer honestly: it isn't, in the MVP. The login is purely a UI hint plus a row-ownership anchor for the `cart` / `contact` tables. Explain that re-introducing real auth is the obvious follow-up (the `user` table is already in place and the FKs from `cart` / `contact` are ready to be enforced server-side), but the team chose to spend the two weeks on the catalog depth and commerce flow rather than a security model that can't be meaningfully reviewed live.

If the **vitamin quiz**, **personalized recommendations**, **wishlist**, **order history page**, or **product bundles** come up: acknowledge them as part of the longer-term vision (visible in the Balsamiq mockup) and explain that the team prioritized a working end-to-end commerce flow over breadth for the 2-week MVP. The schema and architecture are designed to extend for those features without breaking changes — though order history specifically needs an `order.user_id` (or equivalent) migration before it's implementable.

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
| **Wishlist (Soovikorv)** | Adds 1 table + 2 endpoints + 1 page for a feature that doesn't change the demo's wow factor. |
| **Product bundles (Tootekomplektid)** | Requires `bundles` + `bundle_products` tables and bundle detail pages. Not in the v2 schema. |
| **Order history page (Tellimuste ajalugu)** | Requires a per-user "my orders" listing. The v2 `order` table has no `user_id` FK — order history needs a v2.1 migration before it's implementable. |
| **Reorder reminders** | Requires scheduled job + reminder table + email/notification dispatch — fully separate subsystem. |
| **Brand filter, Goal filter** in the shop | Requires `brands` + `product_goals` tables and many-to-many joins. Category filter alone is enough for the demo. |
| **Blog (Blogi/Artiklid)** | Cut entirely from the data model. The frontend `/blog` route and `BlogView`/`AdminBlogView` still exist and need to be deleted in the §12 foundation cleanup. |
| **FAQ (KKK)** | Cut from the data model. The frontend `/admin/faq` route and `AdminFaqView` still exist and need to be deleted in the §12 foundation cleanup. A static `FaqView` (content typed in code, no DB) is acceptable as a Day 12–13 stretch goal. |
| **Live chat** | Already labeled "tulevikus" (in the future) in the mockup. Cut. |
| **Real payments** | The checkout collects shipping info only — no card capture, no payment provider. |
| **Real authentication enforcement** | See §6. The `user` / `role` tables and the login endpoint exist; the SPA uses them for role-gating and cart ownership. The backend does **not** verify the supplied `userId`. |

### Back in scope in Rev. 4.1 (modelled in v2, was cut in Rev. 4)

| Feature | Notes |
|---|---|
| **Contact / feedback form (Tagasiside & Kontakt)** | `contact (id, user_id, first_name, last_name)` exists in v2. Frontend `ContactView` + `POST /api/contacts` + admin inbox. The schema doesn't carry the message body yet — see §12 pair points. |
| **Server-side cart** | `cart` + `cart_item` exist in v2; replaces the Rev. 4 browser-only design. |
| **Multiple images per nutrient** | v2's back-pointer FK makes this trivial; UI may render only the first image for the MVP and ship the gallery later. |
| **Configurable couriers** | `courier` table with `api_key` / `endpoint_url` enables a future real shipping integration. The MVP seeds one or two rows. |

### Cut from the original encyclopedia spec

| Feature | Reason for cut |
|---|---|
| **Foods + food-nutrient amounts** | Doubles content authoring work. |
| **Recommended daily intake** | Not visible on the e-commerce product detail page in the current mockup. |
| **Body systems and academic source citations** | Out of scope for the commerce focus. |
| **Separate per-domain lookup tables** (functions, absorption_methods, absorption_factors, deficiency_symptoms) | Replaced by the generalized `property` table + `type` discriminator per the v2 schema. |

### In scope, modelled in v2, not yet built (no pre-assigned owner)

| Item | Status |
|---|---|
| Regenerate `2_create.sql` from `nutrionista_data_model_v2.xml` (and fix the `effect_type` column bug) | Rev. 4.1 day-1 task |
| Backend entities + repositories for the 16 v2 tables | Depends on schema regeneration |
| Cart endpoints (`/api/users/{userId}/cart`, `/api/carts/{cartId}/items`, `/api/cart-items/{id}`) | New in Rev. 4.1 |
| Checkout endpoints (`POST /api/billings`, `POST /api/orders`, `GET /api/orders/{id}`) | Tables exist in v2 |
| Frontend `/cart`, `/checkout`, `/confirmation/:id`, `/contact` pages on live data | Depends on backend endpoints |
| `/admin/orders`, `/admin/contacts`, `/admin/couriers` admin pages | Depends on admin endpoints |

### Backlog-ready extensions (small additions on top of the v2 schema)

If post-demo work continues, these features fit cleanly:

- **Real auth enforcement** → add a Spring Security filter that resolves the request's user from a session cookie or JWT; the `cart.user_id` / `contact.user_id` FKs are already in place.
- **Wishlist** → add `wishlist_item (user_id, nutrient_id)` (5-minute migration; the structure parallels `cart_item`).
- **`order.user_id`** → migration to add the column + `ON DELETE SET NULL`; backfill is fine because pre-migration orders are anonymous-by-design. Unlocks "my orders" listings and per-user analytics.
- **`order.status` CHECK constraint** → tighten the `CHAR(1)` column with `CHECK (status IN ('P','A','S','C'))` once the codes are frozen.
- **`order.created_at` + `order.updated_at`** → useful for `/admin/orders` sorting.
- **`contact.message TEXT`** → so the feedback form actually captures the user's message body.
