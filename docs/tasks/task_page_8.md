# Task: Page 8 — Ostukorv / CART VIEW PAGE

**Maps to:** `CartView.vue` at `/cart` (HTML page id `cart`)
**Spec sections:** §5 schema (`cart`, `cart_item`), §6 auth, §7 API (cart endpoints), §7.1 cart explainer (server-side), §8 frontend (cart store)
**Depends on:** task_page_1.md (shell, `cartStore` skeleton, `User` entity, `Nutrient` entity), task_page_2.md (login — required to add to cart per spec §6)

Cart is server-side in Rev. 4.1 (spec §7.1) — this task implements the endpoints and rewrites `cartStore` to mirror the DB. The mockup shows quantity editing, line removal, and a "Mine maksma" handoff to checkout (page 9).

## 1. Frontend

### 1.1 Route
File: `frontend/src/router/index.js`.
- `/cart` already exists. **Add `meta: { requiresLogin: true }`** (the router guard from task_page_1 §1.1 then redirects anonymous users to `/login?next=/cart`).

### 1.2 View component
- **Path:** `frontend/src/views/CartView.vue`.
- **Status:** rewrite-existing.
- **Layout (matches mockup):**
  - H1 "Ostukorv".
  - **Empty state** (`v-if="!cart.items.length"`): `<p>Ostukorv on tühi.</p><RouterLink to="/shop" class="bg-primary text-white px-4 py-2 rounded">Mine poodi</RouterLink>`.
  - **Items list** (`v-else`, one row per item):
    - Thumbnail (`/api/nutrient-images/{imageId}` or placeholder).
    - Name (`<RouterLink :to="\`/product/\${item.nutrientId}\`">`).
    - Quantity stepper: `<button @click="dec(item)">-</button> {{ item.quantity }} <button @click="inc(item)">+</button>`. Hitting `-` at qty=1 calls `cart.removeItem(item.id)` (or a confirm-then-remove).
    - Line total: `{{ formatPrice(item.price * item.quantity) }}`.
    - "Eemalda" button → `cart.removeItem(item.id)`.
  - **Footer row:** Koguhind label + total: `<p class="text-xl font-bold">Koguhind: {{ formatPrice(cart.totalAmount) }}</p>`.
  - **"Mine maksma"** button (primary, large, right-aligned). Disabled when `items.length === 0`. `@click="$router.push('/checkout')"`.
- **Data load:** `beforeMount` calls `cart.fetch(auth.userId)` if not already populated.

### 1.3 Components needed
- **NEW: `<QuantityStepper>`** (optional; inline buttons are also fine). If extracted: `frontend/src/components/QuantityStepper.vue`, props `modelValue: Number`, `min: Number` (default 1), `max: Number`; emits `update:modelValue`.
- Existing: NavBar, FooterBar.

### 1.4 Store interactions (cartStore — fully implemented here)

`frontend/src/stores/cart.js` (rewrite finalised here):
```js
import { defineStore } from 'pinia'
import api from '../api.js'

export const useCartStore = defineStore('cart', {
  state: () => ({ cartId: null, items: [] }),
  getters: {
    count: (s) => s.items.reduce((sum, i) => sum + i.quantity, 0),
    totalAmount: (s) => s.items.reduce((sum, i) => sum + Number(i.price) * i.quantity, 0),
  },
  actions: {
    async fetch(userId) {
      const { data } = await api.get(`/users/${userId}/cart`)
      this.cartId = data.id; this.items = data.items
    },
    async addItem(nutrient) {
      if (!this.cartId) await this.fetch(/* userId */)
      const { data } = await api.post(`/carts/${this.cartId}/items`, { nutrientId: nutrient.id, quantity: 1 })
      // server returns the merged-or-inserted line; refresh from response
      const idx = this.items.findIndex(i => i.id === data.id)
      if (idx >= 0) this.items[idx] = data; else this.items.push(data)
    },
    async setQuantity(itemId, quantity) {
      const { data } = await api.put(`/cart-items/${itemId}`, { quantity })
      const idx = this.items.findIndex(i => i.id === itemId)
      this.items[idx] = data
    },
    async removeItem(itemId) {
      await api.delete(`/cart-items/${itemId}`)
      this.items = this.items.filter(i => i.id !== itemId)
    },
    async clear() {
      if (!this.cartId) return
      await api.delete(`/carts/${this.cartId}/items`)
      this.items = []
    },
  },
})
```

### 1.5 Visual notes
- Row: `flex items-center gap-4 border-b border-divider py-3`.
- Thumbnail: `w-16 h-16 rounded`.
- Total: `bg-band rounded p-4 mt-6`.
- "Mine maksma": `bg-primary text-white text-lg px-6 py-3 rounded`.

## 2. Backend

### 2.1 Endpoints
| Method | Path | Purpose | Status |
|---|---|---|---|
| `GET` | `/api/users/{userId}/cart` | Get or lazily create the user's cart with items | create-from-scratch |
| `POST` | `/api/carts/{cartId}/items` | Add an item; merges with existing line by `nutrient_id` | create-from-scratch |
| `PUT` | `/api/cart-items/{id}` | Update line quantity | create-from-scratch |
| `DELETE` | `/api/cart-items/{id}` | Remove one line | create-from-scratch |
| `DELETE` | `/api/carts/{cartId}/items` | Clear the cart (called on checkout success and logout) | create-from-scratch |

#### CartController (NEW)
`backend/src/main/java/ee/nutrionista/cart/CartController.java`
```java
@RestController @RequiredArgsConstructor
public class CartController {
    private final CartService service;

    @GetMapping("/api/users/{userId}/cart")
    public CartDto get(@PathVariable Long userId) { return service.getOrCreate(userId); }

    @PostMapping("/api/carts/{cartId}/items")
    public CartItemDto addItem(@PathVariable Long cartId, @Valid @RequestBody AddCartItemDto body) {
        return service.addItem(cartId, body);
    }

    @PutMapping("/api/cart-items/{id}")
    public CartItemDto setQuantity(@PathVariable Long id, @Valid @RequestBody UpdateCartItemDto body) {
        return service.setQuantity(id, body.quantity());
    }

    @DeleteMapping("/api/cart-items/{id}")
    public ResponseEntity<Void> remove(@PathVariable Long id) {
        service.remove(id); return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/api/carts/{cartId}/items")
    public ResponseEntity<Void> clear(@PathVariable Long cartId) {
        service.clear(cartId); return ResponseEntity.noContent().build();
    }
}
```

#### DTOs
- `CartDto`: `Long id, Long userId, List<CartItemDto> items`.
- `CartItemDto`: `Long id, Long nutrientId, String name, BigDecimal price, Long imageId, Integer quantity`.
- `AddCartItemDto` (record): `@NotNull Long nutrientId, @Min(1) Integer quantity`.
- `UpdateCartItemDto` (record): `@Min(1) Integer quantity`.

#### Service
`CartService`:
- `getOrCreate(Long userId)`:
  ```java
  User user = userRepository.findById(userId).orElseThrow();
  Cart cart = cartRepository.findByUserId(userId).orElseGet(() -> cartRepository.save(new Cart(user)));
  return mapper.toDto(cart);
  ```
- `addItem(Long cartId, AddCartItemDto body)`:
  ```java
  Cart cart = cartRepository.findById(cartId).orElseThrow();
  CartItem existing = cartItemRepository.findByCartIdAndNutrientId(cartId, body.nutrientId()).orElse(null);
  if (existing != null) {
      existing.setQuantity(existing.getQuantity() + body.quantity());
      return mapper.toDto(cartItemRepository.save(existing));
  }
  Nutrient n = nutrientRepository.findById(body.nutrientId()).orElseThrow();
  CartItem item = new CartItem(cart, n, body.quantity());
  return mapper.toDto(cartItemRepository.save(item));
  ```
- `setQuantity(Long itemId, Integer qty)` — bean-validation already enforces `qty >= 1`. Returns the updated DTO.
- `remove(Long itemId)`, `clear(Long cartId)` — straightforward deletes.

#### Repositories
- `CartRepository extends JpaRepository<Cart, Long>`:
  - `Optional<Cart> findByUserId(Long userId);`
- `CartItemRepository extends JpaRepository<CartItem, Long>`:
  - `Optional<CartItem> findByCartIdAndNutrientId(Long cartId, Long nutrientId);`
  - `void deleteByCartId(Long cartId);` (use `@Modifying @Transactional`)

#### Entities (created here)
- `Cart` (`@Entity @Table(name = "cart")`):
  ```java
  @Id @GeneratedValue(strategy = GenerationType.IDENTITY) Long id;
  @ManyToOne(optional = false) @JoinColumn(name = "user_id") User user;
  @OneToMany(mappedBy = "cart", cascade = CascadeType.ALL, orphanRemoval = true) List<CartItem> items;
  ```
- `CartItem` (`@Entity @Table(name = "cart_item")`):
  ```java
  @Id @GeneratedValue(strategy = GenerationType.IDENTITY) Long id;
  @ManyToOne(optional = false) @JoinColumn(name = "cart_id") Cart cart;
  @ManyToOne(optional = false) @JoinColumn(name = "nutrient_id") Nutrient nutrient;
  @Column(nullable = false) Integer quantity;
  ```

#### Mapper
- `CartMapper.toDto(Cart cart)` + `toDto(CartItem item)` mapping nutrient price + first-image-id via the existing `NutrientMapper.firstImageId`.

### 2.2 Error handling
- Unknown `userId` / `cartId` / `itemId` → 404 (from `ApiExceptionHandler`).
- `MethodArgumentNotValidException` from bean validation → 400 with field errors.
- No mockup sticky annotation for this page; the contract above is the team's design.

### 2.3 CORS / Swagger
Inherited from task_page_1. Add `@Operation` summaries.

## 3. Database

### 3.1 Schema reads
- `cart`, `cart_item`, `"user"`, `nutrient`, `nutrient_image` (for thumbnails).

### 3.2 Schema writes
- `cart` (INSERT on first access — lazy create).
- `cart_item` (INSERT / UPDATE quantity / DELETE).

Transactional boundary: each endpoint is one transaction (`@Transactional` on the service methods). No multi-row writes need a single boundary for this page.

### 3.3 Seed data
None new — task_page_1 §3.3 already seeds at least one `USER`-role demo account, which is enough for the demo cart flow. Optionally seed one pre-existing `cart_item` row so the cart icon shows `1` on first login.

### 3.4 Schema gaps
- **Cart ownership is unverified.** Anyone calling `POST /api/carts/{anyCartId}/items` succeeds. Spec §6 acknowledges this; not blocking for the MVP.
- **No `cart_item.unit_price` column.** Quantity changes don't snapshot a price — the cart always displays the current `nutrient.price`. The line snapshot lives on `order_item.price` at checkout (task_page_9). That's intentional per v2.

## 4. Mockup-vs-spec divergence

- **Mockup shows 3 hard-coded products** (Vitamiin A, Vitamiin B kompleks, Vitamiin C) — for the demo, render whatever's in the user's actual cart.
- **Mockup format `12.50 € x 2`** for line description — preserve this format in the UI (`{{ formatPrice(price) }} × {{ quantity }}`).
- **Mockup "Eemalda" button is a separate link, not part of the quantity stepper** — keep it as a separate "Eemalda" link for clarity even when `quantity > 1`.
- **No quantity-edit affordance in the mockup wireframe** (only the static "x 2", "x 1", "x 3") — the spec §7.1 wants quantity edits; add a stepper so the UX is functional.
- **Anonymous cart browsing** — mockup implies anyone can view the cart. Spec §6 / §5 require login. **Resolution:** route guard sends anonymous users to `/login?next=/cart`. The mockup is wrong on this one.

## 5. Acceptance criteria (end-to-end)

- [ ] `curl -s http://localhost:8080/api/users/1/cart | jq` returns `{id, userId, items: []}` for a fresh user; the call is idempotent and lazily creates the row.
- [ ] `curl -s -X POST -H 'Content-Type: application/json' -d '{"nutrientId":3,"quantity":2}' http://localhost:8080/api/carts/1/items | jq` returns the new line; a second call with `nutrientId=3, quantity=1` returns the line with `quantity: 3` (merged).
- [ ] `curl -X PUT -H 'Content-Type: application/json' -d '{"quantity":5}' http://localhost:8080/api/cart-items/1` returns the updated line.
- [ ] `curl -X DELETE http://localhost:8080/api/cart-items/1` returns 204.
- [ ] Opening `/cart` while logged out redirects to `/login?next=/cart`.
- [ ] After login, `/cart` renders the items with thumbnails, names, line totals, and the koguhind matching `SUM(price*quantity)`.
- [ ] Clicking `+` / `-` immediately updates the UI and the DB; clicking "Eemalda" removes the line.
- [ ] Clicking "Mine maksma" navigates to `/checkout` (page 9 owns the destination).
- [ ] The NavBar cart badge reflects `cartStore.count` and updates as items are added/removed.
- [ ] `/swagger-ui.html` lists all five endpoints with their DTOs.
