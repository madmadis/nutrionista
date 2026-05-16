# Task: Page 2 — Sisselogimine / LOGIN PAGE

**Maps to:** `LoginView.vue` at `/login` (HTML page id `login`)
**Spec sections:** §3 stack, §5 schema (`"user"`, `role`), §6 auth, §7 API (`POST /api/login`), §8 frontend (Pinia authStore, login route), §12 task split
**Depends on:** task_page_1.md — shared shell (App.vue, NavBar, FooterBar, Tailwind tokens, api.js, router, authStore skeleton, `"user"`/`role` tables + seed)

This page wires the `POST /api/login` endpoint into the `authStore` set up by task_page_1. After this task, every other page that says "requires login" works.

## 1. Frontend

### 1.1 Route
File: `frontend/src/router/index.js` (added in task_page_1).
- Route `/login` already exists; **no `meta: { requiresLogin: true }`** on this one (it's the redirect target).
- Honour `?next=<path>` from the route guard: on successful login, the view pushes to `route.query.next` if present, otherwise `/admin` for admins or `/` for users.

### 1.2 View component
- **Path:** `frontend/src/views/LoginView.vue`.
- **Status:** rewrite-existing (the file is currently a placeholder).
- **Layout (matches mockup):**
  - H1 "Sisselogimine / Registreerimine" — but the actual form is login-only. **No "Loo uus konto" button** (cut — see §4).
  - Login form (single `<form @submit.prevent="onSubmit">`):
    - Label "E-posti aadress" + `<input type="email" v-model="form.username">` — see §4 about email-vs-username naming.
    - Label "Parool" + `<input type="password" v-model="form.password">`.
    - Submit button "Logi sisse" (primary background).
  - Error banner (`v-if="errorMessage"`) above the submit button — red, rounded, dismissible.
- **Buttons:**
  - "Logi sisse" → `onSubmit()` calls `authStore.login(form.username, form.password)`, then navigates per `route.query.next || (auth.isAdmin ? '/admin' : '/')`.

### 1.3 Components needed
- Existing: NavBar (task_page_1), FooterBar (task_page_1).
- New: none for this page.

### 1.4 Store interactions
- `authStore.login(username, password)` — already specified in task_page_1 §1.5. Implement here:
  ```js
  async function login(username, password) {
    const res = await api.post('/login', { username, password })
    userId.value = res.data.userId
    username.value = res.data.username
    role.value = res.data.role
    localStorage.setItem('userId', userId.value)
    localStorage.setItem('username', username.value)
    localStorage.setItem('role', role.value)
    return res.data
  }
  ```
- After login, also call `cartStore.fetch(userId.value)` so the cart icon's badge populates immediately. Put this in the LoginView's `onSubmit` handler, not in the store, to keep the store dependency-free.

### 1.5 Visual notes
- Centre the form: `max-w-md mx-auto py-12` container; `bg-surface` card with `border-divider` border.
- Submit button: `bg-primary text-white`.
- Error banner: `bg-red-100 text-red-800 border border-red-200`.

## 2. Backend

### 2.1 Endpoints
| Method | Path | Purpose | Status |
|---|---|---|---|
| `POST` | `/api/login` | BCrypt-verify the seeded user, return `{userId, username, role}` | create-from-scratch |

#### AuthController (NEW)
`backend/src/main/java/ee/nutrionista/auth/AuthController.java`

```java
@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class AuthController {
    private final AuthService authService;

    @PostMapping("/login")
    public LoginResponseDto login(@Valid @RequestBody LoginDto body) {
        return authService.login(body);
    }
}
```

#### DTOs
- **`LoginDto`** (record): `String username, String password`, both `@NotBlank`. (The mockup sticky uses `email` — we use `username` per spec §5 and the v2 schema. See §4.)
- **`LoginResponseDto`** (record): `Long userId, String username, String role`. (The mockup adds `firstName`/`middleName`/`lastName`; we omit them — see §4.)

#### Service
`AuthService.login(LoginDto body)`:
1. `User user = userRepository.findByUsername(body.username()).orElseThrow(BadCredentialsException::new);`
2. `if (!BCrypt.checkpw(body.password(), user.getPasswordHash())) throw new BadCredentialsException();`
3. `return new LoginResponseDto(user.getId(), user.getUsername(), user.getRole().getName());`

Dependency: `org.mindrot:jbcrypt:0.4` on the Gradle classpath (spec §6).

#### Repository
- `UserRepository extends JpaRepository<User, Long>`
  - `Optional<User> findByUsername(String username);`
- `RoleRepository extends JpaRepository<Role, Integer>` (Integer because `id` is `SERIAL`).

#### Entities (owned here)
- `User` (`@Entity @Table(name = "\"user\"")` — the quoted name is required because `user` is a reserved word):
  ```java
  @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
  @Column(unique = true, nullable = false, length = 50) private String username;
  @Column(name = "password_hash", nullable = false, length = 60) private String passwordHash;
  @Column(name = "created_at", nullable = false) private Instant createdAt;
  @ManyToOne(optional = false) @JoinColumn(name = "role_id") private Role role;
  @PrePersist void prePersist() { createdAt = Instant.now(); }
  ```
- `Role` (`@Entity @Table(name = "role")`): id, name.

### 2.2 Error handling
Per the mockup sticky Veateated:
- **400 Bad Request — email või parool puudub** → `MethodArgumentNotValidException` caught by the `ApiExceptionHandler` from task_page_1, response `{"error": "Palun täitke kõik väljad"}`.
- **401 Unauthorized — vale email või parool** → `BadCredentialsException` mapped to 401 in `ApiExceptionHandler`, response `{"error": "Vale email või parool"}`. Add:
  ```java
  @ExceptionHandler(BadCredentialsException.class)
  public ResponseEntity<Map<String, String>> badCredentials() {
      return ResponseEntity.status(401).body(Map.of("error", "Vale email või parool"));
  }
  ```
- **200 OK** — the response DTO above.

### 2.3 CORS / Swagger
- CORS already configured in task_page_1; `/api/login` is covered by `/api/**`.
- Add `@Operation(summary = "User login (UI role-gate only)")` to the controller for clearer Swagger output.

## 3. Database

### 3.1 Schema reads
- `"user"` (id, username, password_hash, role_id)
- `role` (id, name)

### 3.2 Schema writes
None — login is read-only.

### 3.3 Seed data
Inherited from task_page_1 §3.3. Concretely, the seed inserts must include:
```sql
INSERT INTO role (name) VALUES ('ADMIN'), ('USER');
-- BCrypt hashes generated with: BCrypt.hashpw('demo', BCrypt.gensalt(10))
-- Same plaintext for all demo accounts — fine for a class demo, never for production.
INSERT INTO "user" (username, password_hash, role_id) VALUES
  ('madis',  '<bcrypt-hash>', (SELECT id FROM role WHERE name='ADMIN')),
  ('kaili',  '<bcrypt-hash>', (SELECT id FROM role WHERE name='ADMIN')),
  ('rain',   '<bcrypt-hash>', (SELECT id FROM role WHERE name='ADMIN')),
  ('tarmo',  '<bcrypt-hash>', (SELECT id FROM role WHERE name='USER'));
```

### 3.4 Schema gaps
**Email-as-login.** The mockup sticky's `LoginDto` uses `"email":"tarmo.tamm@mail.ee"` and the `LoginResponseDto` returns `firstName`/`middleName`/`lastName`. The v2 `"user"` table has neither `email` nor name columns.

Two options — **pick one explicitly with the team before implementing**:
- **(A) Mockup wins.** Add a v2.1 migration `V17__add_user_profile_columns.sql` with `ALTER TABLE "user" ADD COLUMN email VARCHAR(255) UNIQUE, ADD COLUMN first_name VARCHAR(255), ADD COLUMN middle_name VARCHAR(255), ADD COLUMN last_name VARCHAR(255)`. Update the entity, DTO, seed, NavBar display name. Login lookup switches to `findByEmail`.
- **(B) Spec wins (Recommended for the 2-week MVP).** Keep the `"user"` table as-is. The login form label stays "E-posti aadress" but the backend treats it as `username`. The seed uses email-shaped usernames (`tarmo.tamm@mail.ee`) so it looks right in the UI. The login response omits `firstName`/`middleName`/`lastName`. NavBar shows `username`. Add a comment in the seed explaining the alias.

Document the choice in the file's top comment and update both task_page_1 (NavBar) and task_page_4 (Profile delete) accordingly.

## 4. Mockup-vs-spec divergence

- **"Loo uus konto" button → `profile.vue`** — spec §8 "There is **no `/register` route**". **Resolution:** delete the button from the mockup-faithful layout. The H1 keeps "Sisselogimine / Registreerimine" only if the team prefers; clearer is to change it to "Sisselogimine".
- **Submit goes to `profile.vue`** — `ProfileView` is cut (§14). **Resolution:** redirect to `?next=<path>` (preserved by task_page_1 router guard) or `/` for users / `/admin` for admins.
- **Login key is `email`** — see §3.4 above.
- **Response includes `firstName`/`middleName`/`lastName`** — see §3.4 above.
- **Bearer-token Axios interceptor** — already removed in task_page_1; flag here so the reader doesn't reintroduce it.

## 5. Acceptance criteria (end-to-end)

- [ ] `curl -i -X POST -H 'Content-Type: application/json' -d '{"username":"madis","password":"demo"}' http://localhost:8080/api/login` returns `200 OK` with body `{"userId":1,"username":"madis","role":"ADMIN"}`.
- [ ] Same request with wrong password returns `401` and body `{"error":"Vale email või parool"}`.
- [ ] Empty body returns `400` with `{"error":"Palun täitke kõik väljad"}` (or the field-level errors from the global handler — confirm wording).
- [ ] In the browser, navigating to `/cart` while logged out redirects to `/login?next=/cart`. After submitting the form successfully, the SPA navigates straight to `/cart`.
- [ ] After logging in as `madis`, the NavBar shows "Logi välja" and the admin dropdown (per task_page_1 §1.3).
- [ ] `localStorage` now holds `userId` / `username` / `role`; **no `token` key**.
- [ ] Reloading the browser keeps the user logged in (authStore rehydrates from `localStorage`).
- [ ] Clicking "Logi välja" clears the keys and returns NavBar to the anonymous state.
- [ ] `/swagger-ui.html` shows `POST /api/login` with the documented DTOs.
