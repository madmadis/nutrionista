# Task: Page 10 — Tellimus kinnitatud / CONFIRMATION PAGE

**Maps to:** `ConfirmationView.vue` at `/confirmation/:id` (HTML page id `confirmation`; mockup sticky is unannotated — filename and URL are inferred)
**Spec sections:** §7 API (`GET /api/orders/{id}`), §8 frontend (public routes), §13 demo plan
**Depends on:** task_page_1.md (shell), task_page_9.md (`POST /api/orders` + `GET /api/orders/{id}` + `OrderDto`)

This page renders the just-placed order's summary after the checkout submit. The backend endpoint is implemented by task_page_9; this task only creates the view + route.

## 1. Frontend

### 1.1 Route
File: `frontend/src/router/index.js`.
- **New route** — currently absent:
  ```js
  { path: '/confirmation/:id', name: 'Confirmation', component: () => import('@/views/ConfirmationView.vue'), props: true }
  ```
- No `meta.requiresLogin` flag — the page is reachable only via the checkout submit's `router.push`, but a deep link from email (future) should also work without login. The endpoint is public per spec §7.

### 1.2 View component
- **Path:** `frontend/src/views/ConfirmationView.vue`.
- **Status:** create-from-scratch.
- **Layout (matches mockup):**
  - Big H1 "Tellimus kinnitatud!" with a green check icon.
  - `<p>Täname teid tellimuse eest. Teie tellimus on edukalt esitatud ja töödeldakse peagi.</p>`.
  - **Tellimuse number:** `<p class="text-muted">Tellimuse nr. #{{ order.orderId }}</p>` (the mockup omits the number; surface it for traceability).
  - H2 "Tellimuse kokkuvõte".
  - Items list — one row per `order.items`:
    - `{{ item.nutrientName }}`
    - `{{ formatPrice(item.price) }} × {{ item.quantity }} = {{ formatPrice(item.totalSum) }}`
  - Footer row: Kogusumma label + total — `<p class="text-xl font-bold">Kogusumma: {{ formatPrice(order.totalSum) }}</p>`.
  - **Tarneandmed block** (the mockup omits, but useful for confirmation):
    - "Saaja: {{ billing.firstName }} {{ billing.lastName }}"
    - "Aadress: {{ billing.address }}"
    - if `order.collectFromStore` → "Tulen ise järele", else "Tarneviis: {{ billing.courierName }}"
  - "Tagasi avalehele" button → `router.push('/')`.

- **Data load:** `beforeMount` → `api.get('/orders/' + this.id)`. Set `order` on success; show error banner "Tellimust ei leitud" on 404.

### 1.3 Components needed
- Existing: NavBar, FooterBar.
- New: optional `<CheckIcon>` component (just an SVG; can inline).

### 1.4 Store interactions
None. The order summary is fetched fresh.

### 1.5 Visual notes
- Wrap in a card: `max-w-2xl mx-auto bg-surface border border-divider rounded-lg p-8 my-12`.
- Check icon: `text-secondary` (light green, matches spec §8 token).
- "Tagasi avalehele": `bg-primary text-white px-6 py-3 rounded`.

## 2. Backend

### 2.1 Endpoints
| Method | Path | Purpose | Status |
|---|---|---|---|
| `GET` | `/api/orders/{id}` | already created by task_page_9 | done |

No new endpoints needed.

### 2.2 Error handling
- Unknown order id → 404 (already mapped in `ApiExceptionHandler`).

### 2.3 CORS / Swagger
Inherited.

## 3. Database

### 3.1 Schema reads
- `"order"`, `order_item`, `billing`, `courier`, `nutrient` (via `OrderItem.nutrient` for the name).

### 3.2 Schema writes
None.

### 3.3 Seed data
None new. Confirmation only renders an order that exists, so the demo flow creates it live.

### 3.4 Schema gaps
- **No `order.created_at`** — the confirmation page would normally show the order date. Either omit (recommended for MVP) or add the column in a v2.1 migration. Same call-out as task_page_9 §3.4.
- **No `order.tracking_number` or shipping ETA** — Spec doesn't ask for it; mockup doesn't render one. Skip.

## 4. Mockup-vs-spec divergence

- **Mockup sticky is empty** (label `???`, filename `???.vue`) — the design exists but no API contract was annotated. **Resolution:** rely on `GET /api/orders/{id}` from task_page_9 §2.1; this task documents the contract.
- **Mockup shows only items + total, no billing block** — adding the billing recap improves the demo and uses data already on hand. **Resolution:** include the billing block.
- **No URL was annotated** — `/confirmation/:id` is our choice, matching spec §8 routes table.

## 5. Acceptance criteria (end-to-end)

- [ ] Completing a checkout (task_page_9) navigates to `/confirmation/<newOrderId>`; the page renders the order summary with items, line totals, kogusumma, and the billing block.
- [ ] Deep-linking to `/confirmation/9999` (non-existent id) shows the "Tellimust ei leitud" error state.
- [ ] Clicking "Tagasi avalehele" returns to `/` and the NavBar shows the cart icon at 0.
- [ ] The page renders for both anonymous and logged-in users (no `requiresLogin` guard).
- [ ] Console is clean; no Authorization header on the request.
