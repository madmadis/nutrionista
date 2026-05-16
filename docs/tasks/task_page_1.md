# Task: Page 1 — Avaleht / LANDING PAGE/HOME

**Maps to:** `HomeView.vue` at `/` (HTML page id `main`; mockup sticky says `/home` — we use `/` per the existing router and spec §8 routes table)
**Spec sections:** §3 stack, §4 architecture, §5 schema (`nutrient`, `category`, `nutrient_image`), §6 auth, §7 API (`/api/nutrients/highlights`, `/api/nutrient-images/{id}`), §8 frontend (visual tokens, public routes), §10 DB workflow, §12 task split
**Depends on:** None — **this task owns the entire shared frontend shell + the schema-alignment foundation**.

This page is the first one to ship. Before its content runs, the project must come up off the v2 model with a working dev server, an Axios + Pinia + Router skeleton, the shared NavBar/FooterBar, the Tailwind tokens, the `nutrient` table seeded, and one read endpoint live. The task is bigger than just `HomeView.vue` for that reason.

## 1. Frontend

### 1.1 Routes (whole-app — touched once here)
File: `frontend/src/router/index.js` (already exists; rewrite needed).

- Change the `/` route to load `HomeView.vue` (already correct in the current file).
- Add `meta: { requiresLogin: true }` to `/cart`, `/checkout`, `/profile`, `/contact` (cart/contact rows need a user — spec §6).
- Keep `meta: { requiresAdmin: true }` on `/admin/*` routes.
- **Remove** the routes for the cut-feature views (per spec §14): `/quiz`, `/wishlist`, `/order-history`, `/blog`, `/admin/blog`, `/admin/faq`. Leave a comment in their place referencing the spec.
- Extend the `router.beforeEach` guard:
  ```js
  router.beforeEach((to) => {
    const auth = useAuthStore()
    if (to.meta.requiresAdmin && !auth.isAdmin) return { path: '/login', query: { next: to.fullPath } }
    if (to.meta.requiresLogin && !auth.isLoggedIn) return { path: '/login', query: { next: to.fullPath } }
  })
  ```

### 1.2 Shared shell (whole-app — touched once here)
File: `frontend/src/App.vue` (rewrite — currently only renders `<RouterView />`).

```vue
<template>
  <div class="min-h-screen flex flex-col bg-background">
    <NavBar />
    <main class="flex-1"><RouterView /></main>
    <FooterBar />
  </div>
</template>

<script>
import NavBar from '@/components/NavBar.vue'
import FooterBar from '@/components/FooterBar.vue'
import { RouterView } from 'vue-router'
export default { name: 'App', components: { NavBar, FooterBar, RouterView } }
</script>
```

### 1.3 NavBar.vue (already exists — edit-in-place)
- Replace inline hex (`bg-[#e6007a]`, `bg-[#e0ffe0]`, `text-[#555555]`, etc.) with Tailwind tokens (see §1.6).
- Drop the admin dropdown items for cut features: remove "Blogi" (`/admin/blog`) and "KKK" (`/admin/faq`); keep "Vitamiinid" (`/admin/nutrients`). Plan to add "Kategooriad", "Tellimused", "Kontaktid", "Kullerid", "Värvikoodid", "Omadused" links here as later tasks land them.
- After a successful login, NavBar shows the user's `firstName + lastName` (per the mockup login response) — but since the v2 schema doesn't carry those fields, show `auth.username` instead until §3.4 below is resolved.
- The Estonian labels stay Estonian: "Avaleht", "Tooted", "Ostukorv", "Logi sisse", "Logi välja", "Profiil", "Admin".

### 1.4 FooterBar.vue (already exists — edit-in-place)
- Render: `© 2026 Nutrionista` and a single link "Kontakt" → `/contact`.
- **Remove** "Blogi" and "KKK" links — those features are cut (§14). The mockup shows them; the spec wins.

### 1.5 Pinia stores (whole-app — touched once here)

**`frontend/src/stores/auth.js` — rewrite (currently uses tokens; spec §6 forbids tokens).**
- State: `userId`, `username`, `role`. (No token, no `Authorization` header.)
- Actions: `login(username, password)` posts to `/api/login`; `logout()` clears state (no backend call); no `register` action — delete it.
- Persistence: `localStorage` keys `userId` / `username` / `role`, rehydrated on store init.
- Getters: `isAdmin` (= `role === 'ADMIN'`), `isLoggedIn` (= `userId != null`).

**`frontend/src/stores/cart.js` — rewrite (currently browser-only; spec §5 / §7.1 puts cart in the DB).**
- State: `cartId`, `items: [{ id, nutrientId, name, price, imageUrl, quantity }]`.
- Actions: `fetch(userId)`, `addItem(nutrient)`, `updateQuantity(itemId, qty)`, `removeItem(itemId)`, `clearLocal()`. Each action that mutates hits the corresponding endpoint (§7).
- Getters: `count` (sum of `quantity`), `totalAmount` (sum of `price * quantity`).
- No `localStorage` persistence for items — DB is source of truth. Hydrate via `fetch(authStore.userId)` after login (or on app mount if `isLoggedIn`).

### 1.6 Axios instance (whole-app — touched once here)
File: `frontend/src/api.js` (rewrite — currently sends a Bearer token).

```js
import axios from 'axios'
const api = axios.create({ baseURL: '/api' })
export default api
```

Drop the request interceptor entirely. Spec §6: no token to send. Also delete the `app.config.globalProperties.$axios = axios` line in `main.js` — every component imports the `api` instance directly.

### 1.7 Tailwind tokens (whole-app — touched once here)
File: `frontend/tailwind.config.js` (extend).

Extend `theme.extend.colors` with the §8 design-token table (currently missing the header/footer band, primary-pink is fine, plus muted text):
```js
colors: {
  primary: '#e6007a',
  secondary: '#90ee90',
  band: '#e0ffe0',        // NEW — header/footer green strip
  background: '#f8f8f8',
  surface: '#ffffff',
  border: '#dddddd',
  divider: '#eeeeee',     // NEW — softer divider
  text: '#333333',        // NEW — primary text
  muted: '#666666',       // NEW — secondary captions
},
```
Then sweep `NavBar.vue` / `FooterBar.vue` / every new view to use `bg-band`, `text-text`, `text-muted`, `border-divider` instead of `bg-[#e0ffe0]` etc.

### 1.8 Vite proxy (whole-app — touched once here)
File: `frontend/vite.config.js`. Add:
```js
server: { proxy: { '/api': { target: 'http://localhost:8080', changeOrigin: true } } }
```
So `baseURL: '/api'` works in dev without CORS errors. Spring Boot CORS still has to allow the Vercel domain in prod (§7).

### 1.9 Bootstrap removal
File: `frontend/src/main.js`. Remove the `import 'bootstrap/dist/css/...'` and `import 'bootstrap/dist/js/bootstrap.js'` lines. The project is Tailwind-styled per the spec; Bootstrap is dead weight.

### 1.10 HomeView.vue (already exists — rewrite per mockup)
File: `frontend/src/views/HomeView.vue`.

Layout, top to bottom:
- **Hero section**: H1 "Tere tulemast Nutrionistasse!", subtitle "Avasta parimad vitamiinid ja toidulisandid oma tervise toetamiseks.", **NO** "Tee vitamiinitest" CTA (quiz is cut — see §4). Replace with an "Ava pood" button → `/shop`.
- **Esiletõstetud Tooted section**: H2 "Esiletõstetud Tooted", then a 4-card grid populated from `GET /api/nutrients/highlights`. Each card: image (from `/api/nutrient-images/{id}` via the first image id in the nutrient payload), name, short description, price (formatted `price.toFixed(2) + " €"`), and a "Vaata lähemalt" button that pushes to `/product/:id`. Wrap the whole card in `<RouterLink>` so the whole card is clickable (matches the mockup's HTML `card` nav edge).
- Data-load in `beforeMount()` per `docs/vue-komponendi-struktuur.md`. Show a simple "Laadimine..." text while pending and a friendly error banner if the API call fails.

### 1.11 ProductCard component (NEW)
File: `frontend/src/components/ProductCard.vue`.
- Props: `nutrient: { id, name, description, price, imageId }`.
- Renders: image (or `/placeholder.svg` if `imageId` is null), `name`, truncated `description`, formatted price, "Vaata lähemalt" button. Wraps a `<RouterLink :to="\`/product/\${nutrient.id}\`">`.
- Used by HomeView (highlights), ShopView (full grid), WishlistView would have used it (cut feature).

### 1.12 Visual notes
- Hero subtitle area maps to a wide image placeholder in the mockup — use `/assets/hero.jpg` (commit a public-domain image into `frontend/public/assets/hero.jpg`).
- Product card images: 56×56 thumbnail per the mockup (`54.7×58.1` from describe-mockup-page).
- All text uses the `text` token; muted captions (price `9.50 €`) stay primary-coloured per the mockup; descriptions use `muted`.

## 2. Backend

### 2.1 Endpoints
| Method | Path | Purpose | Status |
|---|---|---|---|
| `GET` | `/api/nutrients/highlights` | 4 newest in-stock nutrients for the home grid | create-from-scratch |
| `GET` | `/api/nutrient-images/{id}` | raw bytes of one `nutrient_image` row | create-from-scratch |
| `GET` | `/actuator/health` | keep-alive — comes for free with the actuator dep | dependency only |

#### NutrientController (NEW)
`backend/src/main/java/ee/nutrionista/nutrient/NutrientController.java`

```java
@RestController
@RequestMapping("/api/nutrients")
@RequiredArgsConstructor
public class NutrientController {
    private final NutrientService service;

    @GetMapping("/highlights")
    public List<NutrientCardDto> highlights() { return service.findHighlights(); }
}
```

#### NutrientImageController (NEW)
`backend/src/main/java/ee/nutrionista/nutrient/NutrientImageController.java`

```java
@RestController
@RequestMapping("/api/nutrient-images")
@RequiredArgsConstructor
public class NutrientImageController {
    private final NutrientImageService service;

    @GetMapping("/{id}")
    public ResponseEntity<byte[]> bytes(@PathVariable Long id) {
        byte[] data = service.find(id);
        return ResponseEntity.ok()
            .contentType(MediaType.IMAGE_JPEG)
            .cacheControl(CacheControl.maxAge(Duration.ofDays(7)))
            .body(data);
    }
}
```

#### DTOs
- `NutrientCardDto` (record): `Long id, String name, String description, BigDecimal price, Integer stockQuantity, Long imageId`. `imageId` is the lowest `nutrient_image.id` for that nutrient (or null).
- Sticky says nothing for this page — these DTO names are ours. Document them in Swagger via `@Schema(description = "...")`.

#### Services
- `NutrientService.findHighlights()`:
  ```java
  return nutrientRepository.findTop4ByStockQuantityGreaterThanOrderByCreatedAtDesc(0)
       .stream().map(mapper::toCardDto).toList();
  ```
- `NutrientImageService.find(id)` returns `nutrientImageRepository.findById(id).orElseThrow(...).getImageData()`.

#### Repositories
- `NutrientRepository extends JpaRepository<Nutrient, Long>`
  - `List<Nutrient> findTop4ByStockQuantityGreaterThanOrderByCreatedAtDesc(int min);`
- `NutrientImageRepository extends JpaRepository<NutrientImage, Long>`
- `CategoryRepository extends JpaRepository<Category, Long>` (created here even though page 1 doesn't read it — keeps the package import order coherent).

#### Entities (whole-catalog — created here)
- `Nutrient` (`@Entity @Table(name="nutrient")`): id, name, description, `@ManyToOne` category, price (`BigDecimal`, `@DecimalMin("0.00")`), stockQuantity (`Integer`), createdAt, updatedAt (`@PrePersist`/`@PreUpdate`).
- `NutrientImage` (`@Entity @Table(name="nutrient_image")`): id, `@ManyToOne` nutrient, `image_data` mapped as `byte[]` with `@Lob`.
- `Category` (`@Entity @Table(name="category")`): id, name, description.

#### MapStruct mapper
`NutrientMapper.java` — `@Mapper(componentModel = "spring")` with `toCardDto(Nutrient entity)` that picks the first image id via a custom method:
```java
@Mapping(target = "imageId", expression = "java(firstImageId(entity))")
NutrientCardDto toCardDto(Nutrient entity);

default Long firstImageId(Nutrient n) {
  return n.getImages() == null || n.getImages().isEmpty() ? null
       : n.getImages().stream().mapToLong(NutrientImage::getId).min().getAsLong();
}
```

### 2.2 Error handling (whole-app — owned here)
`backend/src/main/java/ee/nutrionista/common/ApiExceptionHandler.java` — `@RestControllerAdvice`.
- `EntityNotFoundException` → 404 `{ "error": "Toodet ei leitud" }`
- `MethodArgumentNotValidException` → 400 with field errors (used by later tasks).
- `RuntimeException` → 500 `{ "error": "Sisemine viga" }` (don't leak stack).

### 2.3 CORS (whole-app — owned here)
`backend/src/main/java/ee/nutrionista/common/CorsConfig.java`:
```java
@Configuration
public class CorsConfig implements WebMvcConfigurer {
    @Value("${cors.allowed-origins}") private String[] origins;
    @Override public void addCorsMappings(CorsRegistry r) {
        r.addMapping("/api/**").allowedOrigins(origins).allowedMethods("*");
    }
}
```
In `application.properties`: `cors.allowed-origins=http://localhost:5173,https://<your-vercel-domain>`.

### 2.4 Swagger (whole-app — owned here)
- `build.gradle` already pulls `springdoc-openapi-starter-webmvc-ui:3.0.3` per spec §3. Confirm.
- No code; Swagger UI auto-mounts at `/swagger-ui.html`.

### 2.5 Actuator (whole-app — owned here)
- Add `spring-boot-starter-actuator` to `build.gradle`.
- `application.properties`: `management.endpoints.web.exposure.include=health`.

## 3. Database

### 3.1 Schema reads (this page)
- `nutrient` (id, name, description, price, stock_quantity, created_at)
- `nutrient_image` (id, nutrient_id, image_data) — but the page returns only the id; the bytes are fetched on demand by `<img>` tags.

### 3.2 Schema writes (this page)
None — Avaleht is read-only.

### 3.3 Seed data (whole-DB — owned here)
File: `docs/database/3_import.sql`.

This is the master seed file. Page 1 fills the minimum set so the home page renders something; later tasks append. Owned here:
- `role` rows (id auto, `ADMIN`, `USER`) — used by tasks 2, 4, 8, 13.
- At least one `category` (e.g. `Vitamiinid`, `Mineraalid`, `Toidulisandid`).
- At least four `nutrient` rows with `stock_quantity > 0` and ascending `created_at`, matching the mockup names (`Vitamiin A` 18.75 €, `Vitamiin C` 15.00 €, `Vitamiin D` 12.99 €, `B-kompleks` 9.50 €).
- One `nutrient_image` row per seeded nutrient (use a tiny placeholder PNG decoded from a base64 string in the seed file, or rely on `null` images and have the frontend fallback to `/placeholder.svg`).
- `color_code` rows (id auto, `GOOD` `#22c55e`, `NEUTRAL` `#eab308`, `BAD` `#ef4444`) — used by tasks 7, 8.
- `property.type` reference codes documented in a SQL comment block (FN/AM/AF/DS) — used by task 7.
- One regular `USER`-role demo user with a bcrypt hash, plus the three admin users (`madis`, `kaili`, `rain`) — used by tasks 2, 4, 8, 13.
- One `courier` row (e.g. `Omniva`, type `P` parcel-locker) — used by task 9.

### 3.4 Schema gaps surfaced by this page
None that block Avaleht — but the NavBar wants to show the logged-in user's name. The v2 `"user"` table has only `username` + `password_hash`. The mockup (page 2) returns `firstName`/`middleName`/`lastName` from `/api/login`. **For now** NavBar shows `username`. Resolution is owned by task_page_2.md §3.4.

### 3.5 Canonical `2_create.sql` regeneration (whole-DB — owned here)
Before any of the above works, `docs/database/2_create.sql` must be regenerated from `docs/nutrionista_data_model_v2.xml` per spec §5 / §12. The 16-table DDL block in spec §5 is the reference. Specifically:
- **Add the missing `effect_type VARCHAR(10)` column** on `nutrient_property` so the `nutrient_property_effect_ck` CHECK constraint resolves. (Bug carried forward from the v2 XML — flagged in spec §5.)
- Order: lookups first (`role`, `category`, `color_code`, `courier`, `property`), then `nutrient`, then `nutrient_image`, then the rest.
- Drop the Rev. 4 `nutrient.image_id` column entirely; the relationship is `nutrient_image.nutrient_id` only.
- `nutrient.in_stock` is **not** in v2 — replace with `stock_quantity INT NOT NULL`.

## 4. Mockup-vs-spec divergence

- **Hero CTA "Tee vitamiinitest" → `quiz.vue`** — quiz is cut in spec §14. **Resolution:** replace the CTA with "Ava pood" → `/shop`. Document on the task_page_3 (Quiz) delete task.
- **Footer links Blogi / KKK / Kontakt** — Blogi cut (§14), KKK is a static-page stretch goal, only Kontakt survives. **Resolution:** footer renders only "Kontakt"; remove the rest. Cross-references task_page_12 (Blog delete) and task_page_14 (FAQ static stretch).
- **URL `/home` in the mockup sticky** — current router uses `/` and spec §8 uses `/`. **Resolution:** stay on `/`; the sticky is wrong.
- **NavBar shows "Minu konto" → `login.vue`** — Once logged in, the link should go to `/profile`. But `ProfileView` is cut (§14). **Resolution:** NavBar shows "Logi sisse" when anonymous and "Logi välja" + user's name when logged in; there is no profile route. See task_page_4.
- **Bootstrap is imported in `main.js`** — not in the spec stack (§3 is Tailwind only). **Resolution:** delete the import.
- **`authStore` has a `register` action posting to `/api/register`** — spec §8 "There is **no `/register` route**". **Resolution:** delete the action.
- **`api.js` Axios sends `Authorization: Bearer <token>`** — spec §6 "no token to send". **Resolution:** delete the interceptor.

## 5. Acceptance criteria (end-to-end)

- [ ] `./gradlew bootRun` starts the backend on `:8080`; `psql -f docs/database/{1_reset_database,2_create,3_import}.sql` succeeds without errors.
- [ ] `curl -s http://localhost:8080/api/nutrients/highlights | jq` returns an array of 4 objects in the shape `{id, name, description, price, stockQuantity, imageId}`.
- [ ] `curl -s http://localhost:8080/api/nutrient-images/1 -o /tmp/img.bin && file /tmp/img.bin` reports an image type (PNG/JPEG).
- [ ] `curl -s http://localhost:8080/actuator/health` returns `{"status":"UP"}`.
- [ ] `npm run dev` (in `frontend/`) starts Vite on `:5173`; opening `http://localhost:5173/` shows NavBar, hero, the 4-card highlights grid populated from the API, and the FooterBar.
- [ ] Clicking a product card navigates to `/product/<id>` (404 OK for now — page 7 owns that view).
- [ ] Clicking NavBar "Logi sisse" navigates to `/login` (404-renderable shell OK — page 2 owns that view).
- [ ] No console errors. No `Authorization` header on `/api/nutrients/highlights`. Browser DevTools shows requests going through the Vite proxy.
- [ ] No references to Bootstrap classes anywhere. No `bg-[#hex]` literals in `NavBar.vue` or `FooterBar.vue`.
- [ ] `/swagger-ui.html` lists `GET /api/nutrients/highlights` and `GET /api/nutrient-images/{id}`.
