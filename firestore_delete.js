 // firestore_delete.js
// Jalankan: node firestore_delete.js
//
// Script ini akan menghapus semua dokumen dari collection:
//   - category
//   - destinations
//   - accommodations
//   - packages
//
// Collection TIDAK akan dihapus:
//   - users
//   - favorites
//   - reviews

const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// ── COLLECTION YANG AKAN DIHAPUS ──────────────────────────────────────────

const collectionsToDelete = [
  "category",
  "destinations",
  "accommodations",
  "packages",
];

// ── DELETE FUNCTION ────────────────────────────────────────────────────────

async function deleteCollection(collectionName) {
  console.log(`\n⏳ Menghapus collection: ${collectionName}...`);

  const snapshot = await db.collection(collectionName).get();

  if (snapshot.empty) {
    console.log(`⚠️  Collection [${collectionName}] sudah kosong, dilewati.`);
    return 0;
  }

  // Hapus per batch (max 500 per batch)
  const chunkSize = 400;
  const docs = snapshot.docs;
  const chunks = [];

  for (let i = 0; i < docs.length; i += chunkSize) {
    chunks.push(docs.slice(i, i + chunkSize));
  }

  let total = 0;
  for (const chunk of chunks) {
    const batch = db.batch();
    chunk.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();
    total += chunk.length;
  }

  console.log(`✅ ${total} dokumen berhasil dihapus dari [${collectionName}]`);
  return total;
}

// ── MAIN ───────────────────────────────────────────────────────────────────

async function main() {
  try {
    console.log("🗑️  Memulai penghapusan data Firestore...");
    console.log("⚠️  Collection yang TIDAK akan dihapus: users, favorites, reviews\n");

    let grandTotal = 0;

    for (const collectionName of collectionsToDelete) {
      const total = await deleteCollection(collectionName);
      grandTotal += total;
    }

    console.log("\n🎉 Penghapusan selesai!");
    console.log(`🗑️  Total dokumen dihapus: ${grandTotal}`);
    console.log("\n➡️  Sekarang jalankan: node firestore_seed.js");

    process.exit(0);
  } catch (error) {
    console.error("❌ Error saat menghapus:", error);
    process.exit(1);
  }
}

main();