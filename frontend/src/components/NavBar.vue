<template>
  <header class="w-full bg-[#e0ffe0] border-b border-[#dddddd]">
    <div class="max-w-7xl mx-auto px-4 md:px-6 py-4 flex items-center justify-between">
      <RouterLink to="/" class="text-xl font-bold text-[#333333]">Nutrionista</RouterLink>
      <nav class="flex gap-6 items-center">
        <RouterLink to="/" class="text-[#555555] hover:text-[#e6007a]">Avaleht</RouterLink>
        <RouterLink to="/shop" class="text-[#555555] hover:text-[#e6007a]">Tooted</RouterLink>
        <RouterLink to="/cart" class="text-[#555555] hover:text-[#e6007a] relative">
          Ostukorv
          <span v-if="cart.count > 0" class="absolute -top-2 -right-4 bg-[#e6007a] text-white text-xs rounded-full w-5 h-5 flex items-center justify-center">{{ cart.count }}</span>
        </RouterLink>
        <template v-if="auth.isAdmin">
          <RouterLink to="/profile" class="text-[#555555] hover:text-[#e6007a]">Profiil</RouterLink>
          <div class="relative">
            <button @click="showAdmin = !showAdmin" class="text-[#e6007a] font-semibold hover:opacity-80 flex items-center gap-1">
              Admin <span class="text-xs">▼</span>
            </button>
            <div v-if="showAdmin" class="absolute top-full right-0 mt-2 bg-white border border-[#dddddd] rounded-lg shadow-lg py-2 min-w-[180px] z-50">
              <RouterLink @click="showAdmin = false" to="/admin/nutrients" class="block px-4 py-2 text-sm text-[#333333] hover:bg-pink-50">Vitamiinid</RouterLink>
              <RouterLink @click="showAdmin = false" to="/admin/blog" class="block px-4 py-2 text-sm text-[#333333] hover:bg-pink-50">Blogi</RouterLink>
              <RouterLink @click="showAdmin = false" to="/admin/faq" class="block px-4 py-2 text-sm text-[#333333] hover:bg-pink-50">KKK</RouterLink>
            </div>
          </div>
          <a @click="handleLogout" class="text-[#555555] hover:text-[#e6007a] cursor-pointer">Logi välja</a>
        </template>
        <RouterLink v-else to="/login" class="bg-[#e6007a] text-white px-4 py-2 rounded-lg text-sm hover:opacity-90">Logi sisse</RouterLink>
      </nav>
    </div>
  </header>
</template>

<script>
import { RouterLink } from 'vue-router'
import { useCartStore } from '../stores/cart.js'
import { useAuthStore } from '../stores/auth.js'

export default {
  name: 'NavBar',
  components: { RouterLink },
  data() {
    return {
      showAdmin: false,
    }
  },
  computed: {
    cart() { return useCartStore() },
    auth() { return useAuthStore() },
  },
  methods: {
    handleLogout() {
      this.auth.logout()
        .then(() => this.$router.push('/'))
        .catch((e) => console.error(e))
    },
  },
}
</script>
