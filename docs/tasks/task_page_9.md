# Task: Page 9 — Kassa / CHECKOUT PAGE

**Maps to:** `CheckoutView.vue` at `/checkout` (HTML page id `checkout`)
**Spec sections:** §5 schema (`order`, `order_item`, `billing`, `courier`, `cart`, `cart_item`), §7 API (`POST /api/billings`, `POST /api/orders`, `GET /api/couriers`), §14 (real payments cut)
**Depends on:** task_page_1.md (shell, `User`/`Nutrient` entities, color/courier seed), task_page_2.md (login), task_page_8.md (cart endpoints + cartStore)

Checkout converts the server-side cart into a v2 `order` + `order_item` set, splitting the customer's shipping form into a `billing` row (with optional `courier_id`). Real payment is out of scope per §14 — the form collects the data but no payment provider is wired.

## 1. Frontend

### 1.1 Route
File: `frontend/src/router/index.js`.
- `/checkout` already exists. **Add `meta: { requiresLogin: true }`** — the user must be logged in to have a cart.
- Add a navigation guard inside the view: if `cartStore.items.length === 0`, redirect to `/cart` on `beforeMount`.

### 1.2 View component
- **Path:** `frontend/src/views/CheckoutView.vue`.
- **Status:** rewrite-existing.
- **Layout (two sections, then submit):**
  - H1 "Kassa".
  - **Tarneandmed section** (`<form>` with `@submit.prevent="onSubmit"`):
    - Label "Eesnimi:" + `<input v-model="billing.firstName">` (mockup says "Täisnimi"; we split per the v2 `billing` table — see §4).
    - Label "Perekonnanimi:" + `<input v-model="billing.lastName">`.
    - Label "Aadress:" + `<input v-model="billing.address">` (placeholder "Sisesta aadress").
    - Label "Tarneviis:" + `<select v-model="billing.courierId">` populated from `GET /api/couriers`; first option `value=null` labelled "Vali tarneviis".
    - Checkbox `<input type="checkbox" v-model="order.collectFromStore">` + label "Tulen ise järele". When checked, the courier dropdown disables and `billing.courierId` is set to `null`.
    - **Drop the Linn / Postiindeks / E-post / Telefon fields** — see §4 schema gap. (Optional: keep them as UI-only fields that the backend ignores, to match the mockup; safer to omit so the form matches what the API persists.)
  - **Makseandmed section** — render the static "Kaardi number / Kehtivusaeg / CVV" inputs but **disable them and add a `<p class="text-muted">Kaardimaksed pole MVP-s aktiivsed (vt §14)</p>`** below. Don't collect card data into reactive state.
  - **"Kinnita tellimus" button** (primary, large). Disabled while submitting.
- **Submit handler `onSubmit()`:**
  1. `const { data: billing } = await api.post('/billings', { firstName, lastName, address, courierId })` — `courierId` is null if `collectFromStore`.
  2. `const { data: order } = await api.post('/orders', { billingId: billing.id, collectFromStore, cartId: cartStore.cartId })`.
  3. `await cartStore.clear()` — the server already deleted the cart_item rows; this just resets the local state.
  4. `router.push({ name: 'Confirmation', params: { id: order.orderId } })` (route added by task_page_10).
- **Error display**: a banner above the submit button if the API call fails.

### 1.3 Components needed
- Existing: NavBar, FooterBar.
- New: none. (A small `<FormField>` wrapper is overkill for this page.)

### 1.4 Store interactions
- Read: `authStore.userId`, `cartStore.cartId`, `cartStore.items` (for the order summary panel).
- Write: `cartStore.clear()` post-success.

### 1.5 Visual notes
- Two-column on `md+` for the Tarneandmed section; the disabled Makseandmed sits underneath full-width.
- Order summary panel on the right: list the current cart items + totals as a sticky `bg-surface border rounded-lg p-4` block.
- "Kinnita tellimus": `bg-primary text-white text-lg px-6 py-3 rounded`.

## 2. Backend

### 2.1 Endpoints
| Method | Path | Purpose | Status |
|---|---|---|---|
| `POST` | `/api/billings` | Insert a billing row, return `{id}` | create-from-scratch |
| `POST` | `/api/orders` | Materialise `order` + `order_item` rows from a cart in one transaction | create-from-scratch |
| `GET` | `/api/orders/{id}` | Fetch a single order for the confirmation page | create-from-scratch (page 10 also uses) |
| `GET` | `/api/couriers` | Courier dropdown source | create-from-scratch |

#### BillingController (NEW)
`backend/src/main/java/ee/nutrionista/billing/BillingController.java`
```java
@RestController @RequestMapping("/api") @RequiredArgsConstructor
public class BillingController {
    private final BillingService service;
    @PostMapping("/billings")
    public BillingDto create(@Valid @RequestBody CreateBillingDto body) { return service.create(body); }
}
```

#### OrderController (NEW)
`backend/src/main/java/ee/nutrionista/order/OrderController.java`
```java
@RestController @RequestMapping("/api/orders") @RequiredArgsConstructor
public class OrderController {
    private final OrderService service;
    @PostMapping public OrderDto create(@Valid @RequestBody CreateOrderDto body) { return service.create(body); }
    @GetMapping("/{id}") public OrderDto get(@PathVariable Long id) { return service.get(id); }
}
```

#### CourierController (NEW)
`backend/src/main/java/ee/nutrionista/courier/CourierController.java`
```java
@RestController @RequestMapping("/api/couriers") @RequiredArgsConstructor
public class CourierController {
    private final CourierRepository repo;
    @GetMapping public List<CourierDto> list() {
        return repo.findAll().stream().map(c -> new CourierDto(c.getId(), c.getName(), c.getType())).toList();
    }
}
```

#### DTOs
- `CreateBillingDto`: `@NotBlank String firstName, @NotBlank String lastName, @NotBlank String address, Long courierId`.
- `BillingDto`: `Long id, String firstName, String lastName, String address, Long courierId, String courierName`.
- `CreateOrderDto`: `@NotNull Long billingId, @NotNull Boolean collectFromStore, @NotNull Long cartId`.
- `OrderDto`: `Long orderId, BigDecimal totalSum, Character status, Boolean collectFromStore, BillingDto billing, List<OrderItemDto> items`.
- `OrderItemDto`: `Long id, Long nutrientId, String nutrientName, BigDecimal price, Integer quantity, BigDecimal totalSum`.
- `CourierDto`: `Long id, String name, Character type`.

#### Service — the important one
`OrderService.create(CreateOrderDto body)` runs in a single `@Transactional`:
1. `Billing billing = billingRepository.findById(body.billingId()).orElseThrow();`
2. `Cart cart = cartRepository.findById(body.cartId()).orElseThrow();`
3. `List<CartItem> items = cartItemRepository.findByCartId(body.cartId());`
4. `if (items.isEmpty()) throw new IllegalStateException("Cart on tühi");`
5. Build `Order order = new Order(); order.setBilling(billing); order.setStatus('P'); order.setCollectFromStore(body.collectFromStore());`
6. For each `CartItem ci`:
   - `Nutrient n = ci.getNutrient();`
   - `if (n.getStockQuantity() < ci.getQuantity()) throw new IllegalStateException(n.getName() + ": laoseis ei jätku");`
   - Build `OrderItem oi` with `price = n.getPrice()`, `quantity = ci.getQuantity()`, `total_sum = price * quantity`.
   - `order.getItems().add(oi); oi.setOrder(order);`
   - Decrement `n.setStockQuantity(n.getStockQuantity() - ci.getQuantity()); nutrientRepository.save(n);` (optional — spec doesn't mandate; team's call).
7. `order.setTotalSum(items.stream().map(...).reduce(BigDecimal.ZERO, BigDecimal::add));`
8. `orderRepository.save(order);`
9. `cartItemRepository.deleteByCartId(body.cartId());` (also delete the `cart` row if the team prefers a fresh cart on next add — recommend keeping the `cart` row, only clearing items).
10. `return mapper.toDto(order);`

Status codes for `order.status` (CHAR(1)) — spec §5 suggested codes:
- `P` = PENDING (initial)
- `A` = PAID
- `S` = SHIPPED
- `C` = CANCELLED

Document these in `frontend/src/lookups/orderStatus.js` (per task_page_8's spec) and ensure the seed comments line up.

#### Repositories
- `BillingRepository extends JpaRepository<Billing, Long>`.
- `OrderRepository extends JpaRepository<Order, Long>`:
  - Custom finder for §11 page admin list.
- `OrderItemRepository extends JpaRepository<OrderItem, Long>`.
- `CourierRepository extends JpaRepository<Courier, Long>`.
- `CartItemRepository.findByCartId(Long cartId)` and `deleteByCartId(Long cartId)` (already in task_page_8).

#### Entities (created here)
- `Courier` — id, name, `Character type`, apiKey (nullable), endpointUrl (nullable).
- `Billing` — id, firstName, lastName, address, `@ManyToOne(optional = true) @JoinColumn(name = "courier_id") Courier courier`.
- `Order` (`@Entity @Table(name = "\"order\"")` — quoted because `order` is reserved):
  ```java
  @Id @GeneratedValue Long id;
  @ManyToOne(optional = false) @JoinColumn(name = "billing_id") Billing billing;
  BigDecimal totalSum;
  @Column(nullable = false) Character status;
  @Column(name = "collect_from_store") Boolean collectFromStore;
  @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true) List<OrderItem> items;
  ```
- `OrderItem` — id, `@ManyToOne` order, `@ManyToOne` nutrient, price, quantity, `total_sum`.

#### Mapper
- `OrderMapper.toDto(Order o)` — includes nested `BillingDto` + `OrderItemDto` list; uses `NutrientMapper` for nutrient name lookup.

### 2.2 Error handling
- Insufficient stock → 400 `{"error": "<nutrient>: laoseis ei jätku"}`.
- Empty cart at checkout → 400 `{"error": "Ostukorv on tühi"}`.
- Unknown ids → 404 (already handled).

### 2.3 CORS / Swagger
Inherited. Annotate each endpoint with `@Operation`.

## 3. Database

### 3.1 Schema reads
- `cart`, `cart_item`, `nutrient`, `billing`, `courier`.

### 3.2 Schema writes
- `billing` (INSERT one row).
- `"order"` (INSERT one row).
- `order_item` (INSERT N rows).
- `cart_item` (DELETE all rows for the source cart).
- `nutrient` (UPDATE stock_quantity, if the team chose to decrement at checkout).

**All five operations must be in one transaction** — wrap the service method in `@Transactional`. If anything fails midway, no order, billing, or stock change persists, and the cart is unchanged so the user can retry.

### 3.3 Seed data
Inherited from task_page_1 §3.3 (one courier row). Additionally:
- Make sure at least 2 couriers are seeded for a populated dropdown (`Omniva` type=`P`, `Smartpost` type=`P`, optionally `Kullertelmingu` type=`H` — codes per spec §5).
- Optional: pre-seed one PAID order so `/admin/orders` (task_page_11) has data to render. **Skip the pre-seed if the demo will create one live.**

### 3.4 Schema gaps
- **`billing` has no `city` / `postal_code` / `email` / `phone` columns** but the mockup form collects them. **Resolution options:**
  - **(A)** Drop those fields from the UI (recommended for MVP — minimum data to ship).
  - **(B)** Add a v2.1 migration `V18__extend_billing.sql` with the four columns. If chosen, update the entity/DTO/UI together.
- **`order` has no `created_at` column** — sorting in `/admin/orders` (task_page_11) falls back to `id DESC`. The §14 backlog notes a follow-up migration `ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP`.
- **No payment provider tables.** Card fields are UI-only and ignored by the backend. Spec §14 confirms this is intentional.
- **`order` has no `user_id` FK** — see spec §5 / §14. Order history (task_page_11) is therefore cut.

## 4. Mockup-vs-spec divergence

- **Mockup form fields `Täisnimi`, `Linn`, `Postiindeks`, `E-post`, `Telefon`** vs. v2 `billing(first_name, last_name, address, courier_id)` only. **Resolution:** split full-name into first/last in the form; drop the rest (option A) or extend the schema (option B).
- **Mockup has no courier dropdown or "collect from store" checkbox** but v2 models both. **Resolution:** add both to the UI; they're free in the schema.
- **Mockup has full credit-card form** vs. spec §14 "no card capture, no payment provider". **Resolution:** disable the card section with the explanatory note; don't submit it to the backend.
- **Submit button → `confirmation.vue`** — keep; the page exists (task_page_10).

## 5. Acceptance criteria (end-to-end)

- [ ] `curl -s http://localhost:8080/api/couriers | jq` returns the seeded carriers.
- [ ] `curl -s -X POST -H 'Content-Type: application/json' -d '{"firstName":"Tarmo","lastName":"Tamm","address":"Tänav 1","courierId":1}' http://localhost:8080/api/billings | jq` returns `{id, ...}`.
- [ ] With a non-empty cart for user 1, `POST /api/orders` with the billing id + cart id returns `{orderId, totalSum, status:"P", items:[...]}`. The DB now has one `"order"` row, N `order_item` rows, and zero `cart_item` rows for that cart.
- [ ] POSTing again with the same `cartId` returns 400 with the empty-cart error.
- [ ] In the browser, going to `/checkout` with an empty cart redirects to `/cart`.
- [ ] Filling the form and clicking "Kinnita tellimus" navigates to `/confirmation/<id>`; the cart icon resets to 0.
- [ ] The disabled card fields render but cannot be filled in or submitted.
- [ ] `/swagger-ui.html` shows `POST /api/billings`, `POST /api/orders`, `GET /api/orders/{id}`, `GET /api/couriers`.
