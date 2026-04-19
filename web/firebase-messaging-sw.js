/* eslint-disable no-restricted-globals */
//
// Hayati Firebase Messaging service worker.
//
// Phase 1 status: SCAFFOLD ONLY. Installs and claims clients so the SW file
// path and lifecycle are exercised end-to-end, but no FCM background
// handler is registered yet. Web push (FCM topics `village_{id}`,
// `village_{id}_service_{type}`) lands in Phase 2 per
// `hayati-architecture.md` §3 and §26.
//
// When Phase 2 enables web push, replace this file with the following
// shape (do NOT commit real API keys — Firebase web config is public-safe
// but we keep the SW in the same --dart-define pipeline as the app):
//
//   importScripts('https://www.gstatic.com/firebasejs/<vX.Y.Z>/firebase-app-compat.js');
//   importScripts('https://www.gstatic.com/firebasejs/<vX.Y.Z>/firebase-messaging-compat.js');
//   firebase.initializeApp({ apiKey, authDomain, projectId, messagingSenderId, appId });
//   const messaging = firebase.messaging();
//   messaging.onBackgroundMessage(({ notification }) => {
//     self.registration.showNotification(notification.title, {
//       body: notification.body,
//       icon: '/icons/Icon-192.png',
//       dir: 'rtl',
//       lang: 'ar',
//     });
//   });
//
// Until then, intentionally keep the SW silent so it cannot accidentally
// show notifications from a stale version.

self.addEventListener('install', (event) => {
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(self.clients.claim());
});
