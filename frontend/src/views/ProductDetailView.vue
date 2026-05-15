<template>
  <div class="min-h-screen flex flex-col">
    <NavBar />
    <main class="max-w-7xl mx-auto px-4 md:px-6 py-12 flex-1">
      <div v-if="product" class="flex flex-col md:flex-row gap-12">
        <div class="md:w-1/2">
          <div class="bg-gray-200 w-full aspect-square rounded-xl mb-6 flex items-center justify-center text-[#666666] text-2xl font-semibold">
            {{ product.name }}
          </div>
          <h1 class="text-3xl font-bold text-[#333333] mb-2">{{ product.name }}</h1>
          <p class="text-lg text-[#666666] mb-6">{{ product.description }}</p>
          <div class="text-4xl font-bold text-[#E6007A] mb-8">{{ Number(product.price).toFixed(2) }} €</div>
          <button
            @click="cart.addItem(product); $router.push('/cart')"
            class="bg-[#e6007a] text-white px-8 py-4 rounded-lg shadow hover:opacity-90 w-full flex items-center justify-center gap-2 text-lg"
          >
            <span class="material-symbols-outlined">shopping_cart</span> Lisa ostukorvi
          </button>
        </div>
        <div class="md:w-1/2 space-y-8">
          <div>
            <h2 class="text-xl font-bold text-[#333333] mb-4">Kategooria</h2>
            <p class="text-[#555555]">{{ product.category?.name || '—' }}</p>
          </div>
          <div>
            <h2 class="text-xl font-bold text-[#333333] mb-4">Kirjeldus</h2>
            <p class="text-[#555555]">{{ product.description || '—' }}</p>
          </div>
        </div>
      </div>
      <p v-else class="text-[#666666]">Laadin...</p>
    </main>
    <FooterBar />
  </div>
</template>

<script>
import { useCartStore } from '../stores/cart.js'
import NavBar from '../components/NavBar.vue'
import FooterBar from '../components/FooterBar.vue'
import api from '../api.js'

export default {
  name: 'ProductDetailView',
  components: { NavBar, FooterBar },
  data() {
    return {
      product: null,
    }
  },
  computed: {
    cart() { return useCartStore() },
  },
  methods: {
    getProduct() {
      api.get('/nutrients/' + this.$route.params.id)
        .then((response) => this.handleGetProductResponse(response.data))
        .catch(() => this.handleGetProductError())
    },
    handleGetProductResponse(data) {
      this.product = data
    },
    handleGetProductError() {
      this.product = {
        id: this.$route.params.id,
        name: 'Vitamiin Nimi',
        description: 'Lühikirjeldus vitamiini kohta.',
        price: '0.00',
      }
    },
  },
  beforeMount() {
    this.getProduct()
  },
}
</script>
