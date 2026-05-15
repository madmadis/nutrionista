<template>
  <div class="min-h-screen flex flex-col">
    <NavBar />
    <main class="max-w-7xl mx-auto px-4 md:px-6 py-12 flex-1">
      <h1 class="text-3xl font-bold text-[#333333] mb-8">Blogi</h1>
      <div v-if="loading" class="text-[#666666]">Laadin...</div>
      <div v-else class="grid grid-cols-1 md:grid-cols-3 gap-8">
        <div v-for="article in articles" :key="article.id" class="bg-white rounded-xl border border-[#dddddd] overflow-hidden flex flex-col">
          <div class="w-full h-48 bg-gray-200"></div>
          <div class="p-6 flex flex-col flex-1">
            <h3 class="text-lg font-bold text-[#333333] mb-3">{{ article.title }}</h3>
            <p class="text-sm text-[#666666] mb-6 flex-1">{{ article.summary }}</p>
            <button class="bg-[#e6007a] text-white px-4 py-2 rounded-lg self-start text-sm hover:opacity-90">Loe edasi</button>
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
  name: 'BlogView',
  components: { NavBar, FooterBar },
  data() {
    return {
      articles: [],
      loading: true,
    }
  },
  methods: {
    getArticles() {
      api.get('/blog-posts')
        .then((response) => this.handleGetArticlesResponse(response.data))
        .catch(() => this.handleGetArticlesError())
        .finally(() => { this.loading = false })
    },
    handleGetArticlesResponse(data) {
      this.articles = data
    },
    handleGetArticlesError() {
      this.articles = [
        { id: 1, title: 'Artikli pealkiri 1', summary: 'Lühike kokkuvõte artikli sisust.' },
        { id: 2, title: 'Artikli pealkiri 2', summary: 'Lühike kokkuvõte artikli sisust.' },
        { id: 3, title: 'Artikli pealkiri 3', summary: 'Lühike kokkuvõte artikli sisust.' },
      ]
    },
  },
  beforeMount() {
    this.getArticles()
  },
}
</script>
