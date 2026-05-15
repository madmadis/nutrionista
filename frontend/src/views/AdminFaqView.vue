<template>
  <div class="min-h-screen flex flex-col">
    <NavBar />
    <main class="max-w-4xl mx-auto px-4 md:px-6 py-12 flex-1">
      <h1 class="text-3xl font-bold text-[#333333] mb-8">Admin - KKK</h1>

      <button @click="openForm(null)" class="bg-[#e6007a] text-white px-6 py-2 rounded-lg hover:opacity-90 mb-8">+ Lisa uus KKK</button>

      <div v-if="formVisible" class="bg-white rounded-xl p-6 shadow border border-[#dddddd] mb-8">
        <h2 class="text-xl font-bold text-[#333333] mb-4">{{ editing ? 'Muuda' : 'Lisa' }} KKK</h2>
        <div class="grid grid-cols-1 gap-4 mb-4">
          <div>
            <label class="block text-sm font-bold text-[#555555] mb-1">Sektsioon</label>
            <input v-model="form.section" class="border border-[#dddddd] rounded-lg px-4 py-2 w-full" placeholder="nt: Vitamiinide kohta" />
          </div>
          <div>
            <label class="block text-sm font-bold text-[#555555] mb-1">Küsimus</label>
            <input v-model="form.question" class="border border-[#dddddd] rounded-lg px-4 py-2 w-full" />
          </div>
          <div>
            <label class="block text-sm font-bold text-[#555555] mb-1">Vastus</label>
            <textarea v-model="form.answer" rows="3" class="border border-[#dddddd] rounded-lg px-4 py-2 w-full"></textarea>
          </div>
          <div>
            <label class="block text-sm font-bold text-[#555555] mb-1">Järjekord</label>
            <input v-model.number="form.sortOrder" type="number" class="border border-[#dddddd] rounded-lg px-4 py-2 w-full" />
          </div>
        </div>
        <div class="flex gap-3">
          <button @click="save" class="bg-[#e6007a] text-white px-6 py-2 rounded-lg hover:opacity-90">{{ editing ? 'Salvesta' : 'Lisa' }}</button>
          <button @click="formVisible = false" class="bg-gray-200 text-[#333333] px-6 py-2 rounded-lg hover:opacity-90">Tühista</button>
        </div>
      </div>

      <div class="space-y-4">
        <div v-for="item in items" :key="item.id" class="bg-white rounded-xl p-4 shadow border border-[#dddddd]">
          <div class="flex justify-between items-start">
            <div class="flex-1">
              <span class="text-xs text-[#e6007a] font-semibold">{{ item.section }}</span>
              <h3 class="font-semibold text-[#333333] mt-1">{{ item.question }}</h3>
              <p class="text-sm text-[#666666] mt-1">{{ item.answer }}</p>
            </div>
            <div class="flex gap-3 shrink-0 ml-4">
              <button @click="openForm(item)" class="text-[#e6007a] hover:underline text-sm">Muuda</button>
              <button @click="remove(item.id)" class="text-red-500 hover:underline text-sm">Kustuta</button>
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
  name: 'AdminFaqView',
  components: { NavBar, FooterBar },
  data() {
    return {
      items: [],
      formVisible: false,
      editing: null,
      form: { section: '', question: '', answer: '', sortOrder: 0 },
    }
  },
  methods: {
    load() {
      api.get('/faq-items')
        .then((response) => { this.items = response.data })
        .catch((e) => console.error(e))
    },
    openForm(item) {
      if (item) {
        this.editing = item
        this.form = { section: item.section, question: item.question, answer: item.answer, sortOrder: item.sortOrder }
      } else {
        this.editing = null
        this.form = { section: '', question: '', answer: '', sortOrder: 0 }
      }
      this.formVisible = true
    },
    save() {
      const request = this.editing
        ? api.put('/admin/faq-items/' + this.editing.id, this.form)
        : api.post('/admin/faq-items', this.form)
      request
        .then(() => {
          this.formVisible = false
          this.load()
        })
        .catch((e) => console.error(e))
    },
    remove(id) {
      if (!confirm('Kustuta KKK?')) return
      api.delete('/admin/faq-items/' + id)
        .then(() => this.load())
        .catch((e) => console.error(e))
    },
  },
  beforeMount() {
    this.load()
  },
}
</script>
