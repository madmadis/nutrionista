<template>
  <footer class="w-full bg-[#e0ffe0] border-t border-[#dddddd] mt-12">
    <div class="max-w-7xl mx-auto px-4 md:px-6 py-6 flex justify-between items-center">
      <span class="text-[#333333]">© 2023 Nutrionista</span>
      <div class="flex gap-4">
        <RouterLink to="/blog" class="text-sm text-[#555555] hover:underline">Blogi</RouterLink>
        <RouterLink to="/faq" class="text-sm text-[#555555] hover:underline">KKK</RouterLink>
        <RouterLink to="/contact" class="text-sm text-[#555555] hover:underline">Kontakt</RouterLink>
      </div>
    </div>
  </footer>
</template>

<script>
import { RouterLink } from 'vue-router'

export default {
  name: 'FooterBar',
  components: { RouterLink },
}
</script>
