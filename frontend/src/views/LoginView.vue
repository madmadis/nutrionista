<template>
  <div class="min-h-screen flex flex-col">
    <header class="w-full bg-[#e0ffe0] border-b border-[#dddddd]">
      <div class="max-w-7xl mx-auto px-4 md:px-6 py-4 flex items-center justify-between">
        <RouterLink to="/" class="text-xl font-bold text-[#333333]">Nutrionista</RouterLink>
        <RouterLink to="/" class="text-[#555555] hover:text-[#e6007a]">Avaleht</RouterLink>
      </div>
    </header>

    <main class="max-w-7xl mx-auto px-4 md:px-6 py-20 flex justify-center flex-1">
      <div class="bg-white rounded-xl shadow p-8 w-full max-w-md border border-[#dddddd]">
        <h1 class="text-2xl font-bold text-[#333333] mb-8 text-center">Sisselogimine</h1>

        <div v-if="error" class="bg-red-50 border border-red-200 rounded-lg p-4 text-red-700 text-sm mb-6">
          {{ error }}
        </div>

        <div class="space-y-4">
          <input
            v-model="email"
            type="text"
            placeholder="E-posti aadress"
            class="border border-[#dddddd] rounded-lg px-4 py-3 w-full focus:ring-2 focus:ring-[#e6007a] outline-none"
          />
          <input
            v-model="password"
            type="password"
            placeholder="Parool"
            class="border border-[#dddddd] rounded-lg px-4 py-3 w-full focus:ring-2 focus:ring-[#e6007a] outline-none"
          />
          <button
            @click="login"
            class="bg-[#e6007a] text-white px-4 py-3 rounded-lg shadow hover:opacity-90 w-full font-semibold"
          >
            Logi sisse
          </button>
        </div>

        <div class="flex items-center my-6">
          <div class="flex-1 border-t border-[#dddddd]"></div>
          <span class="px-4 text-[#666666] text-sm">või</span>
          <div class="flex-1 border-t border-[#dddddd]"></div>
        </div>

        <button
          @click="register"
          class="bg-[#90ee90] text-[#333333] px-4 py-3 rounded-lg shadow hover:opacity-90 w-full font-semibold border border-[#7cfc00]"
        >
          Loo uus konto
        </button>

        <div class="mt-6 text-center text-xs text-[#999999]">
          Admin demo: admin@nutrionista.ee / admin123
        </div>
      </div>
    </main>
  </div>
</template>

<script>
import { RouterLink } from 'vue-router'
import { useAuthStore } from '../stores/auth.js'

export default {
  name: 'LoginView',
  components: { RouterLink },
  data() {
    return {
      email: '',
      password: '',
      error: '',
      loading: false,
    }
  },
  computed: {
    auth() { return useAuthStore() },
  },
  methods: {
    login() {
      this.error = ''
      if (!this.email || !this.password) {
        this.error = 'Palun sisesta e-post ja parool'
        return
      }
      this.loading = true
      this.auth.login(this.email, this.password)
        .then((res) => {
          if (res.role === 'ADMIN') {
            this.$router.push('/admin/nutrients')
          } else {
            this.$router.push('/profile')
          }
        })
        .catch((e) => {
          this.error = e.response?.data?.message || 'Vale kasutajanimi või parool'
        })
        .finally(() => { this.loading = false })
    },
    register() {
      this.error = ''
      if (!this.email || !this.password) {
        this.error = 'Palun sisesta e-post ja parool'
        return
      }
      this.loading = true
      this.auth.register(this.email, this.password)
        .then(() => this.$router.push('/profile'))
        .catch((e) => {
          this.error = e.response?.data?.message || 'Registreerimine ebaõnnestus'
        })
        .finally(() => { this.loading = false })
    },
  },
}
</script>
