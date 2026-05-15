<template>
  <div class="min-h-screen flex flex-col">
    <NavBar />
    <main class="max-w-4xl mx-auto px-4 md:px-6 py-12 flex-1">
      <h1 class="text-3xl font-bold text-[#333333] mb-8">Admin - Blogi</h1>

      <button @click="openForm(null)" class="bg-[#e6007a] text-white px-6 py-2 rounded-lg hover:opacity-90 mb-8">+ Lisa uus postitus</button>

      <div v-if="formVisible" class="bg-white rounded-xl p-6 shadow border border-[#dddddd] mb-8">
        <h2 class="text-xl font-bold text-[#333333] mb-4">{{ editing ? 'Muuda' : 'Lisa' }} postitust</h2>
        <div class="grid grid-cols-1 gap-4 mb-4">
          <div>
            <label class="block text-sm font-bold text-[#555555] mb-1">Pealkiri</label>
            <input v-model="form.title" class="border border-[#dddddd] rounded-lg px-4 py-2 w-full" />
          </div>
          <div>
            <label class="block text-sm font-bold text-[#555555] mb-1">Kokkuvõte</label>
            <input v-model="form.summary" class="border border-[#dddddd] rounded-lg px-4 py-2 w-full" />
          </div>
          <div>
            <label class="block text-sm font-bold text-[#555555] mb-1">Sisu</label>
            <textarea v-model="form.content" rows="5" class="border border-[#dddddd] rounded-lg px-4 py-2 w-full"></textarea>
          </div>
          <div>
            <label class="block text-sm font-bold text-[#555555] mb-1">Pildi URL</label>
            <input v-model="form.imageUrl" class="border border-[#dddddd] rounded-lg px-4 py-2 w-full" />
          </div>
        </div>
        <div class="flex gap-3">
          <button @click="save" class="bg-[#e6007a] text-white px-6 py-2 rounded-lg hover:opacity-90">{{ editing ? 'Salvesta' : 'Lisa' }}</button>
          <button @click="formVisible = false" class="bg-gray-200 text-[#333333] px-6 py-2 rounded-lg hover:opacity-90">Tühista</button>
        </div>
      </div>

      <div class="space-y-4">
        <div v-for="post in posts" :key="post.id" class="bg-white rounded-xl p-4 shadow border border-[#dddddd] flex justify-between items-center">
          <div>
            <h3 class="font-semibold text-[#333333]">{{ post.title }}</h3>
            <p class="text-sm text-[#666666]">{{ post.summary }}</p>
          </div>
          <div class="flex gap-3 shrink-0">
            <button @click="openForm(post)" class="text-[#e6007a] hover:underline text-sm">Muuda</button>
            <button @click="remove(post.id)" class="text-red-500 hover:underline text-sm">Kustuta</button>
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
  name: 'AdminBlogView',
  components: { NavBar, FooterBar },
  data() {
    return {
      posts: [],
      formVisible: false,
      editing: null,
      form: { title: '', summary: '', content: '', imageUrl: '' },
    }
  },
  methods: {
    load() {
      api.get('/blog-posts')
        .then((response) => { this.posts = response.data })
        .catch((e) => console.error(e))
    },
    openForm(post) {
      if (post) {
        this.editing = post
        this.form = { title: post.title, summary: post.summary, content: post.content, imageUrl: post.imageUrl || '' }
      } else {
        this.editing = null
        this.form = { title: '', summary: '', content: '', imageUrl: '' }
      }
      this.formVisible = true
    },
    save() {
      const request = this.editing
        ? api.put('/admin/blog-posts/' + this.editing.id, this.form)
        : api.post('/admin/blog-posts', this.form)
      request
        .then(() => {
          this.formVisible = false
          this.load()
        })
        .catch((e) => console.error(e))
    },
    remove(id) {
      if (!confirm('Kustuta postitus?')) return
      api.delete('/admin/blog-posts/' + id)
        .then(() => this.load())
        .catch((e) => console.error(e))
    },
  },
  beforeMount() {
    this.load()
  },
}
</script>
