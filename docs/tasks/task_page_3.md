# Task: Page 3 — Vitamiinitest / QUIZ PAGE (CUT — DELETE TASK)

**Maps to:** `QuizView.vue` at `/quiz` (HTML page id `quiz`)
**Spec sections:** §14 (out of scope), §12 task split (cleanup)
**Depends on:** task_page_1.md (router cleanup) — quiz route removal is already noted there

The vitamin quiz is **explicitly cut** in spec §14 — "Vitamiinitest + personaalne vitamiiniprofiil. Requires question/option/result tables, recommendation rules engine, profile UI. ~20–30 hours." This task documents the deletion, not an implementation.

## 1. Frontend (delete-only)

### 1.1 Route
File: `frontend/src/router/index.js`.
- **Delete** the `/quiz` route block (already called out in task_page_1.md §1.1). No replacement.

### 1.2 View component
- **Path:** `frontend/src/views/QuizView.vue`.
- **Action:** **`rm frontend/src/views/QuizView.vue`**.
- Also grep the codebase for `QuizView`, `/quiz`, `quiz.vue` and remove every remaining reference. As of this writing, the only inbound reference is the "Tee vitamiinitest" hero button in `HomeView.vue` — task_page_1.md §1.10 already replaces that CTA with "Ava pood" → `/shop`.

### 1.3 Components needed
None.

### 1.4 Store interactions
None.

### 1.5 Visual notes
The mockup wireframe contains 5 questions (piimatooted, taimetoit/vegan, päike, väsimus, kroonilised haigused) with radio inputs and a textarea — none of this gets built. Capture the questionnaire in the spec backlog (§14) for a post-MVP iteration so the content isn't lost.

## 2. Backend
None. No endpoints, no DTOs, no entities.

## 3. Database
None. No `quiz_question` / `quiz_option` / `vitamin_profile` tables are added.

## 4. Mockup-vs-spec divergence

- **Mockup says:** Quiz is a primary feature (Vitamiinitest CTA on the landing page, dedicated screen, "Esita vastused" submit).
- **Spec says:** Cut entirely (§14). The data model would need `quiz_question`, `quiz_option`, `vitamin_profile`, plus a recommendation rules engine — too large for the 2-week sprint.
- **Recommendation:** Delete. If a post-MVP team wants to revive it, the mockup is the design reference and §14 is the rationale.

## 5. Acceptance criteria (end-to-end)

- [ ] `frontend/src/views/QuizView.vue` no longer exists.
- [ ] `frontend/src/router/index.js` has no `/quiz` route entry.
- [ ] `grep -r "QuizView\\|/quiz\\|quiz.vue\\|Vitamiinitest\\|Tee vitamiinitest" frontend/ ` returns no results (or only in CHANGELOG-style comments noting the deletion).
- [ ] Visiting `http://localhost:5173/quiz` shows the SPA's 404 / not-found state (Vue Router default behaviour with an unmatched route).
- [ ] No backend code references the quiz; no SQL table mentions quiz.
- [ ] `git log` shows a commit "feat(scope): cut Vitamiinitest per spec §14" or similar.
