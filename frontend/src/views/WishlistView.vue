<template>
  <div class="min-h-screen flex flex-col">
    <NavBar />

    <main class="max-w-7xl mx-auto px-4 md:px-6 py-12 flex-1">
      <h1 class="text-3xl font-bold text-[#333333] mb-8">Soovikorv</h1>

      <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div
          v-for="item in wishlist"
          :key="item.id"
          class="bg-white rounded-xl border border-[#dddddd] p-4 flex flex-col items-center text-center"
        >
          <div class="w-full h-32 bg-gray-100 rounded-lg mb-4"></div>
          <h3 class="font-semibold text-[#333333]">{{ item.name }}</h3>
          <p class="text-xs text-[#666666] my-1">{{ item.description }}</p>
          <span class="text-lg font-bold text-[#E6007A] mb-4">{{ item.price }} €</span>
          <div class="w-full space-y-2">
            <RouterLink
              :to="'/product/' + item.id"
              class="bg-[#e6007a] text-white px-4 py-2 rounded-lg w-full text-sm block text-center"
            >
              Vaata lähemalt
            </RouterLink>
            <button class="bg-[#90ee90] text-[#333333] px-4 py-2 rounded-lg w-full text-sm border border-[#7cfc00]">
              Lisa ostukorvi
            </button>
          </div>
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

export default {
  name: 'WishlistView',
  components: { RouterLink, NavBar, FooterBar },
  data() {
    return {
      wishlist: [
        { id: 1, name: 'Vitamiin Nimi 1', description: 'Lühikirjeldus', price: '15.99' },
        { id: 2, name: 'Vitamiin Nimi 2', description: 'Lühikirjeldus', price: '22.50' },
        { id: 3, name: 'Vitamiin Nimi 3', description: 'Lühikirjeldus', price: '10.00' },
      ],
    }
  },
}
</script>
