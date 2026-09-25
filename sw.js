// Service worker: permite abrir la app sin señal (en yacimiento).
// Los datos no pasan por acá: se guardan en el equipo y se sincronizan con Supabase.
const CACHE = 'blau-vru-v1';
const ARCHIVOS = [
  './', './index.html', './config.js', './manifest.json',
  './icons/icon-192.png', './icons/icon-512.png',
  'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2.117.2/dist/umd/supabase.js'
];

self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(ARCHIVOS)).then(() => self.skipWaiting()));
});

self.addEventListener('activate', e => {
  e.waitUntil(caches.keys().then(ks => Promise.all(ks.filter(k => k !== CACHE).map(k => caches.delete(k))))
    .then(() => self.clients.claim()));
});

self.addEventListener('fetch', e => {
  const req = e.request;
  if (req.method !== 'GET') return;
  const url = new URL(req.url);
  if (url.hostname.endsWith('supabase.co')) return;           // API y fotos: siempre a la red
  const propio = url.origin === self.location.origin;
  if (!propio && !url.hostname.endsWith('jsdelivr.net')) return;
  // Red primero (para tomar actualizaciones); si no hay señal, usa la copia guardada
  e.respondWith(
    fetch(req).then(res => {
      if (res.ok) { const copia = res.clone(); caches.open(CACHE).then(c => c.put(req, copia)); }
      return res;
    }).catch(() => caches.match(req).then(r => r || (req.mode === 'navigate' ? caches.match('./index.html') : undefined)))
  );
});
