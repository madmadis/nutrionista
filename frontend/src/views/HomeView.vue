<template>
  <div class="min-h-screen flex flex-col">
    <NavBar />

    <main class="max-w-7xl mx-auto px-4 md:px-6 py-12 flex-1">
      <section class="text-center mb-16">
        <h1 class="text-4xl font-bold text-[#333333] mb-4">Tere tulemast Nutrionistasse!</h1>
        <p class="text-lg text-[#666666]">Avasta parimad vitamiinid ja toidulisandid oma tervise toetamiseks.</p>
        <div class="mt-8 flex justify-center gap-4">
          <RouterLink
            to="/shop"
            class="bg-[#e6007a] text-white px-8 py-3 rounded-lg shadow hover:opacity-90 flex items-center gap-2"
          >
            <span class="material-symbols-outlined">shopping_bag</span> Tooted
          </RouterLink>
          <RouterLink
            to="/login"
            class="bg-white text-[#e6007a] border-2 border-[#e6007a] px-8 py-3 rounded-lg shadow hover:bg-pink-50 flex items-center gap-2"
          >
            <span class="material-symbols-outlined">person</span> Logi sisse
          </RouterLink>
        </div>
      </section>

      <section>
        <h2 class="text-2xl font-bold text-[#333333] mb-8">Esiletõstetud Tooted</h2>
        <div v-if="loading" class="text-[#666666]">Laadin tooteid...</div>
        <div v-else class="grid grid-cols-1 md:grid-cols-4 gap-6">
          <div
            v-for="product in featuredProducts"
            :key="product.id"
            class="bg-white rounded-xl shadow p-4 flex flex-col items-center text-center border border-[#dddddd] hover:border-[#e6007a] transition-colors cursor-pointer"
            @click="$router.push('/product/' + product.id)"
          >
            <div class="bg-gray-100 w-full h-32 rounded-lg mb-4 flex items-center justify-center text-[#666666]">
              {{ product.name }}
            </div>
            <h3 class="text-lg font-semibold text-[#333333]">{{ product.name }}</h3>
            <p class="text-sm text-[#666666] my-2">{{ product.description }}</p>
            <span class="text-xl font-bold text-[#E6007A] mb-4">{{ Number(product.price).toFixed(2) }} €</span>
            <RouterLink
              :to="'/product/' + product.id"
              class="bg-[#e6007a] text-white px-4 py-2 rounded-lg w-full hover:opacity-90 text-center"
            >
              Vaata lähemalt
            </RouterLink>
          </div>
        </div>
      </section>
    </main>

    <FooterBar />
  </div>
</template>

<script>
import NavBar from '../components/NavBar.vue'
import FooterBar from '../components/FooterBar.vue'
import api from '../api.js'

export default {
  name: 'HomeView',
  components: { NavBar, FooterBar },
  data() {
    return {
      featuredProducts: [],
      loading: true,
    }
  },
  methods: {
    getFeaturedProducts() {
      api.get('/nutrients', { params: { featured: true } })
        .then((response) => this.handleGetFeaturedProductsResponse(response.data))
        .catch(() => this.handleGetFeaturedProductsError())
        .finally(() => { this.loading = false })
    },
    handleGetFeaturedProductsResponse(products) {
      this.featuredProducts = products
    },
    handleGetFeaturedProductsError() {
      this.featuredProducts = [
        { id: 1, name: 'Vitamiin C', description: 'Antioksüdant ja immuunsüsteem', price: '9.50' },
        { id: 2, name: 'Vitamiin D', description: 'Luude tervis ja kaltsiumi imendumine', price: '15.00' },
      ]
    },
  },
  beforeMount() {
    this.getFeaturedProducts()
  },
}
</script>
