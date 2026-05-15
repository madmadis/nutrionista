<template>
  <div class="min-h-screen flex flex-col">
    <NavBar />

    <main class="max-w-7xl mx-auto px-4 md:px-6 py-12 flex-1">
      <h1 class="text-3xl font-bold text-[#333333] mb-8">Tellimuste ajalugu</h1>

      <div class="space-y-8">
        <div
          v-for="order in orders"
          :key="order.id"
          class="bg-white rounded-xl p-8 shadow border border-[#dddddd]"
        >
          <div class="flex justify-between items-start mb-6">
            <div>
              <h2 class="text-xl font-bold text-[#333333]">Tellimus #{{ order.id }}</h2>
              <p class="text-sm text-[#666666]">Kuupäev: {{ order.date }}</p>
            </div>
            <div class="text-right">
              <p class="text-sm font-bold">
                <span class="text-[#666666]">Staatus:</span>
                <span class="text-green-600"> {{ order.status }}</span>
              </p>
              <p class="text-sm font-bold mt-1">
                <span class="text-[#666666]">Tellimuse summa:</span>
                <span class="text-[#E6007A]"> {{ order.total }} €</span>
              </p>
            </div>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-8 mb-8">
            <p class="text-sm text-[#666666]"><span class="font-bold">Aadress:</span> {{ order.address }}</p>
            <p class="text-sm text-[#666666]"><span class="font-bold">Makseviis:</span> {{ order.payment }}</p>
          </div>

          <h3 class="text-lg font-bold text-[#333333] mb-4">Tellimuse detailid:</h3>
          <div class="space-y-3">
            <div
              v-for="item in order.items"
              :key="item.name"
              class="flex items-center justify-between p-4 bg-white rounded-lg border border-[#eeeeee]"
            >
              <div class="flex items-center gap-4">
                <div class="w-12 h-12 bg-gray-100 rounded"></div>
                <div>
                  <p class="font-semibold text-[#333333]">{{ item.name }}</p>
                  <p class="text-xs text-[#666666]">{{ item.price }} € x {{ item.qty }}</p>
                </div>
              </div>
              <span class="font-bold text-[#333333]">{{ (parseFloat(item.price) * item.qty).toFixed(2) }} €</span>
            </div>
          </div>
          <div class="text-right mt-6">
            <span class="text-xl font-bold text-[#E6007A]">Kokku: {{ order.total }} €</span>
          </div>
        </div>
      </div>
    </main>

    <FooterBar />
  </div>
</template>

<script>
import NavBar from '../components/NavBar.vue'
import FooterBar from '../components/FooterBar.vue'

export default {
  name: 'OrderHistoryView',
  components: { NavBar, FooterBar },
  data() {
    return {
      orders: [
        {
          id: 12345,
          date: '2023-10-26',
          status: 'Täidetud',
          total: '45.99',
          address: 'Tänav 1, Linn, 12345',
          payment: 'Krediitkaart',
          items: [
            { name: 'Vitamiin A', price: '12.99', qty: 2 },
            { name: 'Vitamiin C', price: '10.00', qty: 2 },
          ],
        },
        {
          id: 12344,
          date: '2023-09-15',
          status: 'Täidetud',
          total: '25.50',
          address: 'Tänav 2, Linn, 12345',
          payment: 'Pangaülekanne',
          items: [],
        },
      ],
    }
  },
}
</script>
