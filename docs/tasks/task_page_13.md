# Task: Page 13 — Tagasiside & Kontakt / CONTACT PAGE

**Maps to:** `ContactView.vue` at `/contact` (HTML page id `contact`)
**Spec sections:** §5 schema (`contact`), §6 auth (contact requires login), §7 API (`/api/contacts`, `/api/admin/contacts`), §14 (back-in-scope in Rev. 4.1)
**Depends on:** task_page_1.md (shell, `User` entity), task_page_2.md (login — required because `contact.user_id` is NOT NULL)

The contact form is back in scope in Rev. 4.1 because the v2 schema models a `contact` table. The form itself is minimal (the v2 schema only carries `user_id`, `first_name`, `last_name`); the mockup adds an e-mail and a message body that need either a small migration or graceful UI omission.

## 1. Frontend

### 1.1 Route
File: `frontend/src/router/index.js`.
- `/contact` route already exists. **Add `meta: { requiresLogin: true }`** (the router guard redirects to `/login?next=/contact`).

### 1.2 View component
- **Path:** `frontend/src/views/ContactView.vue`.
- **Status:** rewrite-existing.
- **Layout (two columns on `md+`):**
  - **Left column — "Saada meile tagasisidet" (form):**
    - H2 "Saada meile tagasisidet".
    - Label "Eesnimi:" + `<input v-model="form.firstName">` (the mockup says "Nimi" — single field; we split per the v2 `contact` table; see §4).
    - Label "Perekonnanimi:" + `<input v-model="form.lastName">`.
    - **(Optional)** Label "E-post:" + `<input v-model="form.email">` and Label "Sõnum:" + `<textarea v-model="form.message">` — only render if §3.4 option A (schema extension) is chosen.
    - Submit button "Saada tagasiside" (primary).
    - Success state: replace the form with `<p>Aitäh! Võtame ühendust.</p>`.
  - **Right column — "Võta meiega ühendust" (static info):**
    - H2 "Võta meiega ühendust".
    - `<p>E-post: info@nutrionista.ee</p>`
    - `<p>Telefon: +372 123 4567</p>`
    - `<p>Aadress: Näidis tänav 1, Tallinn, Eesti</p>`
    - **Drop the "Live Chat (tulevikus)" block** — chat is cut in §14.
- **Submit handler:**
  ```js
  await api.post('/contacts', { userId: auth.userId, firstName: form.firstName, lastName: form.lastName /* + email/message if schema extended */ })
  this.submitted = true
  ```

### 1.3 Components needed
- Existing: NavBar, FooterBar.
- New: none.

### 1.4 Store interactions
- Read: `authStore.userId` for the submission payload.
- No write to a store.

### 1.5 Visual notes
- Two-column: `grid md:grid-cols-2 gap-8`.
- Form card: `bg-surface border border-divider rounded-lg p-6`.
- Pre-fill the form `firstName`/`lastName` from authStore on mount **only if** §3.4 option A has been taken and the user's name is known; otherwise leave empty.

## 2. Backend

### 2.1 Endpoints
| Method | Path | Purpose | Status |
|---|---|---|---|
| `POST` | `/api/contacts` | Insert one `contact` row for the logged-in user | create-from-scratch |
| `GET` | `/api/admin/contacts` | Admin inbox list | create-from-scratch (paired with admin page) |

#### ContactController (NEW)
`backend/src/main/java/ee/nutrionista/contact/ContactController.java`
```java
@RestController @RequiredArgsConstructor
public class ContactController {
    private final ContactService service;

    @PostMapping("/api/contacts")
    public ContactDto create(@Valid @RequestBody CreateContactDto body) { return service.create(body); }

    @GetMapping("/api/admin/contacts")
    public List<ContactDto> list() { return service.list(); }
}
```

#### DTOs
- `CreateContactDto`: `@NotNull Long userId, @NotBlank String firstName, @NotBlank String lastName` (+ optional `email`, `message` if §3.4 option A).
- `ContactDto`: `Long id, Long userId, String username, String firstName, String lastName` (+ `email`, `message` if applicable).

#### Service
- `create(CreateContactDto body)` — find the user, build a `Contact` entity, save, return DTO.
- `list()` — `contactRepository.findAllByOrderByIdDesc()` mapped to DTOs.

#### Repository
- `ContactRepository extends JpaRepository<Contact, Long>`:
  - `List<Contact> findAllByOrderByIdDesc();`

#### Entity
- `Contact` (`@Entity @Table(name = "contact")`):
  ```java
  @Id @GeneratedValue Long id;
  @ManyToOne(optional = false) @JoinColumn(name = "user_id") User user;
  @Column(name = "first_name", nullable = false) String firstName;
  @Column(name = "last_name",  nullable = false) String lastName;
  // optional: email, message columns if §3.4 option A
  ```

### 2.2 Error handling
- 400 on validation failure → already handled by `ApiExceptionHandler`.
- 404 on unknown user → handled.
- No specific Veateated in the mockup sticky.

### 2.3 CORS / Swagger
Inherited. Add `@Operation` summaries.

### 2.4 Admin page glue (the admin inbox)
- Add `/admin/contacts` route in `router/index.js` with `meta: { requiresAdmin: true }`.
- Create `frontend/src/views/AdminContactsView.vue` rendering a simple table: `#id | Kasutaja | Eesnimi | Perekonnanimi | (Email | Sõnum if schema extended)`. No actions beyond viewing.
- Wire NavBar admin dropdown to include "Kontaktid" → `/admin/contacts` (also called out in task_page_1.md §1.3 as a future link).

## 3. Database

### 3.1 Schema reads
- `contact`, `"user"`.

### 3.2 Schema writes
- `contact` (INSERT).

### 3.3 Seed data
- Optional: pre-seed one or two contact rows so `/admin/contacts` isn't empty on first boot. Skip if the demo will create one live.

### 3.4 Schema gaps
**The v2 `contact` table is `(id, user_id, first_name, last_name)` — no `email`, no `message`.** The mockup form has both. **Pick one with the team:**

- **(A) Mockup wins (Recommended for completeness).** Add a v2.1 migration `V18__extend_contact.sql`:
  ```sql
  ALTER TABLE contact
    ADD COLUMN email   VARCHAR(255),
    ADD COLUMN message TEXT;
  ```
  Update the entity, DTOs, controller, frontend form. Estimated effort: 30 minutes.

- **(B) Schema wins.** UI form collects only first/last name. The submission is essentially a "kasutaja võttis meiega ühendust" ping; the admin must reach out by username. Less useful but matches v2 literally.

The Rev. 4.1 spec §12 names this as an explicit pair-point ("`contact.message` column" decision). Document the choice in the file's top comment and in §12 of the spec.

## 4. Mockup-vs-spec divergence

- **Mockup form has `Nimi` (single name field), `E-post`, `Sõnum`** vs. v2 `contact(first_name, last_name)`. **Resolution:** see §3.4. Recommend option A.
- **Mockup has "Live Chat (tulevikus)" block** — explicitly cut in §14. **Resolution:** delete the block.
- **Static "Võta meiega ühendust" contact info** — keep as-is, it's static text typed in the component.
- **No login requirement on the mockup** — spec §5 makes `contact.user_id` NOT NULL, so login is required. **Resolution:** route guard redirects anonymous users to `/login?next=/contact`. The mockup is wrong on this.

## 5. Acceptance criteria (end-to-end)

- [ ] `curl -X POST -H 'Content-Type: application/json' -d '{"userId":1,"firstName":"Tarmo","lastName":"Tamm"}' http://localhost:8080/api/contacts | jq` returns `{id, userId, username, firstName, lastName}`.
- [ ] `curl -X POST -H 'Content-Type: application/json' -d '{}' http://localhost:8080/api/contacts` returns 400 with field errors.
- [ ] `curl -s http://localhost:8080/api/admin/contacts | jq 'length'` returns the count after submission(s).
- [ ] In the browser, anonymous visit to `/contact` redirects to `/login?next=/contact`.
- [ ] Submitting the form shows the success message; refreshing the page returns the form to its empty state (no leak).
- [ ] Logging in as `madis`, visiting `/admin/contacts` shows the submission row.
- [ ] No Live Chat block visible.
- [ ] `/swagger-ui.html` shows `POST /api/contacts` and `GET /api/admin/contacts`.
