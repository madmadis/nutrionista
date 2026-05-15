import { defineStore } from 'pinia'
import { ref } from 'vue'
import api from '../api.js'

export const useAuthStore = defineStore('auth', () => {
  const token = ref(localStorage.getItem('token') || null)
  const role = ref(localStorage.getItem('role') || null)

  const isAdmin = ref(localStorage.getItem('isAdmin') === 'true')
  const isLoggedIn = ref(!!token.value)

  async function login(username, password) {
    const res = await api.post('/login', { username, password })
    token.value = res.data.token
    role.value = res.data.role
    isAdmin.value = res.data.role === 'ADMIN'
    isLoggedIn.value = true
    localStorage.setItem('token', token.value)
    localStorage.setItem('role', role.value)
    localStorage.setItem('isAdmin', isAdmin.value ? 'true' : 'false')
    return res.data
  }

  async function register(username, password) {
    const res = await api.post('/register', { username, password })
    token.value = res.data.token
    role.value = res.data.role
    isAdmin.value = res.data.role === 'ADMIN'
    isLoggedIn.value = true
    localStorage.setItem('token', token.value)
    localStorage.setItem('role', role.value)
    localStorage.setItem('isAdmin', isAdmin.value ? 'true' : 'false')
    return res.data
  }

  async function logout() {
    try {
      await api.post('/logout')
    } catch (e) {
    }
    token.value = null
    role.value = null
    isAdmin.value = false
    isLoggedIn.value = false
    localStorage.removeItem('token')
    localStorage.removeItem('role')
    localStorage.removeItem('isAdmin')
  }

  return { token, role, isAdmin, isLoggedIn, login, register, logout }
})
