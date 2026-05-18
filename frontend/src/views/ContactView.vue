<template>
  <div class="min-h-screen flex flex-col">
    <NavBar />

    <main class="max-w-7xl mx-auto px-4 md:px-6 py-12 flex-1">
      <h1 class="text-3xl font-bold text-[#333333] mb-8">Tagasiside & Kontakt</h1>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-12">
        <!-- Tagasiside vorm -->
        <div class="bg-white rounded-xl p-8 shadow border border-[#dddddd]">
          <h2 class="text-xl font-bold text-[#333333] mb-6">Saada meile tagasisidet</h2>
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-bold text-[#555555] mb-1">Nimi:</label>
              <input v-model="form.name" type="text" placeholder="Sisesta oma nimi" class="border border-[#dddddd] rounded-lg px-4 py-2.5 w-full" />
            </div>
            <div>
              <label class="block text-sm font-bold text-[#555555] mb-1">E-post:</label>
              <input v-model="form.email" type="email" placeholder="Sisesta oma e-post" class="border border-[#dddddd] rounded-lg px-4 py-2.5 w-full" />
            </div>
            <div>
              <label class="block text-sm font-bold text-[#555555] mb-1">Sõnum:</label>
              <textarea v-model="form.message" placeholder="Sisesta oma tagasiside siia..." class="border border-[#dddddd] rounded-lg px-4 py-2.5 w-full h-32"></textarea>
            </div>
            <p v-if="successMessage" class="text-green-600 font-bold text-sm">{{ successMessage }}</p>
            <p v-if="errorMessage" class="text-red-500 font-bold text-sm">{{ errorMessage }}</p>
            <button @click="submitFeedback" :disabled="loading"
              class="bg-[#e6007a] text-white px-6 py-3 rounded-lg shadow hover:opacity-90 w-full font-bold disabled:opacity-50">
              {{ loading ? 'Saatmine...' : 'Saada tagasiside' }}
            </button>
          </div>
        </div>

        <!-- Kontaktinfo -->
        <div class="bg-white rounded-xl p-8 shadow border border-[#dddddd] space-y-8">
          <h2 class="text-xl font-bold text-[#333333]">Võta meiega ühendust</h2>
          <div class="space-y-4">
            <div class="flex items-center gap-3">
              <span class="material-symbols-outlined text-[#e6007a]">mail</span>
              <p class="text-[#555555]"><span class="font-bold">E-post:</span> info@nutrionista.ee</p>
            </div>
            <div class="flex items-center gap-3">
              <span class="material-symbols-outlined text-[#e6007a]">phone_in_talk</span>
              <p class="text-[#555555]"><span class="font-bold">Telefon:</span> +372 123 4567</p>
            </div>
            <div class="flex items-center gap-3">
              <span class="material-symbols-outlined text-[#e6007a]">location_on</span>
              <p class="text-[#555555]"><span class="font-bold">Aadress:</span> Näidis tänav 1, Tallinn, Eesti</p>
            </div>
          </div>

          <div class="pt-8 border-t border-[#dddddd]">
            <h2 class="text-xl font-bold text-[#333333] mb-4">Live Chat (tulevikus)</h2>
            <div class="bg-[#f0f0f0] rounded-lg p-6 flex flex-col items-center text-center gap-3">
              <span class="material-symbols-outlined text-4xl text-[#90ee90]">chat</span>
              <p class="text-sm text-[#666666]">Live chat funktsionaalsus on arendamisel ja lisatakse peagi!</p>
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

export default {
  name: 'ContactView',
  components: { NavBar, FooterBar },
  data() {
    return {
      form: { name: '', email: '', message: '' },
      loading: false,
      successMessage: '',
      errorMessage: '',
    }
  },
  methods: {
    submitFeedback() {
      this.successMessage = ''
      this.errorMessage = ''
      this.loading = true
      this.$axios.post('/api/feedback', this.form)
        .then(() => this.handleSubmitResponse())
        .catch((error) => this.handleSubmitError(error))
        .finally(() => { this.loading = false })
    },
    handleSubmitResponse() {
      this.successMessage = 'Tagasiside edukalt saadetud!'
      this.form = { name: '', email: '', message: '' }
    },
    handleSubmitError() {
      this.errorMessage = 'Saatmine ebaõnnestus. Proovi uuesti.'
    },
  },
}
</script>
