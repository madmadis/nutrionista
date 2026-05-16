# Task: Page 4 — Personaalne vitamiiniprofiil / (VITAMIN) PROFILE PAGE (CUT — DELETE TASK)

**Maps to:** `ProfileView.vue` at `/profile` (HTML page id `profile`)
**Spec sections:** §14 (out of scope), §6 auth, §12 task split
**Depends on:** task_page_1.md (router cleanup), task_page_3.md (quiz cut — profile is the quiz's downstream)

The personal vitamin profile is built on top of the cut quiz feature. Spec §14 lists "personalized vitamin profile (Vitamiiniprofiil)" alongside the quiz: same reason, same cut. This task documents the deletion. Order history and wishlist (linked from this page in the mockup) are cut separately in task_page_11 and task_page_5.

## 1. Frontend (delete-only)

### 1.1 Route
File: `frontend/src/router/index.js`.
- **Delete** the `/profile` route block. The login redirect logic in task_page_1.md §1.1 already sends post-login users to `/admin` or `/` (no longer `/profile`).

### 1.2 View component
- **Path:** `frontend/src/views/ProfileView.vue`.
- **Action:** **`rm frontend/src/views/ProfileView.vue`**.
- Search and remove every inbound reference: `ProfileView`, `/profile`, `profile.vue`. Notable inbound references the mockup implies:
  - `LoginView` submit button (mockup says → `profile.vue`) — already redirected by task_page_2.md.
  - `NavBar.vue` "Profiil" link — already removed by task_page_1.md §1.3.
  - `QuizView.vue` "Esita vastused" → `profile.vue` — already gone with the quiz delete (task_page_3.md).

### 1.3 Components needed
None.

### 1.4 Store interactions
None.

### 1.5 Visual notes
The mockup shows three sections (Sinu riskid, Soovitused, Ostetud vitamiinid) plus reorder reminders ("Telli uuesti") and the next-reminder date. All of this is downstream of the quiz's output and a notification subsystem — both out of scope. Capture the design in §14 backlog for a future iteration.

## 2. Backend
None.

## 3. Database
None. No `vitamin_profile`, `recommendation`, `reorder_reminder` tables.

## 4. Mockup-vs-spec divergence

- **Mockup says:** Profile is the post-login landing page with risks, recommendations, purchase history, reorder reminders, and links to order history + wishlist + cart.
- **Spec says:** Cut (§14 "Vitamiiniprofiil"). Order history is separately cut because v2's `"order"` table has no `user_id` FK. Wishlist is separately cut.
- **Recommendation:** Delete the view + route + all inbound links. Post-login destinations:
  - Admin → `/admin` (dashboard, scoped by task_page_X for the admin pages).
  - Regular user → `/` (Avaleht). The user's "account" affordance in NavBar is just "Logi välja".

## 5. Acceptance criteria (end-to-end)

- [ ] `frontend/src/views/ProfileView.vue` no longer exists.
- [ ] `frontend/src/router/index.js` has no `/profile` route entry.
- [ ] `grep -r "ProfileView\\|/profile\\|profile.vue\\|Vitamiiniprofiil\\|Personaalne vitamiiniprofiil\\|Telli uuesti" frontend/` returns no results.
- [ ] Visiting `http://localhost:5173/profile` shows the SPA's not-found state.
- [ ] Logging in as `madis` (ADMIN) lands on `/admin` (or the `?next` path). Logging in as `tarmo` (USER) lands on `/`.
- [ ] No backend code or SQL references profile, recommendations, or reminders.
