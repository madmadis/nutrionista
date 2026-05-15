import { defineStore } from 'pinia'

export const useCartStore = defineStore('cart', {
    state: () => ({
        items: []
    }),
    getters: {
        total: (state) =>
            state.items.reduce((sum, item) => sum + parseFloat(item.price) * item.qty, 0).toFixed(2),
        count: (state) =>
            state.items.reduce((sum, item) => sum + item.qty, 0)
    },
    actions: {
        addItem(product) {
            const existing = this.items.find(i => i.id === product.id)
            if (existing) {
                existing.qty++
            } else {
                this.items.push({ ...product, qty: 1 })
            }
        },
        removeItem(id) {
            this.items = this.items.filter(i => i.id !== id)
        },
        clear() {
            this.items = []
        }
    }
})