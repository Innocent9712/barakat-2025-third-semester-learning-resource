import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react-swc'
import tailwindcss from '@tailwindcss/vite'
import { tanstackRouter } from '@tanstack/router-plugin/vite'

// Read proxy target from environment variable, fallback to localhost:8000
const apiProxyTarget = process.env.VITE_API_PROXY_TARGET || 'http://localhost:8000'

export default defineConfig({
    plugins: [
        tanstackRouter({
            target: 'react',
            autoCodeSplitting: true,
        }),
        react(),
        tailwindcss()
    ],
    // server: {
    //     port: 5173,
    //     proxy: {
    //         '/api': {
    //             target: apiProxyTarget,
    //             changeOrigin: true,
    //             rewrite: (path) => path.replace(/^\/api/, '')
    //         }
    //     }
    // }
})
