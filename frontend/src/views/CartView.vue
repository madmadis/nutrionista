<template>
  <div class="min-h-screen flex flex-col">
    <NavBar />

    <main class="max-w-7xl mx-auto px-4 md:px-6 py-12 flex-1">
      <h1 class="text-3xl font-bold text-[#333333] mb-8">Ostukorv</h1>

      <div v-if="cart.items.length === 0" class="text-[#666666]">
        Ostukorv on tühi.
      </div>

      <div v-else>
        <div class="space-y-4 mb-12">
          <div
              v-for="item in cart.items"
              :key="item.id"
              class="bg-white rounded-xl border border-[#eeeeee] p-4 flex items-center justify-between shadow-sm"
          >
            <div class="flex items-center gap-4">
              <div class="w-16 h-16 bg-gray-100 rounded-lg"></div>
              <div>
                <p class="font-semibold text-[#333333]">{{ item.name }}</p>
                <div class="flex items-center gap-2 mt-1">
                  <span class="text-sm text-[#666666]">{{ item.price }} € x</span>
                  <div class="border border-[#cccccc] rounded px-2 py-0.5 text-sm">{{ item.qty }}</div>
                </div>
              </div>
            </div>
            <button
                @click="cart.removeItem(item.id)"
                class="bg-[#ff69b4] text-white px-4 py-1.5 rounded-lg text-sm hover:opacity-90"
            >
              Eemalda
            </button>
          </div>
        </div>

        <div class="bg-white rounded-xl border border-[#eeeeee] p-6 flex flex-col items-end gap-4 shadow-sm">
          <div class="flex items-center gap-4">
            <span class="text-lg font-bold text-[#333333]">Koguhind:</span>
            <span class="text-2xl font-bold text-[#E6007A]">{{ cart.total }} €</span>
          </div>
          <RouterLink
              to="/checkout"
              class="bg-[#e6007a] text-white px-8 py-3 rounded-lg shadow hover:opacity-90 text-lg font-semibold"
          >
            Mine maksma
          </RouterLink>
        </div>
      </div>
    </main>

    <FooterBar />
  </div>
</template>

<script>
import { RouterLink } from 'vue-router'
import NavBar from '../components/NavBar.vue'
import FooterBar from '../components/FooterBar.vue'
import { useCartStore } from '../stores/cart.js'

export default {
  name: 'CartView',
  components: { RouterLink, NavBar, FooterBar },
  computed: {
    cart() { return useCartStore() },
  },
}
</script>