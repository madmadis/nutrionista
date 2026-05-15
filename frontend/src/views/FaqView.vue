<template>
  <div class="min-h-screen flex flex-col">
    <NavBar />
    <main class="max-w-7xl mx-auto px-4 md:px-6 py-12 flex-1">
      <h1 class="text-3xl font-bold text-[#333333] mb-12 text-center">Korduma Kippuvad Küsimused</h1>
      <div v-if="loading" class="text-center text-[#666666]">Laadin...</div>
      <div v-else class="space-y-8">
        <div v-for="section in grouped" :key="section.title" class="bg-white rounded-xl p-8 shadow border border-[#dddddd]">
          <h2 class="text-xl font-bold text-[#e6007a] mb-6">{{ section.title }}</h2>
          <div class="space-y-6">
            <div v-for="item in section.items" :key="item.id">
              <p class="font-bold text-[#333333] mb-2">K: {{ item.question }}</p>
              <p class="text-[#555555]">V: {{ item.answer }}</p>
            </div>
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
import api from '../api.js'

export default {
  name: 'FaqView',
  components: { NavBar, FooterBar },
  data() {
    return {
      items: [],
      loading: true,
    }
  },
  computed: {
    grouped() {
      const map = {}
      for (const item of this.items) {
        if (!map[item.section]) map[item.section] = { title: item.section, items: [] }
        map[item.section].items.push(item)
      }
      return Object.values(map)
    },
  },
  methods: {
    getFaqItems() {
      api.get('/faq-items')
        .then((response) => this.handleGetFaqItemsResponse(response.data))
        .catch(() => this.handleGetFaqItemsError())
        .finally(() => { this.loading = false })
    },
    handleGetFaqItemsResponse(data) {
      this.items = data
    },
    handleGetFaqItemsError() {
      this.items = [
        { id: 1, section: 'Vitamiinide kohta', question: 'Mis on vitamiinid?', answer: 'Vitamiinid on orgaanilised ühendid.' },
        { id: 2, section: 'Vitamiinide kohta', question: 'Kuidas valida õigeid vitamiine?', answer: 'Sõltub teie vajadustest.' },
        { id: 3, section: 'Annuste kohta', question: 'Millised on soovitatavad annused?', answer: 'Sõltub vitamiinist ja vanusest.' },
      ]
    },
  },
  beforeMount() {
    this.getFaqItems()
  },
}
</script>
