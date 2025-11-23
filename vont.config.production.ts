import { defineConfig } from 'vont';
import tailwindcss from '@tailwindcss/vite';
import react from '@vitejs/plugin-react';

/**
 * Vont Framework Production Configuration
 * 
 * Optimized configuration for production deployments on Vercel.
 * This config focuses on performance, security, and reliability.
 */
export default defineConfig({
  // Server settings - read from environment variables (Vercel provides PORT)
  port: parseInt(process.env.PORT || '3000'),
  host: '0.0.0.0',

  // API prefix for backend routes
  apiPrefix: '/api',

  // Build configuration
  build: {
    sourcemap: false,        // Disable sourcemaps in production for smaller bundle size
    minify: true,           // Enable minification
  },

  // Vite configuration
  viteConfig: {
    plugins: [
      tailwindcss(),
      react(),
    ],
    
    // Production build optimizations
    build: {
      target: 'es2020',
      cssCodeSplit: true,     // Split CSS for better caching
      
      // Rollup options for advanced bundling
      rollupOptions: {
        output: {
          // Manual chunk splitting for better caching
          manualChunks: {
            'react-vendor': ['react', 'react-dom', 'react-router-dom'],
          },
          
          // Asset naming for better cache control
          assetFileNames: 'assets/[name]-[hash][extname]',
          chunkFileNames: 'assets/[name]-[hash].js',
          entryFileNames: 'assets/[name]-[hash].js',
        },
      },
      
      // Build performance
      chunkSizeWarningLimit: 1000,
    },
    
    // Define environment variables for client-side
    define: {
      'process.env.NODE_ENV': JSON.stringify('production'),
    },
  },
});

