# Task: Page 7 — Toote detailvaade / PRODUCT DETAIL PAGE

**Maps to:** `ProductDetailView.vue` at `/product/:id` (HTML page id `product_detail`; mockup sticky leaves `url` empty — `/product/:id` is from spec §8)
**Spec sections:** §5 schema (`nutrient`, `property`, `nutrient_property`, `nutrient_interaction`, `color_code`, `nutrient_image`), §7 API (`/api/nutrients/{id}`, `/api/color-codes`, `/api/nutrients/{id}/images`), §8 frontend (visual tokens, interaction dots)
**Depends on:** task_page_1.md (shell, `<ProductCard>`, `NutrientController`, `Nutrient`/`NutrientImage`/`Category` entities, color_code seed), task_page_6.md (categories endpoint is unrelated but `nutrientRepository` is in place)

This is the project's signature page — the encyclopedia content rendered next to the product price + Add-to-cart, with the colored-dot interaction panel that proves Nutrionista is more than a generic store (spec §1).

## 1. Frontend

### 1.1 Route
File: `frontend/src/router/index.js`.
- The `/product/:id` route already exists. Add `props: true` so the `id` param flows in as a prop.
- No `meta` flag — the page is public. Add-to-cart click requires login; the redirect-to-`/login?next=...` happens inside the handler, not the guard.

### 1.2 View component
- **Path:** `frontend/src/views/ProductDetailView.vue`.
- **Status:** rewrite-existing.
- **Layout (matches mockup, two-column on `md+`):**
  - Left column:
    - Hero image — primary image from `GET /api/nutrients/{id}/images` (first id) rendered via `/api/nutrient-images/{firstImageId}`. Fallback: `/placeholder.svg`.
    - Optional thumbnail strip below if `images.length > 1` (stretch goal — the mockup only shows one image).
  - Right column:
    - H1 `{{ nutrient.name }}` (e.g. "Vitamiin Nimi" in the mockup).
    - `<p class="text-muted">{{ nutrient.description }}</p>`.
    - Price block: `<p class="text-2xl font-bold text-primary">{{ formatPrice(nutrient.price) }}</p>`.
    - Stock indicator: `<p v-if="nutrient.stockQuantity <= 0" class="text-red-600">Otsas</p>` else `<p class="text-muted">Laos {{ nutrient.stockQuantity }} tk</p>`.
    - **"Lisa ostukorvi"** button (primary, large). Disabled when stock = 0. Handler in §1.4.
  - Below the two columns, full-width:
    - **Funktsioonid** section — `<ul>` of `nutrient.properties.filter(p => p.type === 'FN').map(p => p.name)`. Bullet style `• {{ name }}`.
    - **Imendumismeetodid** section — same shape, `type === 'AM'`.
    - **Imendumistegurid** section — `type === 'AF'`, render as `{{ name }} — {{ effectLabel(effect_type) }}` where `ENHANCE` → "Soodustab" and `INHIBIT` → "Pärsib".
    - **Koostoimed** section — list of interactions, each rendered with a colored dot via `<InteractionDot :color="i.color_code">` then `{{ i.relatedNutrientName }}: {{ i.label }}` (label = "Hea" / "Neutraalne" / "Halb"). The mockup shows `C-vitamiin: Hea`, `Raud: Neutraalne`, `Tsink: Halb`.
    - **Puuduse sümptomid** section — `type === 'DS'`, bulleted.
- **Data load:** `beforeMount` → `api.get('/nutrients/' + this.id)`; the endpoint already returns properties + interactions + image ids joined, see §2.

### 1.3 Components needed
- **NEW: `<InteractionDot>`** (`frontend/src/components/InteractionDot.vue`)
  - Props: `color: String` (a hex code from `color_code.color_code`).
  - Render: `<span class="inline-block w-3 h-3 rounded-full" :style="{ backgroundColor: color }" />`.
  - Spec §5 says the UI must not hard-code the colour mapping — the colour comes from the DB row. Don't introduce a `colorByLabel(label)` helper.
- Existing: NavBar, FooterBar, `<ProductCard>` (not used here directly, but task_page_8 will reference it).

### 1.4 Store interactions
- **cartStore.addItem(nutrient)**: on "Lisa ostukorvi" click:
  1. If `!authStore.isLoggedIn` → `router.push({ path: '/login', query: { next: route.fullPath } })`.
  2. Else `await cartStore.addItem(nutrient)`.
  3. Show a transient toast "Lisatud ostukorvi" (use a simple Pinia transient or a `<Teleport to="body">` element).
- Implementation of `cartStore.addItem` is owned by task_page_8 §1.4.

### 1.5 Visual notes
- Two-column grid: `grid md:grid-cols-2 gap-8`.
- Sections separated by `border-t border-divider pt-6 mt-6`.
- "Hea / Neutraalne / Halb" labels stay Estonian — these strings come from `color_code.name` after a label-map (`GOOD→Hea`, `NEUTRAL→Neutraalne`, `BAD→Halb`). Keep the label map in `frontend/src/lookups/colorCodeLabel.js` so it can be tweaked once.
- The mockup section "Funktsioonid" appears in the right column at top, while "Imendumismeetodid"/"Koostoimed"/"Puuduse sümptomid" appear below. Either layout works; the simpler "right column → full-width sections" structure above is fine for the MVP.

## 2. Backend

### 2.1 Endpoints
| Method | Path | Purpose | Status |
|---|---|---|---|
| `GET` | `/api/nutrients/{id}` | full product detail payload | create-from-scratch |
| `GET` | `/api/nutrients/{id}/images` | list of image ids for the gallery | create-from-scratch |
| `GET` | `/api/color-codes` | interaction-type lookup for the dots | create-from-scratch |

#### NutrientController (extend)
```java
@GetMapping("/{id}")
public NutrientDetailDto get(@PathVariable Long id) { return service.get(id); }

@GetMapping("/{id}/images")
public List<Long> imageIds(@PathVariable Long id) { return service.imageIds(id); }
```

#### ColorCodeController (NEW)
`backend/src/main/java/ee/nutrionista/colorcode/ColorCodeController.java`
```java
@RestController
@RequestMapping("/api/color-codes")
@RequiredArgsConstructor
public class ColorCodeController {
    private final ColorCodeRepository repo;
    @GetMapping public List<ColorCodeDto> list() {
        return repo.findAll().stream().map(c -> new ColorCodeDto(c.getId(), c.getName(), c.getColorCode())).toList();
    }
}
```

#### DTOs
- `NutrientDetailDto`:
  ```java
  public record NutrientDetailDto(
      Long id, String name, String description,
      BigDecimal price, Integer stockQuantity,
      Long categoryId, String categoryName,
      List<Long> imageIds,
      List<PropertyDto> properties,
      List<InteractionDto> interactions) {}
  ```
- `PropertyDto`: `Long id, String type, String name, String description, String effectType` (effectType nullable; only set when `type='AF'`).
- `InteractionDto`: `Long id, Long relatedNutrientId, String relatedNutrientName, Integer colorCodeId, String colorCodeName, String colorCode, String description`.
- `ColorCodeDto`: `Integer id, String name, String colorCode`.

#### Service
`NutrientService.get(Long id)`:
1. `Nutrient n = repo.findById(id).orElseThrow(EntityNotFoundException::new);`
2. Map to DTO, eagerly fetching `properties` (via `nutrient_property` join — Hibernate `@OneToMany` with `FetchType.LAZY` and `@EntityGraph` on the repo method, OR a custom `@Query`).
3. Map interactions where `nutrient_id = n.id` (NOT `related_nutrient_id` — directionality matters per spec §5).
4. Image ids fetched in a separate query: `nutrientImageRepository.findIdsByNutrientId(n.id)`.

Recommend a single fetch-join query in the repo to avoid N+1:
```java
@Query("""
  SELECT DISTINCT n FROM Nutrient n
  LEFT JOIN FETCH n.category
  LEFT JOIN FETCH n.nutrientProperties np
  LEFT JOIN FETCH np.property
  WHERE n.id = :id
""")
Optional<Nutrient> findFullById(@Param("id") Long id);
```
Then a separate, smaller query for interactions + images.

#### Repository additions
- `NutrientRepository.findFullById(Long id)` as above.
- `NutrientImageRepository`:
  ```java
  @Query("SELECT i.id FROM NutrientImage i WHERE i.nutrient.id = :nid ORDER BY i.id ASC")
  List<Long> findIdsByNutrientId(@Param("nid") Long nid);
  ```
- `NutrientInteractionRepository extends JpaRepository<NutrientInteraction, Long>`:
  ```java
  @Query("""
    SELECT i FROM NutrientInteraction i
    JOIN FETCH i.colorCode JOIN FETCH i.relatedNutrient
    WHERE i.nutrient.id = :nid
  """)
  List<NutrientInteraction> findFullByNutrientId(@Param("nid") Long nid);
  ```
- `ColorCodeRepository extends JpaRepository<ColorCode, Integer>`.

#### Entities (created here)
- `Property` — id, type, name, description.
- `NutrientProperty` — id, `@ManyToOne` nutrient (cascade nothing, FK has `ON DELETE CASCADE` in SQL), `@ManyToOne` property, `effectType` (`@Column(name = "effect_type")`, nullable).
- `ColorCode` — id (`Integer`), name (`@Column(unique = true)`), `colorCode` (`@Column(name = "color_code")`).
- `NutrientInteraction` — id, `@ManyToOne` nutrient (the "actor"), `@ManyToOne` relatedNutrient (`@JoinColumn(name = "related_nutrient_id")`), `@ManyToOne` colorCode (`@JoinColumn(name = "interaction_type_id")`), description.
- Extend `Nutrient` with `@OneToMany(mappedBy = "nutrient") private List<NutrientProperty> nutrientProperties;` and `@OneToMany(mappedBy = "nutrient") private List<NutrientImage> images;`.

#### Mapper
Add to `NutrientMapper`:
- `toDetailDto(Nutrient n, List<Long> imageIds, List<NutrientInteraction> interactions)` — the imageIds + interactions are passed in (the mapper doesn't query).

### 2.2 Error handling
- Unknown id → 404 `{"error": "Toodet ei leitud"}` (already in `ApiExceptionHandler` from task_page_1).
- No mockup sticky annotation for this page; Veateated is empty — so this is the design choice.

### 2.3 CORS / Swagger
Inherited. Add `@Operation` summaries.

## 3. Database

### 3.1 Schema reads
- `nutrient`, `category`, `nutrient_image`
- `nutrient_property` (id, nutrient_id, property_id, effect_type)
- `property` (id, type, name, description)
- `nutrient_interaction` (id, nutrient_id, related_nutrient_id, interaction_type_id, description)
- `color_code` (id, name, color_code)

### 3.2 Schema writes
None.

### 3.3 Seed data
Append to `docs/database/3_import.sql`:
- **`property` rows** (~12 rows total): for each of the seeded nutrients, 1–3 functions (type `FN`), 1 absorption method (`AM`), 1–2 absorption factors (`AF`), 1 deficiency symptom (`DS`). Example for Vitamin D:
  ```sql
  -- Vitamin D (assume nutrient.id=3)
  INSERT INTO property (type, name) VALUES
    ('FN','Toetab immuunsüsteemi'),
    ('FN','Oluline luude tervisele'),
    ('AM','Rasvlahustuv'),
    ('AF','Vajab D-vitamiini'),
    ('DS','Lihasnõrkus');
  -- get the ids back with RETURNING in a transaction, or rely on a known offset
  INSERT INTO nutrient_property (nutrient_id, property_id, effect_type) VALUES
    (3, <FN id>,  NULL),
    (3, <FN id2>, NULL),
    (3, <AM id>,  NULL),
    (3, <AF id>,  'ENHANCE'),
    (3, <DS id>,  NULL);
  ```
- **`nutrient_interaction` rows** (per the mockup's Vitamin D detail): `(Vitamin D, Vitamiin C, GOOD, '')`, `(Vitamin D, Raud, NEUTRAL, '')`, `(Vitamin D, Tsink, BAD, '')`. Seed enough so the dot panel is visible on at least one nutrient.
- `color_code` rows are seeded in task_page_1 §3.3 — reference back.

### 3.4 Schema gaps
None for this page — the v2 model covers it cleanly. Note the property-vs-CHECK bug from spec §5 must already be fixed by task_page_1 §3.5.

## 4. Mockup-vs-spec divergence

- **Section headings on the mockup are "Funktsioonid", "Imendumismeetodid", "Koostoimed", "Puuduse sümptomid"** — these match the `property.type` discriminator codes one-to-one (FN/AM/AF/DS). Stay faithful; **do not** invent a fifth section.
- **Mockup labels for interaction types: "Hea" / "Neutraalne" / "Halb"** vs. DB codes `GOOD` / `NEUTRAL` / `BAD` — map in the frontend, not in the DB. See §1.5.
- **No "absorption factor" section in the mockup wireframe specifically** — the mockup conflates "Imendumismeetodid" with the AF rows. **Resolution:** render `AM` and `AF` as a single combined "Imendumine" section in the UI if simpler, or two sections "Imendumismeetodid" + "Imendumistegurid (soodustab/pärsib)" for clarity. The latter is recommended.
- **Yellow sticky is empty** — the team must invent the API contract. The DTOs above are our design; document them in Swagger.

## 5. Acceptance criteria (end-to-end)

- [ ] `curl -s http://localhost:8080/api/nutrients/3 | jq` returns a payload with `name`, `price`, `stockQuantity`, `imageIds`, `properties` grouped by type, and `interactions` with colour data.
- [ ] `curl -s http://localhost:8080/api/color-codes | jq` returns the 3 seeded codes.
- [ ] Opening `/product/3` in the browser renders the hero image, name, description, price, stock indicator, "Lisa ostukorvi", and all four content sections populated from the API.
- [ ] The Koostoimed section shows three rows for Vitamin D — green for C-vitamiin, yellow for Raud, red for Tsink. Inspecting the dot in DevTools shows the colour from `color_code.color_code`, not a hardcoded class.
- [ ] Clicking "Lisa ostukorvi" while logged out redirects to `/login?next=/product/3`; clicking while logged in adds the item and shows the "Lisatud ostukorvi" toast.
- [ ] An unknown id like `/product/99999` shows a "Toodet ei leitud" error state (frontend catches 404 from the API).
- [ ] `/swagger-ui.html` lists `GET /api/nutrients/{id}`, `GET /api/nutrients/{id}/images`, `GET /api/color-codes` with their DTOs.
