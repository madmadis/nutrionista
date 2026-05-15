<template>
  <div class="min-h-screen flex flex-col">
    <NavBar />
    <main class="max-w-6xl mx-auto px-4 md:px-6 py-12 flex-1">
      <h1 class="text-3xl font-bold text-[#333333] mb-8">Admin - Vitamiinid</h1>

      <button @click="openForm(null)" class="bg-[#e6007a] text-white px-6 py-2 rounded-lg hover:opacity-90 mb-8">+ Lisa uus vitamiin</button>

      <div v-if="formVisible" class="bg-white rounded-xl p-6 shadow border border-[#dddddd] mb-8">
        <h2 class="text-xl font-bold text-[#333333] mb-4">{{ editing ? 'Muuda' : 'Lisa' }} vitamiini</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
          <div>
            <label class="block text-sm font-bold text-[#555555] mb-1">Nimi</label>
            <input v-model="form.name" class="border border-[#dddddd] rounded-lg px-4 py-2 w-full" />
          </div>
          <div>
            <label class="block text-sm font-bold text-[#555555] mb-1">Hind (€)</label>
            <input v-model.number="form.price" type="number" step="0.01" class="border border-[#dddddd] rounded-lg px-4 py-2 w-full" />
          </div>
          <div class="md:col-span-2">
            <label class="block text-sm font-bold text-[#555555] mb-1">Kirjeldus</label>
            <textarea v-model="form.description" class="border border-[#dddddd] rounded-lg px-4 py-2 w-full"></textarea>
          </div>
          <div>
            <label class="block text-sm font-bold text-[#555555] mb-1">Kategooria</label>
            <select v-model="form.categoryId" class="border border-[#dddddd] rounded-lg px-4 py-2 w-full">
              <option value="">—</option>
              <option v-for="cat in categories" :key="cat.id" :value="cat.id">{{ cat.name }}</option>
            </select>
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

      <div class="bg-white rounded-xl shadow border border-[#dddddd] overflow-hidden">
        <table class="w-full">
          <thead class="bg-[#e0ffe0]">
            <tr>
              <th class="text-left px-4 py-3 text-[#333333]">ID</th>
              <th class="text-left px-4 py-3 text-[#333333]">Nimi</th>
              <th class="text-left px-4 py-3 text-[#333333]">Hind</th>
              <th class="text-left px-4 py-3 text-[#333333]">Kategooria</th>
              <th class="text-center px-4 py-3 text-[#333333]">Esilehel</th>
              <th class="text-right px-4 py-3 text-[#333333]">Tegevused</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="n in nutrients" :key="n.id" class="border-t border-[#dddddd] hover:bg-gray-50">
              <td class="px-4 py-3">{{ n.id }}</td>
              <td class="px-4 py-3 font-semibold">{{ n.name }}</td>
              <td class="px-4 py-3">{{ Number(n.price).toFixed(2) }} €</td>
              <td class="px-4 py-3">{{ n.category?.name || '—' }}</td>
              <td class="px-4 py-3 text-center">
                <button @click="toggleFeatured(n)" class="text-sm" :class="n.featured ? 'text-green-600' : 'text-gray-400'">
                  {{ n.featured ? '★' : '☆' }}
                </button>
              </td>
              <td class="px-4 py-3 text-right">
                <button @click="openForm(n)" class="text-[#e6007a] hover:underline mr-3 text-sm">Muuda</button>
                <button @click="remove(n.id)" class="text-red-500 hover:underline text-sm">Kustuta</button>
              </td>
            </tr>
          </tbody>
        </table>
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
  name: 'AdminNutrientsView',
  components: { NavBar, FooterBar },
  data() {
    return {
      nutrients: [],
      categories: [],
      formVisible: false,
      editing: null,
      form: { name: '', description: '', price: '', categoryId: '', imageUrl: '' },
    }
  },
  methods: {
    load() {
      api.get('/nutrients')
        .then((response) => { this.nutrients = response.data })
        .catch((e) => console.error(e))
    },
    loadCategories() {
      api.get('/categories')
        .then((response) => { this.categories = response.data })
        .catch((e) => console.error(e))
    },
    openForm(n) {
      if (n) {
        this.editing = n
        this.form = { name: n.name, description: n.description, price: n.price, categoryId: n.category?.id || '', imageUrl: n.imageUrl || '' }
      } else {
        this.editing = null
        this.form = { name: '', description: '', price: '', categoryId: '', imageUrl: '' }
      }
      this.formVisible = true
    },
    save() {
      const payload = {
        name: this.form.name,
        description: this.form.description,
        price: this.form.price ? parseFloat(this.form.price) : 0,
        imageUrl: this.form.imageUrl,
        category: this.form.categoryId ? { id: parseInt(this.form.categoryId) } : null,
      }
      const request = this.editing
        ? api.put('/admin/nutrients/' + this.editing.id, payload)
        : api.post('/admin/nutrients', payload)
      request
        .then(() => {
          this.formVisible = false
          this.editing = null
          this.load()
        })
        .catch((e) => console.error(e))
    },
    remove(id) {
      if (!confirm('Kustuta vitamiin?')) return
      api.delete('/admin/nutrients/' + id)
        .then(() => this.load())
        .catch((e) => console.error(e))
    },
    toggleFeatured(n) {
      api.put('/admin/nutrients/' + n.id, { ...n, featured: !n.featured })
        .then(() => this.load())
        .catch((e) => console.error(e))
    },
  },
  beforeMount() {
    this.load()
    this.loadCategories()
  },
}
</script>
