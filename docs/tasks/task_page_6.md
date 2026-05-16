# Task: Page 6 — Vitamiinid ja Toidulisandid / SHOP PAGE

**Maps to:** `ShopView.vue` at `/shop` (HTML page id `shop`)
**Spec sections:** §5 schema (`nutrient`, `category`), §7 API (`/api/nutrients`, `/api/categories`), §8 frontend (public routes, design tokens), §14 (brand/goal/bundle cuts)
**Depends on:** task_page_1.md — shell, Tailwind tokens, `<ProductCard>`, `NutrientController`, `Category` entity scaffold, seed data

The shop is the public product browsing experience. Most of the heavy lifting was done in task_page_1 (entities, controller, mapper) — this page extends `NutrientController` with the list endpoint, adds category filtering, and renders a full grid.

## 1. Frontend

### 1.1 Route
File: `frontend/src/router/index.js` (already exists).
- `/shop` route already present. Add `meta: { title: 'Tooted' }` for browser tab title (optional, nice-to-have).

### 1.2 View component
- **Path:** `frontend/src/views/ShopView.vue`.
- **Status:** rewrite-existing.
- **Layout (matches mockup):**
  - H1 "Vitamiinid ja Toidulisandid".
  - **Filter row** (single `<section>`):
    - `<select v-model="filters.categoryId">` — label "Kategooria:". Options populated from `GET /api/categories`. Default option `value=""` labeled "Kõik".
    - Drop "Hind", "Bränd", "Eesmärk", "Sorteeri" dropdowns — see §4 divergence. Only Kategooria survives in the MVP.
  - **Product grid** — responsive `grid grid-cols-2 md:grid-cols-4 gap-4`. One `<ProductCard :nutrient="n" v-for="n in nutrients" :key="n.id">` per result.
  - **Empty state** — when filters return no rows: `<p>Selles kategoorias hetkel tooteid ei ole.</p>`.
  - **No "Populaarsed tootekomplektid" section** — bundles are cut (§14, §4 below).
- **Data load:**
  - `beforeMount()` fetches `categories` and `nutrients` in parallel.
  - `watch(filters.categoryId)` re-fetches `/api/nutrients?category={id}` (omit the param when "Kõik").
  - Use `api.get('/nutrients', { params })`; let Axios serialise the query string.

### 1.3 Components needed
- Existing: `<ProductCard>` (task_page_1.md §1.11), NavBar, FooterBar.
- New: none.

### 1.4 Store interactions
None for read-only browsing. (Cart adds happen on the product detail page — task_page_7.)

### 1.5 Visual notes
- Filter bar: `bg-surface border border-divider rounded-lg p-4 mb-6`.
- Product card images: 75×71 per the mockup (the existing `<ProductCard>` will render the API's `imageId` via `/api/nutrient-images/{id}`).

## 2. Backend

### 2.1 Endpoints
| Method | Path | Purpose | Status |
|---|---|---|---|
| `GET` | `/api/nutrients` | Full nutrient grid; supports `?category={id}` filter | extend controller from task_page_1 |
| `GET` | `/api/nutrients/search?q={query}` | (optional MVP — spec §7) full-text on name | stretch |
| `GET` | `/api/categories` | Category dropdown source | create-from-scratch |
| `GET` | `/api/categories/{id}` | Single category detail (rarely used; included for consistency) | create-from-scratch |

#### NutrientController (extend the file from task_page_1)
```java
@GetMapping
public List<NutrientCardDto> list(@RequestParam(value = "category", required = false) Long categoryId) {
    return service.list(categoryId);
}
```

#### CategoryController (NEW)
`backend/src/main/java/ee/nutrionista/category/CategoryController.java`
```java
@RestController
@RequestMapping("/api/categories")
@RequiredArgsConstructor
public class CategoryController {
    private final CategoryService service;

    @GetMapping public List<CategoryDto> list() { return service.list(); }
    @GetMapping("/{id}") public CategoryDto get(@PathVariable Long id) { return service.get(id); }
}
```

#### DTOs
- `CategoryDto` (record): `Long id, String name, String description`.

#### Services
- `NutrientService.list(Long categoryId)`:
  ```java
  return (categoryId == null
       ? nutrientRepository.findAllByOrderByNameAsc()
       : nutrientRepository.findByCategoryIdOrderByNameAsc(categoryId))
       .stream().map(mapper::toCardDto).toList();
  ```
- `CategoryService.list()` → `categoryRepository.findAllByOrderByNameAsc()`.

#### Repository additions
- `NutrientRepository`:
  - `List<Nutrient> findAllByOrderByNameAsc();`
  - `List<Nutrient> findByCategoryIdOrderByNameAsc(Long categoryId);`

### 2.2 Error handling
- Invalid `category` query param (not a number) → 400 via Spring's default `MethodArgumentTypeMismatchException`. The `ApiExceptionHandler` from task_page_1 covers it.
- Unknown category id → just returns an empty list (200 OK); no error.
- 404 on `GET /api/categories/{id}` for unknown ids — `EntityNotFoundException` handled by `ApiExceptionHandler`.

### 2.3 CORS / Swagger
Both inherited from task_page_1. Add `@Operation` summaries on the new endpoints.

## 3. Database

### 3.1 Schema reads
- `nutrient` (id, name, description, category_id, price, stock_quantity)
- `category` (id, name, description)
- `nutrient_image` (id, nutrient_id) — for the imageId picker

### 3.2 Schema writes
None.

### 3.3 Seed data
Inherited from task_page_1 §3.3. For a richer shop, append more rows to `3_import.sql`:
- 8+ `nutrient` rows across 2+ categories (mockup shows Vitamiin C, D-vitamiin, B-kompleks, Magneesium, Omega-3, Tsink, Kreatiin, Kollageen). Match prices roughly: 12.99, 9.50, 18.00, 7.25, 24.99, 8.90, 15.50, 29.99.
- 2+ `category` rows (`Vitamiinid`, `Mineraalid`, optionally `Toidulisandid`).

### 3.4 Schema gaps
- **Brand / Goal / Bundle filters** in the mockup → no `brand`, `product_goal`, or `bundle` table in v2. **Out of scope per §14.** The single `category` filter is the entire filter UX for the MVP.

## 4. Mockup-vs-spec divergence

- **Brand / Hind / Eesmärk / Sorteeri filters** — no schema, no endpoints. **Resolution:** remove from the UI; only "Kategooria" stays.
- **Populaarsed tootekomplektid section (3 bundles: Immuunsuse Komplekt, Energia Komplekt, Sportlase Komplekt)** — bundles cut in §14. **Resolution:** delete the section from the layout; do not render even as a static teaser.
- **"Vaata komplekti" buttons** — dead links since bundles are cut. **Resolution:** delete with the section.
- **Mockup shows 8 products + 3 bundles in fixed positions** — replace with the dynamic list from the API; the seed should produce enough rows that the grid feels populated.

## 5. Acceptance criteria (end-to-end)

- [ ] `curl -s 'http://localhost:8080/api/categories' | jq` returns an array of seeded categories.
- [ ] `curl -s 'http://localhost:8080/api/nutrients' | jq 'length'` returns the seeded nutrient count.
- [ ] `curl -s 'http://localhost:8080/api/nutrients?category=1' | jq '[.[] | .category_id] | unique'` returns `[1]` (or whatever id was filtered).
- [ ] `curl -s 'http://localhost:8080/api/nutrients?category=99999' | jq` returns `[]`.
- [ ] Opening `/shop` in the browser renders the H1, the Kategooria dropdown populated from the API, and the full nutrient grid.
- [ ] Changing the Kategooria filter immediately re-renders the grid (no full page reload).
- [ ] Each card's "Vaata lähemalt" button routes to `/product/<id>` (page 7 owns the destination).
- [ ] No "Bränd" / "Hind" / "Eesmärk" / "Tootekomplektid" elements visible.
- [ ] `/swagger-ui.html` shows the three endpoints with their DTOs.
