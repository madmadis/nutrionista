<template>
  <div class="min-h-screen flex flex-col">
    <NavBar />
    <main class="max-w-7xl mx-auto px-4 md:px-6 py-12 flex-1">
      <h1 class="text-3xl font-bold text-[#333333] mb-8">Tooted</h1>

      <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
        <div>
          <label class="block text-sm font-bold text-[#555555] mb-1">Kategooria</label>
          <select v-model="filter.category" class="bg-white border border-[#dddddd] rounded-lg px-4 py-2.5 w-full">
            <option value="">Kõik</option>
            <option v-for="cat in categories" :key="cat.id" :value="cat.id">{{ cat.name }}</option>
          </select>
        </div>
        <div>
          <label class="block text-sm font-bold text-[#555555] mb-1">Hind</label>
          <select v-model="filter.price" class="bg-white border border-[#dddddd] rounded-lg px-4 py-2.5 w-full">
            <option value="">Kõik</option>
            <option value="0-10">Kuni 10 €</option>
            <option value="10-15">10–15 €</option>
            <option value="15-999">Alates 15 €</option>
          </select>
        </div>
        <div>
          <label class="block text-sm font-bold text-[#555555] mb-1">Otsi</label>
          <input v-model="filter.search" placeholder="Toote nimi..." class="border border-[#dddddd] rounded-lg px-4 py-2.5 w-full" />
        </div>
        <div class="flex items-end">
          <button @click="clearFilters" class="text-sm text-[#e6007a] hover:underline">Tühista filtrid</button>
        </div>
      </div>

      <div v-if="filtered.length === 0" class="text-center text-[#666666] py-12">Tooteid ei leitud.</div>
      <div v-else class="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div
            v-for="product in filtered"
            :key="product.id"
            class="bg-white rounded-xl shadow p-4 flex flex-col items-center text-center border border-[#dddddd] hover:border-[#e6007a] transition-colors cursor-pointer"
            @click="$router.push('/product/' + product.id)"
        >
          <div class="bg-gray-100 w-full h-32 rounded-lg mb-4 flex items-center justify-center text-[#666666]">
            {{ product.name }}
          </div>
          <h3 class="text-lg font-semibold text-[#333333]">{{ product.name }}</h3>
          <p class="text-sm text-[#666666] my-2 line-clamp-2">{{ product.description }}</p>
          <span class="text-xl font-bold text-[#E6007A] mb-4">{{ Number(product.price).toFixed(2) }} €</span>
          <button
              @click.stop="cart.addItem(product)"
              class="bg-[#90ee90] text-[#333333] px-4 py-2 rounded-lg w-full hover:opacity-90 border border-[#7cfc00] mb-2"
          >
            Lisa ostukorvi
          </button>
          <RouterLink
              :to="'/product/' + product.id"
              class="bg-[#e6007a] text-white px-4 py-2 rounded-lg w-full hover:opacity-90 text-center"
          >
            Vaata lähemalt
          </RouterLink>
        </div>
      </div>
    </main>
    <FooterBar />
  </div>
</template>

<script>
import { RouterLink } from 'vue-router'
import { useCartStore } from '../stores/cart.js'
import NavBar from '../components/NavBar.vue'
import FooterBar from '../components/FooterBar.vue'
import api from '../api.js'

export default {
  name: 'ShopView',
  components: { RouterLink, NavBar, FooterBar },
  data() {
    return {
      products: [],
      categories: [],
      filter: { category: '', price: '', search: '' },
    }
  },
  computed: {
    cart() { return useCartStore() },
    filtered() {
      let result = this.products
      if (this.filter.category) {
        result = result.filter(p => p.category?.id == this.filter.category)
      }
      if (this.filter.price) {
        const [min, max] = this.filter.price.split('-').map(Number)
        result = result.filter(p => p.price >= min && p.price <= max)
      }
      if (this.filter.search) {
        const q = this.filter.search.toLowerCase()
        result = result.filter(p => p.name.toLowerCase().includes(q) || (p.description || '').toLowerCase().includes(q))
      }
      return result
    },
  },
  methods: {
    clearFilters() {
      this.filter = { category: '', price: '', search: '' }
    },
    loadProducts() {
      api.get('/nutrients')
        .then((response) => this.handleLoadProductsResponse(response.data))
        .catch((error) => console.error('API error:', error))
    },
    handleLoadProductsResponse(data) {
      this.products = data
    },
    loadCategories() {
      api.get('/categories')
        .then((response) => this.handleLoadCategoriesResponse(response.data))
        .catch((error) => console.error('API error:', error))
    },
    handleLoadCategoriesResponse(data) {
      this.categories = data
    },
  },
  beforeMount() {
    this.loadProducts()
    this.loadCategories()
  },
}
</script>
