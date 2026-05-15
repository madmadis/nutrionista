# Frontend — Claude juhised

## Käsud

```sh
npm install       # Installi sõltuvused
npm run dev       # Arendusserver aadressil http://localhost:5173
npm run build     # Tootmisbuild
npm run preview   # Eelvaade tootmisbuildist
```

## Tehnoloogia

Vue 3 (Options API), Vue Router 4, Pinia, Tailwind CSS, Axios, Vite.

## Projekti struktuur

```
src/
├── main.js              # Rakenduse käivituspunkt
├── App.vue              # Juurkomponent
├── router/index.js      # Marsruudid
├── stores/              # Pinia andmehoidlad
├── views/               # Lehekomponendid (üks faas = üks view)
├── components/          # Korduvkasutatavad komponendid
└── assets/              # CSS ja staatilised failid
```

Tee alias: `@` → `src/`

## Komponendi struktuur (Options API)

**Kasutame Options API-t, mitte Composition API-t.** Täpsem dokumentatsioon: `docs/vue-komponendi-struktuur.md`

### `<script>` järjekord

```js
export default {
  name: 'KomponendNimi',
  components: { Komponent1 },
  props: { propNimi: { type: String, default: '' } },
  emits: ['event-midagi-juhtus'],
  data() { return { muutuja: '' } },
  computed: { arvutatudVäärtus() { return this.muutuja.toUpperCase() } },
  methods: { teeMiddagi() { ... } },
  beforeMount() { this.laeAndmed() },
}
```

### Olulised konventsioonid

- **Sündmused** algavad alati `event-` eesliitega — nt `event-modal-closed`, `event-city-selected`
- **Andmete laadimine** käib `beforeMount`-is, mitte `mounted`-is
- **Propid** antakse alla `:prop-nimi="..."` ja sündmusi kuulatakse `@event-nimi="..."`

## API päringute muster

Axios on registreeritud `app.config.globalProperties.$axios`-na — kasutatakse `this.$axios` kaudu.

Päringud käivad `.then()` / `.catch()` / `.finally()` ahelana. Iga päringu vastus suunatakse eraldi `handle`-meetodisse:

```js
methods: {
  getItems() {
    this.$axios.get('/api/items')
      .then((response) => this.handleGetItemsResponse(response.data))
      .catch((error) => this.handleGetItemsError(error))
      .finally()
  },
  handleGetItemsResponse(items) {
    this.items = items
  },
  handleGetItemsError(error) {
    this.errorMessage = error.response.data.message
  },
}
```

## Nimetamiskonventsioonid

- **Vaate failid**: PascalCase + `View` sufiks — `HomeView.vue`, `AdminBlogView.vue`
- **Komponentide failid**: PascalCase — `NavBar.vue`, `FooterBar.vue`
- **Route nimed**: camelCase + `Route` sufiks — `homeRoute`, `blogRoute`
- **Store export**: `use` + PascalCase + `Store` — `useAuthStore`, `useCartStore`

## Router

```js
{
  path: '/blog',
  name: 'blogRoute',
  component: BlogView,
}
```

## Pinia store-id

Composition API stiilis `defineStore`:

```js
import { ref, computed } from 'vue'
import { defineStore } from 'pinia'

export const useAuthStore = defineStore('auth', () => {
  const user = ref(null)
  const isLoggedIn = computed(() => user.value !== null)

  function login(userData) { user.value = userData }
  function logout() { user.value = null }

  return { user, isLoggedIn, login, logout }
})
```

## Koodistiil

Prettier: **ilma semikooloniteta**, ülakomad (`'`), 100-märgiline realaius.

## Keel

CLAUDE.md ja `docs/` kaustas olev dokumentatsioon peab alati olema **eestikeelne**.