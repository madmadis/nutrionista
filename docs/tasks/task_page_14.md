# Task: Page 14 — KKK / FAQ PAGE (STATIC STRETCH GOAL)

**Maps to:** `FaqView.vue` at `/faq` (HTML page id `faq`)
**Spec sections:** §14 (stretch goal — "A static `FaqView` (content typed in code, no DB) is acceptable as a Day 12–13 stretch goal")
**Depends on:** task_page_1.md (shell, Tailwind tokens, router)

KKK is partially cut: there is no `faq` table, no admin CRUD, no `AdminFaqView`. The spec §14 allows a **static** `FaqView` whose content lives in the component as a JavaScript constant. Cheap to implement; useful for the demo's "we cover the basics" line.

## 1. Frontend

### 1.1 Route
File: `frontend/src/router/index.js`.
- `/faq` route already exists; keep as-is (no `meta` flag — public).
- **Delete** the `/admin/faq` route and its view (`AdminFaqView.vue`) — already listed in task_page_1.md §1.1 and task_page_12.md §1.2.

### 1.2 View component
- **Path:** `frontend/src/views/FaqView.vue`.
- **Status:** rewrite-existing.
- **Layout:**
  - H1 "Korduma Kippuvad Küsimused".
  - Section per category (4 sections from the mockup): "Vitamiinide kohta", "Annuste kohta", "Raseduse ja imetamise ajal", "Tellimise kohta".
  - Each Q&A as a `<details><summary>` (collapsible by default, no JS state) so the page is fast and the user can scan headings.
  - All content typed inline as a JS constant `faqData: Array<{ category: string, items: Array<{ q: string, a: string }> }>`. Copy the wording verbatim from the mockup.
- **No data fetch.** No store interaction. No backend call. The page renders the constant.

### 1.3 Components needed
- Existing: NavBar, FooterBar.
- New: none. Native `<details>` handles the toggle.

### 1.4 Store interactions
None.

### 1.5 Visual notes
- Section headings: `text-xl font-bold mt-8 mb-2`.
- `<details>`: `border border-divider rounded-lg p-4 my-2 cursor-pointer`.
- `<summary>`: `font-medium text-text`; remove the default disclosure triangle with `summary::-webkit-details-marker { display: none; }` and prepend a small chevron icon.
- Answer text: `text-muted mt-2`.

### 1.6 Content (typed verbatim from the mockup)

```js
const faqData = [
  { category: 'Vitamiinide kohta', items: [
    { q: 'Mis on vitamiinid ja miks need on olulised?',
      a: 'Vitamiinid on orgaanilised ühendid, mida organism vajab normaalseks kasvuks ja toimimiseks. Need on olulised ainevahetuses, immuunsüsteemi toetamisel ja rakkude kaitsmisel.' },
    { q: 'Kuidas valida õigeid vitamiine?',
      a: 'Õigete vitamiinide valik sõltub teie individuaalsetest vajadustest, toitumisest ja elustiilist. Soovitame konsulteerida arsti või toitumisnõustajaga.' },
  ]},
  { category: 'Annuste kohta', items: [
    { q: 'Millised on soovitatavad vitamiiniannused?',
      a: 'Soovitatavad annused varieeruvad sõltuvalt vitamiinist, vanusest, soost ja tervislikust seisundist. Järgige alati toote etiketil olevaid juhiseid või konsulteerige spetsialistiga.' },
    { q: 'Kas vitamiine on võimalik üle doseerida?',
      a: 'Jah, teatud vitamiinide (eriti rasvlahustuvate) liigne tarbimine võib olla kahjulik. Olge ettevaatlik ja ärge ületage soovitatud annuseid.' },
  ]},
  { category: 'Raseduse ja imetamise ajal', items: [
    { q: 'Milliseid vitamiine on raseduse ajal vaja?',
      a: 'Raseduse ajal on eriti olulised foolhape, raud, kaltsium ja D-vitamiin. Enne vitamiinide võtmist konsulteerige kindlasti oma arstiga.' },
    { q: 'Kas imetamise ajal on vitamiinide võtmine ohutu?',
      a: 'Enamik vitamiine on imetamise ajal ohutud, kuid alati on soovitatav konsulteerida arstiga, et tagada nii ema kui ka lapse heaolu.' },
  ]},
  { category: 'Tellimise kohta', items: [
    { q: 'Kuidas ma saan tellimust esitada?',
      a: 'Saate tellimuse esitada meie veebipoes, lisades soovitud tooted ostukorvi ja järgides maksejuhiseid.' },
    { q: 'Millised on tarneajad ja -kulud?',
      a: 'Tarneajad ja -kulud sõltuvad teie asukohast ja valitud tarneviisist. Täpsema info leiate meie tarneinfo lehelt.' },
  ]},
]
```

(Note: the last answer mentions a "tarneinfo leht" that doesn't exist. Either change the answer to "Info leiate kassa lehelt" or build a Tarneinfo page later. For the MVP, just edit the answer.)

## 2. Backend
None. No endpoints, no DTOs, no entities.

## 3. Database
None. No `faq_category` / `faq_item` tables.

## 4. Mockup-vs-spec divergence

- **Mockup says:** Full FAQ page with 4 categories and 8+ questions; mockup also implies an admin FAQ CRUD via `/admin/faq` and `AdminFaqView.vue`.
- **Spec says:** Static-only (§14). No admin CRUD, no DB.
- **Recommendation:** Implement as static (this task). Delete `AdminFaqView.vue` + the `/admin/faq` route. If a future iteration needs editable FAQs, add `faq (id, category, question, answer, sort_order)`.

- **Mockup footer links here** ("KKK") — only Kontakt survived the §14 cut in task_page_1's FooterBar. **Resolution:** the footer should either (a) keep only Kontakt (current task_page_1 plan) or (b) re-add a KKK footer link if the team treats this stretch goal as in-scope. Default: footer stays as task_page_1 specified; the FAQ page is discoverable only via direct URL or future NavBar additions.

## 5. Acceptance criteria (end-to-end)

- [ ] `frontend/src/views/AdminFaqView.vue` no longer exists.
- [ ] `frontend/src/router/index.js` has no `/admin/faq` route.
- [ ] Opening `http://localhost:5173/faq` renders the 4 sections + Q&A pairs from the constant. Clicking a question expands the answer; clicking again collapses it. Multiple questions can be open simultaneously (native `<details>` behaviour).
- [ ] No network requests are made by the page (DevTools Network tab shows zero `/api` calls).
- [ ] `grep -r "AdminFaqView\\|/admin/faq" frontend/` returns no results.
- [ ] All Estonian text from the mockup is reproduced exactly; the "tarneinfo leht" answer is either corrected or backed by a real page.
