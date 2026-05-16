# Task: Page 11 — Tellimuste ajalugu / ORDER HISTORY PAGE (CUT — DELETE TASK, with notes for adjacent ADMIN page)

**Maps to:** `OrderHistoryView.vue` at `/order-history` (HTML page id `order_history`)
**Spec sections:** §5 schema (`"order"` has no `user_id`), §14 (out of scope), §7 admin orders endpoints (separate)
**Depends on:** task_page_1.md (router cleanup), task_page_4.md (profile delete — its "Tellimuste ajalugu" button is gone)

The per-user order history is **cut** in spec §14 because the v2 `"order"` table has no `user_id` FK — there's no way to ask "show me my orders". This task documents the deletion AND defines the closely related **admin-orders** page (`/admin/orders`), which IS in scope, since the per-user mockup wireframe doubles as the visual reference for the admin list.

## Part A — Delete `/order-history` (per-user view)

### 1. Frontend (delete-only)

- Delete `frontend/src/views/OrderHistoryView.vue`.
- Remove the `/order-history` route from `router/index.js`.
- Grep and remove inbound references to "Tellimuste ajalugu" (the ProfileView button was already removed by task_page_4).

### 2. Backend (skip)
No `/api/users/{userId}/orders` endpoint is built. The v2 schema doesn't support it without a migration.

### 3. Database (skip)
No new tables. **Backlog item (spec §14):** future revision can add `order.user_id INTEGER REFERENCES "user"(id)` to enable this feature.

### 4. Mockup-vs-spec divergence
- **Mockup says:** Logged-in user sees their two past orders with full details.
- **Spec says:** Cut (§14) — `order` has no `user_id` FK in v2.
- **Recommendation:** Delete the per-user view. The data shape in the mockup informs the admin list below.

## Part B — Build `/admin/orders` (admin order list — IN scope)

The Rev. 4.1 spec §7 lists `/api/admin/orders` and `/api/admin/orders/{id}` plus `/api/admin/orders/{id}/status`. The mockup wireframe for page 11 doubles as the visual reference (cards per order with summary + items + status). The §8 admin routes table also lists `/admin/orders`. This is the right task to ship that.

### B.1 Frontend

#### Route
File: `frontend/src/router/index.js`.
- Add:
  ```js
  { path: '/admin/orders', name: 'AdminOrders', component: () => import('@/views/AdminOrdersView.vue'), meta: { requiresAdmin: true } }
  ```

#### View component
- **Path:** `frontend/src/views/AdminOrdersView.vue` (create-from-scratch).
- **Layout:**
  - H1 "Tellimused (admin)".
  - Filter row: `<select v-model="filterStatus">` with options "Kõik", "PENDING (P)", "PAID (A)", "SHIPPED (S)", "CANCELLED (C)". The lookup `frontend/src/lookups/orderStatus.js` maps codes ↔ labels (see task_page_8 §1).
  - One card per order — visually similar to the mockup's per-user wireframe:
    - H2 "Tellimus #{{ o.orderId }}"
    - "Staatus: {{ statusLabel(o.status) }}" with a colored badge driven by status code (P=yellow, A=blue, S=green, C=red).
    - "Saaja: {{ o.billing.firstName }} {{ o.billing.lastName }}"
    - "Aadress: {{ o.billing.address }}"
    - "Tarneviis: {{ o.collectFromStore ? 'Tulen ise järele' : o.billing.courierName }}"
    - Items table: nutrient name, price × quantity, line total.
    - "Kogusumma: {{ formatPrice(o.totalSum) }}"
    - Status-change dropdown: `<select :modelValue="o.status" @change="updateStatus(o, $event.target.value)">` with the four codes.
- **Data load:** `beforeMount` fetches `/api/admin/orders?status={filter}`; watcher on `filterStatus` re-fetches.

#### Components needed
- New: `<StatusBadge>` (`frontend/src/components/StatusBadge.vue`) — props `status: Character` (one of `P`/`A`/`S`/`C`); renders a coloured pill with the label.

#### Store interactions
None. Admin reads/writes are direct API calls.

#### Visual notes
- Card: `bg-surface border border-divider rounded-lg p-6 mb-4`.
- Status badge colour mapping (UI-only, not in DB):
  - `P` PENDING → `bg-yellow-100 text-yellow-800`
  - `A` PAID → `bg-blue-100 text-blue-800`
  - `S` SHIPPED → `bg-green-100 text-green-800`
  - `C` CANCELLED → `bg-red-100 text-red-800`

### B.2 Backend

#### Endpoints
| Method | Path | Purpose | Status |
|---|---|---|---|
| `GET` | `/api/admin/orders` | list all orders, optional `?status={P|A|S|C}` | create-from-scratch |
| `GET` | `/api/admin/orders/{id}` | one order joined with billing + items | reuse `/api/orders/{id}` from task_page_9? — see note |
| `PUT` | `/api/admin/orders/{id}/status` | update the status code | create-from-scratch |

**Note on `/api/admin/orders/{id}` vs `/api/orders/{id}`:** Both return the same shape. Either reuse `OrderService.get(Long id)` by adding `/api/admin/orders/{id}` as a thin alias, or skip the alias and have the SPA call `/api/orders/{id}`. Recommended: skip the alias; one endpoint is enough.

#### AdminOrderController (NEW)
`backend/src/main/java/ee/nutrionista/order/AdminOrderController.java`
```java
@RestController @RequestMapping("/api/admin/orders") @RequiredArgsConstructor
public class AdminOrderController {
    private final OrderService service;

    @GetMapping
    public List<OrderDto> list(@RequestParam(required = false) Character status) {
        return service.adminList(status);
    }

    @PutMapping("/{id}/status")
    public OrderDto updateStatus(@PathVariable Long id, @Valid @RequestBody UpdateStatusDto body) {
        return service.updateStatus(id, body.status());
    }
}
```

#### DTOs
- `UpdateStatusDto`: `@NotNull Character status` + a custom validator (or service-side check) that the value is in `{'P','A','S','C'}`.

#### Service additions
- `OrderService.adminList(Character status)`:
  ```java
  return (status == null ? orderRepository.findAllByOrderByIdDesc()
                          : orderRepository.findByStatusOrderByIdDesc(status))
       .stream().map(mapper::toDto).toList();
  ```
- `OrderService.updateStatus(Long id, Character status)`:
  ```java
  if (!"PASC".contains(String.valueOf(status))) throw new IllegalArgumentException("Sobimatu staatus");
  Order o = orderRepository.findById(id).orElseThrow();
  o.setStatus(status);
  return mapper.toDto(orderRepository.save(o));
  ```

#### Repository additions
- `OrderRepository`:
  - `List<Order> findAllByOrderByIdDesc();`
  - `List<Order> findByStatusOrderByIdDesc(Character status);`

### B.3 Database

#### Schema reads
- `"order"`, `order_item`, `billing`, `courier`, `nutrient`.

#### Schema writes
- `"order".status` (UPDATE).

#### Seed data
- Optional: pre-seed 2 historical orders (one `S` SHIPPED, one `A` PAID) so the admin list isn't empty on first boot. Keep seeded orders' billing rows simple (`'Demo', 'Demo', 'Demo aadress 1', courier_id=NULL, collect_from_store=TRUE`).

#### Schema gaps
- No `order.created_at` → list is sorted by `id DESC` as a proxy. Add the column in a v2.1 migration to make this a date sort.

### B.4 Mockup-vs-spec divergence (for the admin page)

- **Mockup is a per-user view** ("My orders"), not the admin view. The admin page repurposes the visual layout. Make it clear in the H1: "Tellimused (admin)" or "Kõik tellimused".
- **Mockup shows hardcoded statuses "Täidetud" / "Töötlemisel"** — map our CHAR(1) codes to these or other Estonian labels via `orderStatus.js`. Recommended labels: PENDING→"Ootel", PAID→"Makstud", SHIPPED→"Saadetud", CANCELLED→"Tühistatud". Avoid "Täidetud" to keep status changes unambiguous.
- **Mockup shows shipping address, ETA, payment method per order** — ETA and payment method are not in v2; render only address + courier + collect-from-store flag.

### B.5 Acceptance criteria (admin orders)

- [ ] `curl -s http://localhost:8080/api/admin/orders | jq 'length'` returns the number of orders in the DB.
- [ ] `curl -s 'http://localhost:8080/api/admin/orders?status=P' | jq '[.[] | .status] | unique'` returns `["P"]`.
- [ ] `curl -X PUT -H 'Content-Type: application/json' -d '{"status":"A"}' http://localhost:8080/api/admin/orders/1` returns the updated order with `status:"A"`.
- [ ] `curl -X PUT -H 'Content-Type: application/json' -d '{"status":"X"}' http://localhost:8080/api/admin/orders/1` returns 400.
- [ ] Logging in as `madis` and visiting `/admin/orders` renders one card per order, with the status badge in the right colour and a working status-change dropdown.
- [ ] Non-admin visit to `/admin/orders` redirects to `/login`.
- [ ] `/swagger-ui.html` shows `GET /api/admin/orders` and `PUT /api/admin/orders/{id}/status` with their DTOs.

### B.6 Acceptance criteria (deletion of `/order-history`)

- [ ] `frontend/src/views/OrderHistoryView.vue` no longer exists.
- [ ] No `/order-history` route in `router/index.js`.
- [ ] `grep -r "OrderHistoryView\\|/order-history\\|order_history" frontend/` returns no results.
- [ ] Visiting `http://localhost:5173/order-history` shows the SPA's not-found state.
