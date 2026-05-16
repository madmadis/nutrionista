# Task: Page 5 — Soovikorv / WISHLIST PAGE (CUT — DELETE TASK)

**Maps to:** `WishlistView.vue` at `/wishlist` (HTML page id `wishlist`)
**Spec sections:** §14 (out of scope)
**Depends on:** task_page_1.md (router cleanup), task_page_4.md (profile delete — wishlist was its outbound link)

Wishlist is **explicitly cut** in spec §14: "Adds 1 table + 2 endpoints + 1 page for a feature that doesn't change the demo's wow factor." No `wishlist_item` table is in the v2 model.

## 1. Frontend (delete-only)

### 1.1 Route
File: `frontend/src/router/index.js`.
- **Delete** the `/wishlist` route block (already listed for removal in task_page_1.md §1.1).

### 1.2 View component
- **Path:** `frontend/src/views/WishlistView.vue`.
- **Action:** **`rm frontend/src/views/WishlistView.vue`**.
- Inbound references to remove: "Soovikorv" link / button anywhere in `ProfileView` (deleted by task_page_4), NavBar, footer, etc.

### 1.3 Components needed
None for the page itself. However, if the team wants to keep the "wishlist heart" affordance on product cards as a no-op for future use, **don't** — drop it entirely; less code is better.

### 1.4 Store interactions
None.

### 1.5 Visual notes
Mockup shows three product cards with images, description, price, "Vaata lähemalt" + "Lisab ostukorvi" buttons. The visual pattern is identical to `<ProductCard>` (task_page_1.md §1.11); no new component shapes were introduced by this page.

## 2. Backend
None.

## 3. Database
None. No `wishlist`, `wishlist_item`, or `favorite` tables.

## 4. Mockup-vs-spec divergence

- **Mockup says:** Wishlist with three products and "Lisab ostukorvi" buttons (note: button says "Lisab" — Estonian present tense; the working verb form for the actual cart action is "Lisa ostukorvi" elsewhere).
- **Spec says:** Cut (§14).
- **Recommendation:** Delete. Backlog note in §14 already names the schema if the feature ever returns: `wishlist_item (user_id, nutrient_id)`.

## 5. Acceptance criteria (end-to-end)

- [ ] `frontend/src/views/WishlistView.vue` no longer exists.
- [ ] `frontend/src/router/index.js` has no `/wishlist` route entry.
- [ ] `grep -r "WishlistView\\|/wishlist\\|wishlist.vue\\|Soovikorv" frontend/` returns no results.
- [ ] Visiting `http://localhost:5173/wishlist` shows the SPA's not-found state.
- [ ] No backend code or SQL references wishlist / favourites.
