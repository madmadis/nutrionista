<template>
  <div class="min-h-screen flex flex-col">
    <header class="w-full bg-[#e0ffe0] border-b border-[#dddddd]">
      <div class="max-w-7xl mx-auto px-4 md:px-6 py-4 flex items-center justify-between">
        <RouterLink to="/" class="text-xl font-bold text-[#333333]">Nutrionista</RouterLink>
        <nav class="flex gap-6">
          <RouterLink to="/" class="text-[#555555]">Avaleht</RouterLink>
          <RouterLink to="/cart" class="text-[#555555]">Ostukorv</RouterLink>
        </nav>
      </div>
    </header>

    <main class="max-w-3xl mx-auto px-4 md:px-6 py-12 flex-1">
      <h1 class="text-3xl font-bold text-[#333333] mb-8">Kassa</h1>

      <div class="bg-white rounded-xl p-8 shadow border border-[#dddddd] space-y-8">
        <!-- Tarneandmed -->
        <section class="space-y-4">
          <h2 class="text-xl font-bold text-[#333333]">Tarneandmed</h2>
          <div class="grid grid-cols-1 gap-4">
            <div>
              <label class="block text-sm font-bold text-[#555555] mb-1">Täisnimi:</label>
              <input v-model="form.name" type="text" placeholder="Sisesta täisnimi" class="border border-[#dddddd] rounded-lg px-4 py-2.5 w-full" />
            </div>
            <div>
              <label class="block text-sm font-bold text-[#555555] mb-1">Aadress:</label>
              <input v-model="form.address" type="text" placeholder="Sisesta aadress" class="border border-[#dddddd] rounded-lg px-4 py-2.5 w-full" />
            </div>
            <div class="grid grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-bold text-[#555555] mb-1">Linn:</label>
                <input v-model="form.city" type="text" placeholder="Sisesta linn" class="border border-[#dddddd] rounded-lg px-4 py-2.5 w-full" />
              </div>
              <div>
                <label class="block text-sm font-bold text-[#555555] mb-1">Postiindeks:</label>
                <input v-model="form.zip" type="text" placeholder="Sisesta postiindeks" class="border border-[#dddddd] rounded-lg px-4 py-2.5 w-full" />
              </div>
            </div>
            <div class="grid grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-bold text-[#555555] mb-1">E-post:</label>
                <input v-model="form.email" type="email" placeholder="Sisesta e-post" class="border border-[#dddddd] rounded-lg px-4 py-2.5 w-full" />
              </div>
              <div>
                <label class="block text-sm font-bold text-[#555555] mb-1">Telefon:</label>
                <input v-model="form.phone" type="tel" placeholder="Sisesta telefoninumber" class="border border-[#dddddd] rounded-lg px-4 py-2.5 w-full" />
              </div>
            </div>
          </div>
        </section>

        <!-- Makseviis -->
        <section class="space-y-4 pt-8 border-t border-[#dddddd]">
          <h2 class="text-xl font-bold text-[#333333]">Makseviis</h2>
          <div class="flex gap-4">
            <label class="flex items-center gap-2 cursor-pointer">
              <input type="radio" v-model="paymentMethod" value="card" class="accent-[#e6007a]" />
              <span class="text-[#555555]">Krediitkaart</span>
            </label>
            <label class="flex items-center gap-2 cursor-pointer">
              <input type="radio" v-model="paymentMethod" value="bank" class="accent-[#e6007a]" />
              <span class="text-[#555555]">Pangaülekanne</span>
            </label>
          </div>
        </section>

        <button
          class="bg-[#e6007a] text-white px-8 py-4 rounded-lg shadow hover:opacity-90 w-full text-lg font-semibold"
          @click="submitOrder"
        >
          Kinnita tellimus
        </button>
      </div>
    </main>
  </div>
</template>

<script>
import { RouterLink } from 'vue-router'
import { useCartStore } from '../stores/cart.js'

export default {
  name: 'CheckoutView',
  components: { RouterLink },
  data() {
    return {
      paymentMethod: 'card',
      form: { name: '', address: '', city: '', zip: '', email: '', phone: '' },
    }
  },
  computed: {
    cart() { return useCartStore() },
  },
  methods: {
    submitOrder() {
      this.cart.clear()
      alert('Tellimus esitatud!')
      this.$router.push('/order-history')
    },
  },
}
</script>
