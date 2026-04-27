// firestore_backup.js
// Jalankan: node firestore_backup.js

const admin = require("firebase-admin");
const fs = require("fs");
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// ── COLLECTION YANG AKAN DI-BACKUP ────────────────────────────────────────
const collections = [
  "category",
  "destinations",
  "packages",
  "accommodations",
  "users",
  "favorites",
  "reviews",
];

// ── BACKUP FUNCTION ────────────────────────────────────────────────────────

async function backupCollection(collectionName) {
  console.log(`\n⏳ Backup collection: ${collectionName}...`);

  const snapshot = await db.collection(collectionName).get();

  if (snapshot.empty) {
    console.log(`⚠️  Collection [${collectionName}] kosong, dilewati.`);
    return {};
  }

  const data = {};
  snapshot.forEach((doc) => {
    data[doc.id] = doc.data();
  });

  console.log(`✅ ${snapshot.size} dokumen berhasil di-backup dari [${collectionName}]`);
  return data;
}

async function main() {
  try {
    console.log("🚀 Memulai backup Firestore...");

    const backup = {};

    for (const collectionName of collections) {
      backup[collectionName] = await backupCollection(collectionName);
    }

    // ── SIMPAN KE FILE JSON ──────────────────────────────────────────────
    const timestamp = new Date().toISOString().replace(/[:.]/g, "-");
    const filename = `firestore_backup_${timestamp}.json`;

    fs.writeFileSync(filename, JSON.stringify(backup, null, 2), "utf-8");

    console.log(`\n🎉 Backup selesai! File tersimpan: ${filename}`);
    process.exit(0);
  } catch (error) {
    console.error("❌ Error saat backup:", error);
    process.exit(1);
  }
}

main();