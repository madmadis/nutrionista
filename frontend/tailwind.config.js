/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{vue,js,ts}'],
  theme: {
    extend: {
      colors: {
        primary: '#e6007a',
        secondary: '#90ee90',
        background: '#f8f8f8',
        surface: '#ffffff',
        border: '#dddddd',
      },
    },
  },
  plugins: [],
}
