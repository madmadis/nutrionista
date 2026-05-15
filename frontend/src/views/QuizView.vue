<template>
  <div class="min-h-screen flex flex-col">
    <NavBar />

    <main class="max-w-3xl mx-auto px-4 md:px-6 py-12 flex-1">
      <h1 class="text-3xl font-bold text-[#333333] mb-8 text-center">Vitamiinitest</h1>

      <div class="bg-white rounded-xl p-8 shadow border border-[#dddddd] space-y-8">
        <div v-for="(question, index) in questions" :key="index" class="space-y-3">
          <p class="font-bold text-[#333333]">{{ index + 1 }}. {{ question.text }}</p>
          <div class="space-y-2">
            <label
              v-for="option in question.options"
              :key="option"
              class="flex items-center gap-3 p-3 rounded-lg border border-[#dddddd] cursor-pointer hover:border-[#e6007a] transition-colors"
            >
              <input
                type="radio"
                :name="'q' + index"
                :value="option"
                v-model="answers[index]"
                class="accent-[#e6007a]"
              />
              <span class="text-[#555555]">{{ option }}</span>
            </label>
          </div>
        </div>

        <button
          @click="submitQuiz"
          class="bg-[#e6007a] text-white px-8 py-3 rounded-lg shadow hover:opacity-90 w-full font-semibold text-lg"
        >
          Näita soovitusi
        </button>

        <div v-if="showResults" class="mt-6 p-6 bg-[#e0ffe0] rounded-xl border border-[#7cfc00]">
          <h2 class="text-xl font-bold text-[#333333] mb-4">Soovitused sinu jaoks:</h2>
          <ul class="space-y-2 text-[#555555]">
            <li class="flex gap-2"><span>•</span> D-vitamiin 2000 IU päevas</li>
            <li class="flex gap-2"><span>•</span> B12-vitamiin 1000 mcg nädalas</li>
            <li class="flex gap-2"><span>•</span> Magneesium õhtuti</li>
          </ul>
          <RouterLink to="/shop" class="mt-4 inline-block bg-[#e6007a] text-white px-6 py-2 rounded-lg hover:opacity-90">
            Vaata tooteid
          </RouterLink>
        </div>
      </div>
    </main>

    <FooterBar />
  </div>
</template>

<script>
import { RouterLink } from 'vue-router'
import NavBar from '../components/NavBar.vue'
import FooterBar from '../components/FooterBar.vue'

export default {
  name: 'QuizView',
  components: { RouterLink, NavBar, FooterBar },
  data() {
    return {
      answers: {},
      showResults: false,
      questions: [
        {
          text: 'Kui sageli tunned väsimust?',
          options: ['Harva', 'Mõnikord', 'Sageli', 'Peaaegu alati'],
        },
        {
          text: 'Kui palju viibid päevas päikese käes?',
          options: ['Vähem kui 15 min', '15–30 min', '30–60 min', 'Üle tunni'],
        },
        {
          text: 'Kui sageli sööd kala või mereande?',
          options: ['Harva või mitte kunagi', '1–2 korda kuus', '1–2 korda nädalas', 'Iga päev'],
        },
      ],
    }
  },
  methods: {
    submitQuiz() {
      this.showResults = true
    },
  },
}
</script>
