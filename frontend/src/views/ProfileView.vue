<template>
  <div class="min-h-screen flex flex-col">
    <NavBar />

    <main class="max-w-7xl mx-auto px-4 md:px-6 py-12 flex-1">
      <h1 class="text-3xl font-bold text-[#333333] mb-8">Minu konto</h1>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
        <!-- Isikuandmed -->
        <div class="bg-white rounded-xl p-6 shadow border border-[#dddddd]">
          <h2 class="text-xl font-bold text-[#E6007A] mb-6">Isikuandmed</h2>
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-bold text-[#555555] mb-1">Nimi:</label>
              <input v-model="form.name" type="text" class="border border-[#dddddd] rounded-lg px-4 py-2 w-full" />
            </div>
            <div>
              <label class="block text-sm font-bold text-[#555555] mb-1">E-post:</label>
              <input v-model="form.email" type="email" class="border border-[#dddddd] rounded-lg px-4 py-2 w-full" />
            </div>
            <div>
              <label class="block text-sm font-bold text-[#555555] mb-1">Telefon:</label>
              <input v-model="form.phone" type="tel" class="border border-[#dddddd] rounded-lg px-4 py-2 w-full" />
            </div>
            <button class="bg-[#e6007a] text-white px-4 py-2 rounded-lg w-full hover:opacity-90 font-semibold">
              Salvesta muudatused
            </button>
          </div>
        </div>

        <!-- Soovitused -->
        <div class="bg-white rounded-xl p-6 shadow border border-[#dddddd]">
          <h2 class="text-xl font-bold text-[#E6007A] mb-6">Soovitused</h2>
          <ul class="space-y-4 text-[#555555]">
            <li class="flex gap-2"><span>•</span> D-vitamiin 2000 IU päevas</li>
            <li class="flex gap-2"><span>•</span> B12-vitamiin 1000 mcg nädalas</li>
            <li class="flex gap-2"><span>•</span> Rauapreparaat koos C-vitamiiniga</li>
            <li class="flex gap-2"><span>•</span> Magneesium õhtuti paremaks uneks</li>
          </ul>
          <RouterLink
            to="/wishlist"
            class="mt-8 bg-[#90ee90] text-[#333333] px-4 py-2 rounded-lg w-full flex items-center justify-center gap-2 border border-[#7cfc00]"
          >
            <span class="material-symbols-outlined text-sm">favorite</span> Soovikorv
          </RouterLink>
        </div>

        <!-- Ostetud vitamiinid -->
        <div class="bg-white rounded-xl p-6 shadow border border-[#dddddd]">
          <h2 class="text-xl font-bold text-[#E6007A] mb-6">Ostetud vitamiinid</h2>
          <div class="space-y-4">
            <div
              v-for="item in purchased"
              :key="item.name"
              class="bg-white rounded-lg border border-[#eeeeee] p-3 flex gap-3"
            >
              <div class="w-12 h-12 bg-gray-100 rounded flex-shrink-0"></div>
              <div class="flex-1">
                <p class="text-sm font-bold text-[#333333]">{{ item.name }}</p>
                <p class="text-xs text-[#666666]">Järgmine meeldetuletus: {{ item.reminder }}</p>
              </div>
              <button class="bg-[#e6007a] text-white px-2 py-1 rounded text-[10px] self-center">Telli uuesti</button>
            </div>
          </div>
          <RouterLink
            to="/cart"
            class="mt-8 bg-[#e6007a] text-white px-4 py-2 rounded-lg w-full flex items-center justify-center gap-2"
          >
            <span class="material-symbols-outlined text-sm">shopping_cart</span> Ostukorvi
          </RouterLink>
        </div>
      </div>

      <!-- Kiirlingid -->
      <div class="mt-8 flex gap-4">
        <RouterLink to="/order-history" class="bg-white border border-[#dddddd] rounded-lg px-4 py-2 text-[#555555] hover:border-[#e6007a]">
          Tellimuste ajalugu
        </RouterLink>
        <RouterLink to="/quiz" class="bg-white border border-[#dddddd] rounded-lg px-4 py-2 text-[#555555] hover:border-[#e6007a]">
          Vitamiinitest
        </RouterLink>
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
  name: 'ProfileView',
  components: { RouterLink, NavBar, FooterBar },
  data() {
    return {
      form: { name: 'Kaili', email: 'kaili@example.com', phone: '+372 000 0000' },
      purchased: [
        { name: 'D-vitamiin 2000 IU', reminder: '15.11.2023' },
        { name: 'Magneesiumtsitraat', reminder: '01.12.2023' },
      ],
    }
  },
}
</script>
