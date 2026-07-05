const admin = require('firebase-admin');

const projectId = process.env.FIREBASE_PROJECT_ID;
const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
const privateKeyRaw = process.env.FIREBASE_PRIVATE_KEY;

if (!projectId || !clientEmail || !privateKeyRaw) {
  throw new Error(
    'Firebase config error: FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, and FIREBASE_PRIVATE_KEY must all be set in .env'
  );
}

const privateKey = privateKeyRaw.replace(/\\n/g, '\n');

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert({
      projectId,
      clientEmail,
      privateKey,
    }),
  });
}

module.exports = admin;
