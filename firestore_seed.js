// firestore_seed.js
// Jalankan: node firestore_seed.js
//
// Pastikan kedua file berada di folder yang sama:
//   - firestore_seed.js
//   - firestore_seed_data.json
//   - serviceAccountKey.json

const admin = require("firebase-admin");
const fs = require("fs");
const path = require("path");
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// ── LOAD DATA DARI JSON ────────────────────────────────────────────────────

const dataPath = path.join(__dirname, "firestore_seed_data.json");

if (!fs.existsSync(dataPath)) {
  console.error("❌ File firestore_seed_data.json tidak ditemukan!");
  console.error("   Pastikan file berada di folder yang sama dengan firestore_seed.js");
  process.exit(1);
}

const seedData = JSON.parse(fs.readFileSync(dataPath, "utf-8"));
const { categories, destinations, accommodations, packages } = seedData;

// ── VALIDASI DATA ──────────────────────────────────────────────────────────

function validateData() {
  const errors = [];

  // Kumpulkan semua category ID
  const categoryIds = new Set(categories.map((c) => c.id));

  // Kumpulkan semua destination ID
  const destinationIds = new Set(destinations.map((d) => d.id));

  // Validasi categoryId di destinations
  destinations.forEach((dest) => {
    if (!categoryIds.has(dest.data?.categoryId ?? dest.categoryId)) {
      errors.push(`❌ Destination "${dest.name ?? dest.id}" punya categoryId tidak valid: "${dest.data?.categoryId ?? dest.categoryId}"`);
    }
    if (dest.hasVirtualTour && !dest.maps360Url) {
      errors.push(`❌ Destination "${dest.name ?? dest.id}" hasVirtualTour=true tapi maps360Url kosong`);
    }
  });

  // Validasi categoryId di accommodations
  accommodations.forEach((acc) => {
    if (!categoryIds.has(acc.data?.categoryId ?? acc.categoryId)) {
      errors.push(`❌ Accommodation "${acc.name ?? acc.id}" punya categoryId tidak valid: "${acc.data?.categoryId ?? acc.categoryId}"`);
    }
    if (acc.hasVirtualTour && !acc.maps360Url) {
      errors.push(`❌ Accommodation "${acc.name ?? acc.id}" hasVirtualTour=true tapi maps360Url kosong`);
    }
  });

  // Validasi destinationIds di packages
  packages.forEach((pkg) => {
    const destIds = pkg.data?.destinationIds ?? pkg.destinationIds ?? [];
    destIds.forEach((destId) => {
      if (!destinationIds.has(destId)) {
        errors.push(`❌ Package "${pkg.name ?? pkg.id}" punya destinationId tidak valid: "${destId}"`);
      }
    });
    const days = pkg.data?.durationDays ?? pkg.durationDays;
    const nights = pkg.data?.durationNights ?? pkg.durationNights;
    if (nights !== days - 1) {
      errors.push(`❌ Package "${pkg.name ?? pkg.id}" durationNights (${nights}) tidak sesuai dengan durationDays (${days})`);
    }
  });

  return errors;
}

// ── NORMALISASI DATA ───────────────────────────────────────────────────────
// Mendukung format flat (tanpa wrapper "data") dari JSON

function normalizeItem(item, addTimestamp = true) {
  const { id, data, ...rest } = item;
  const payload = data ?? rest;
  if (addTimestamp && !payload.createdAt) {
    payload.createdAt = admin.firestore.FieldValue.serverTimestamp();
  }
  return { id, data: payload };
}

// ── SEED FUNCTION ──────────────────────────────────────────────────────────

async function seedCollection(collectionName, items) {
  console.log(`\n⏳ Seeding collection: ${collectionName}...`);

  const normalized = items.map((item) => normalizeItem(item));

  // Firestore batch max 500 ops — split jika perlu
  const chunkSize = 400;
  const chunks = [];
  for (let i = 0; i < normalized.length; i += chunkSize) {
    chunks.push(normalized.slice(i, i + chunkSize));
  }

  let total = 0;
  for (const chunk of chunks) {
    const batch = db.batch();
    chunk.forEach(({ id, data }) => {
      const ref = db.collection(collectionName).doc(id);
      batch.set(ref, data);
    });
    await batch.commit();
    total += chunk.length;
  }

  console.log(`✅ ${total} dokumen berhasil ditambahkan ke [${collectionName}]`);
}

// ── MAIN ───────────────────────────────────────────────────────────────────

async function main() {
  try {
    console.log("🔍 Memvalidasi data...");
    const errors = validateData();

    if (errors.length > 0) {
      console.error("\n⚠️  Ditemukan masalah pada data:");
      errors.forEach((e) => console.error(`   ${e}`));
      console.error("\nSeed dibatalkan. Perbaiki data terlebih dahulu.");
      process.exit(1);
    }

    console.log("✅ Validasi data berhasil!\n");
    console.log("🚀 Memulai seed data Firestore...");

    await seedCollection("category", categories);
    await seedCollection("destinations", destinations);
    await seedCollection("accommodations", accommodations);
    await seedCollection("packages", packages);

    console.log("\n🎉 Semua data berhasil di-seed!");
    console.log("📊 Total dokumen:");
    console.log(`   - category      : ${categories.length}`);
    console.log(`   - destinations  : ${destinations.length}`);
    console.log(`   - accommodations: ${accommodations.length}`);
    console.log(`   - packages      : ${packages.length}`);
    console.log(`   ──────────────────────────`);
    console.log(`   Total           : ${categories.length + destinations.length + accommodations.length + packages.length}`);

    process.exit(0);
  } catch (error) {
    console.error("❌ Error saat seed:", error);
    process.exit(1);
  }
}

main();