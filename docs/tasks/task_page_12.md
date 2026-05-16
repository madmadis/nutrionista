# Task: Page 12 — Blogi/Artiklid / BLOG PAGE (CUT — DELETE TASK)

**Maps to:** `BlogView.vue` at `/blog` (HTML page id `blog`)
**Spec sections:** §14 (out of scope), §12 task split (cleanup)
**Depends on:** task_page_1.md (router cleanup, footer cleanup)

Blog is **explicitly cut** in spec §14: "Blogi/Artiklid — Cut entirely from the data model. The frontend `/blog` route and `BlogView`/`AdminBlogView` still exist and need to be deleted in the §12 foundation cleanup."

## 1. Frontend (delete-only)

### 1.1 Routes
File: `frontend/src/router/index.js`.
- **Delete** the `/blog` route block.
- **Delete** the `/admin/blog` route block (admin counterpart).

Both removals are already listed in task_page_1.md §1.1 — this task confirms them and ships the file deletions.

### 1.2 View components
- **Delete:**
  - `frontend/src/views/BlogView.vue`
  - `frontend/src/views/AdminBlogView.vue`
- Inbound references to remove:
  - Footer "Blogi" link — already removed by task_page_1.md §1.4 (FooterBar).
  - NavBar admin dropdown "Blogi" entry — already removed by task_page_1.md §1.3.

### 1.3 Components needed
None.

### 1.4 Store interactions
None.

### 1.5 Visual notes
The mockup shows a 6-card grid of articles (Artikli pealkiri 1..6) with images and "Loe edasi" buttons. None of it is implemented.

## 2. Backend
None. No `BlogPostController`, no entities. The spec §12 already notes "Deleted cut-feature backend code: `BlogPost*` entities/repos/controllers — never existed in the current backend skeleton; nothing to delete."

## 3. Database
None. No `blog_post`, `blog_category`, `blog_image` tables.

## 4. Mockup-vs-spec divergence

- **Mockup says:** Six-card blog grid for SEO + education.
- **Spec says:** Cut (§14).
- **Recommendation:** Delete. Backlog item: a future revision could add `blog_post (id, title, slug, body, image_id, published_at)` plus CRUD; out of scope for the MVP.

## 5. Acceptance criteria (end-to-end)

- [ ] `frontend/src/views/BlogView.vue` no longer exists.
- [ ] `frontend/src/views/AdminBlogView.vue` no longer exists.
- [ ] `frontend/src/router/index.js` has no `/blog` or `/admin/blog` routes.
- [ ] `grep -r "BlogView\\|AdminBlogView\\|/blog\\|blog.vue\\|Blogi\\|Artikli pealkiri" frontend/` returns no results.
- [ ] Visiting `http://localhost:5173/blog` and `http://localhost:5173/admin/blog` both show the SPA's not-found state.
- [ ] No backend code or SQL references blog / articles.
