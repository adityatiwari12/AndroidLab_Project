import type { Config } from 'tailwindcss'

export default {
  content: ['./index.html', './src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: '#FF6B35',
          light: '#FFF3EE',
          dark: '#E8521A',
        },
        accent: '#FF9F1C',
        surface: '#FFFFFF',
        muted: '#F7F8FA',
        border: '#EEEEEE',
        divider: '#F3F4F6',
        'text-primary': '#111827',
        'text-secondary': '#6B7280',
        'text-muted': '#9CA3AF',
      },
      fontFamily: {
        display: ['Poppins', 'sans-serif'],
        body: ['DM Sans', 'sans-serif'],
      },
      boxShadow: {
        card: '0 2px 12px rgba(0,0,0,0.06)',
        elevated: '0 4px 24px rgba(0,0,0,0.10)',
        'accent-glow': '0 4px 20px rgba(255,107,53,0.28)',
      },
    },
  },
  plugins: [],
} satisfies Config
