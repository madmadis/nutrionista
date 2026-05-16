---
name: create-page-task
description: Generates a per-page implementation task at docs/tasks/task_page_<N>.md for one Nutrionista mockup page. Synthesizes the screen content (via the describe-mockup-page extractor), the canonical v2 data model, and the current Rev. 4.1 design spec into a concrete end-to-end punch list — Vue components, router entries, Pinia stores, Spring Boot endpoints, DTOs, schema/seed needs, and mockup-vs-spec divergences. Use when the user asks to "create a page task", "generate a task for page N", "build a task list to implement page N of the mockup", or invokes `/create-page-task <N>`. Argument is the 1-indexed page number (1–14).
---

# Create Page Task — Nutrionista

You are generating a per-page implementation task file. For one Balsamiq mockup page, produce a concrete, end-to-end task list at `docs/tasks/task_page_<N>.md` that another contributor can pick up and ship the page from.

## Invocation

The user supplies one argument: a 1-indexed page number (1–14). Examples: `/create-page-task 3`, `/create-page-task 12`. If the argument is missing, non-numeric, or out of range, ask the user which page (do not guess).

## Step 1 — Gather inputs (always run these in this order)

1. **Mockup content (UI authority).** Run the describe-mockup-page extractor for page N:
   ```bash
   .claude/skills/describe-mockup-page/.venv/bin/python \
     .claude/skills/describe-mockup-page/scripts/extract.py --page <N>
   ```
   Read everything: PDF wireframe lines, image placeholders, HTML structure, navigation edges (out), form fields, and the yellow-sticky annotations (filename, url, API, DTO, Response, Veateated).

2. **Spec (backend + schema authority).** Read `docs/2026-05-06-nutrionista-design_REV4.1.md`. The relevant sections are §3 stack, §5 schema, §6 auth, §7 API surface (incl. §7.1 cart explainer), §8 frontend routes/stores/admin, §10 DB workflow, §12 task split, §14 scope. Cite section numbers when you write "per the spec".

3. **Data model (table-shape authority).** When the spec is ambiguous, consult `docs/nutrionista_data_model_v2.xml` (Redgate source) and `docs/nutrionista_data_model_v2.pdf` (rendered ERD) for exact column names, types, and nullability.

4. **Mockup sources (visual context — read only when needed).** `docs/Nutrionista balsamiq.pdf` for visual layout; `docs/madis/nutrionista-mockup.html` for the Tailwind classes Balsamiq exported.

5. **Previous task files (shared-element ownership).** Read every `docs/tasks/task_page_*.md` that already exists. **First task to need a shared element owns it; later tasks reference back, never re-state it.** Shared elements typically include: `NavBar.vue`, `FooterBar.vue`, Vue Router setup, Pinia `authStore`, Pinia `cartStore`, Axios instance in `api.js`, CORS config, Tailwind tokens, `POST /api/login` endpoint, `AuthService` / `BCrypt` wiring, seed data in `3_import.sql`, the regenerated `2_create.sql` from v2. When in doubt, grep the existing task files for the element name before re-introducing it.

6. **Current codebase state (grounding).** Quickly inspect:
   - `frontend/src/views/` — note whether the target view file already exists (most do; some are cut-feature views the spec wants deleted — see §12).
   - `frontend/src/router/index.js`, `frontend/src/stores/`, `frontend/src/components/` — note what's already wired.
   - `backend/src/main/java/ee/nutrionista/` — currently only `NutrionistaApplication.java`. Anything else listed in the task is create-from-scratch.

## Step 2 — Synthesize the task file

Write `docs/tasks/task_page_<N>.md` with this structure. **Do not embed the raw describe-mockup-page output.** Be specific: real file paths, real class names, real field names. The reader should be able to copy identifiers out of the file straight into their IDE.

```markdown
# Task: Page <N> — <Estonian title> / <ENGLISH LABEL>

**Maps to:** `<filename>.vue` at `<url>` (HTML page id `<id>`)
**Spec sections:** §<comma-separated Rev. 4.1 sections>
**Depends on:** task_page_<M>.md — <what it provides> (or "None — page 1 owns the shared shell")

## 1. Frontend

### 1.1 Route
Single bullet describing the entry in `frontend/src/router/index.js`. Include the `meta` block (`requiresAdmin`, login redirect, `next` query param handling). Reference the spec's §8 routes table.

### 1.2 View component
- **Path:** `frontend/src/views/<File>.vue`.
- **Status:** create-from-scratch | edit-existing | **delete (cut feature per §14)**.
- **Layout:** top-down breakdown of every section in the mockup. For each section: heading copy (in Estonian), the data it renders, the source (endpoint / store / static text).
- **Form fields:** one bullet per `<input>` / `<select>` / `<textarea>` with v-model target, type, validation rules, and the placeholder/label text from the mockup.
- **Buttons:** one bullet per button with the visible label, the handler method name, and what it does (route push, store call, API call, etc.).
- **Image placeholders:** for each placeholder reported by describe-mockup-page, the actual source it should render from (`GET /api/nutrient-images/{id}` or a static asset).

### 1.3 Components needed
- **Existing** (in `frontend/src/components/`): list and confirm.
- **New:** path + one-line spec for any reusable component the page introduces (`<ProductCard>`, `<InteractionDot>`, `<QuantityStepper>`, etc.).

### 1.4 Store interactions
- For each Pinia store touched, list the calls: method name, when it fires, what it returns / mutates.

### 1.5 Visual notes
- Tailwind tokens used (cite §8 design-token table — `bg-primary`, `bg-secondary`, etc.).
- Anywhere the mockup uses inline hex that should be replaced with a token.

## 2. Backend

### 2.1 Endpoints
One entry per API call the page makes (cross-reference the yellow sticky AND spec §7). For each:
- **Method + path** — purpose.
- **Owner file:** `backend/src/main/java/ee/nutrionista/<package>/<File>.java`. Status: stub | create-from-scratch.
- **Request DTO:** Java class + fields + bean-validation annotations (`@NotBlank`, `@Min`, etc.).
- **Response DTO:** Java class + fields. If the mockup sticky's DTO disagrees with §7, **flag under §4 divergence** and recommend a resolution.
- **Service logic:** numbered steps (reads, writes, transactional boundary, snapshotting, cascade-deletes).
- **Repository methods:** Spring Data JPA derived queries or `@Query` strings.

### 2.2 Error handling
For each line in the sticky's Veateated:
- HTTP status, exception type, `@ControllerAdvice` handler, the user-facing message (kept in Estonian).

### 2.3 CORS / Swagger / cross-cutting
Reference back to the task that owns CORS / Swagger setup. Only add a new entry here if this page introduces something new.

## 3. Database

### 3.1 Schema reads
Tables read by this page, listing the v2 columns consumed (so the entity / DTO mapping is unambiguous).

### 3.2 Schema writes
Tables written + the transactional boundary (one transaction or several).

### 3.3 Seed data
Rows that must exist in `docs/database/3_import.sql` for this page to function (color codes, courier rows, demo users, property type codes, etc.). Reference back to a previous task if the seed item is already owned there.

### 3.4 Schema gaps
Any column or table the mockup needs that v2 doesn't have. Common examples surfaced so far: `user.email` (mockup uses email-as-login; v2 only has username), `user.first_name` / `last_name`, `contact.message`. For each gap, recommend either a v2.1 migration **or** a mockup amendment (one side has to give).

## 4. Mockup-vs-spec divergence
A bulleted list of every place the mockup contradicts the Rev. 4.1 spec. For each:
- **Mockup says:** …
- **Spec says:** … (cite §)
- **Recommendation:** …

Examples to watch for (these recur across pages):
- Login uses `email`, spec uses `username`.
- "Loo uus konto" button exists, spec §8 says "no `/register` route".
- Cart is shown as anonymous, spec §5 / §7.1 makes it require login.
- Footer links Blogi / KKK / Kontakt — only Kontakt survives §14; Blogi cut; KKK static-only stretch goal.
- "Tee vitamiinitest" CTA — quiz is cut in §14.

## 5. Acceptance criteria (end-to-end)
A checklist of independently testable outcomes. Each item is a verifiable behaviour, not a code task. Examples:
- [ ] Navigating to `<url>` while not logged in redirects to `/login?next=<url>`.
- [ ] `GET <endpoint>` against a freshly seeded DB returns the expected JSON shape (paste a sample).
- [ ] Submitting the form with empty fields shows "Palun täitke kõik väljad".
- [ ] After a successful submit, the SPA navigates to `<next-route>` and the new row is visible in `<admin page>`.
```

## Step 3 — Confirm and summarise

After writing the file:
1. Run `wc -l docs/tasks/task_page_<N>.md` and print: `Wrote docs/tasks/task_page_<N>.md (<X> lines)`.
2. In 2–3 sentences, tell the user what's in scope on that page and the most consequential mockup-vs-spec divergence the task surfaces. Do not dump the file content.

## Operating rules (apply to every page)

- **No raw mockup dump in the output file.** Synthesize.
- **Cross-reference back, don't duplicate.** When a step is "use the NavBar from task_page_1", say exactly that and stop.
- **Edit-in-place over create-from-scratch** when the target file already exists. Note the distinction explicitly per file.
- **Cut-feature views (per spec §14) are a delete task, not an implement task.** If page N maps to `BlogView.vue` / `QuizView.vue` / `WishlistView.vue` / `OrderHistoryView.vue` / `AdminBlogView.vue` / `AdminFaqView.vue` / `ProfileView.vue`, the task is: delete the file, remove the route, remove links/buttons elsewhere that point at it. Keep §4 divergence so the reader sees why.
- **Estonian labels stay Estonian.** UI text from the mockup is in Estonian; preserve it in the task body so the reader can match strings 1:1 against the mockup. Section headings can be English.
- **Don't invent features.** If the screen wants something the spec + v2 model don't support, list it under §3.4 schema gaps or §4 divergence — do not silently design it.
- **No backwards-compat hedging.** The backend is a skeleton; the cleanest implementation wins. No "// for compatibility with the old API" notes.
