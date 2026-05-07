// firestore_seed_packages.js
// Jalankan: node firestore_seed_packages.js
//
// Pastikan kedua file berada di folder yang sama:
//   - firestore_seed_packages.js
//   - package_data.json
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

const dataPath = path.join(__dirname, "package_data.json");

if (!fs.existsSync(dataPath)) {
  console.error("❌ File package_data.json tidak ditemukan!");
  console.error("   Pastikan file berada di folder yang sama dengan firestore_seed_packages.js");
  process.exit(1);
}

const seedData = JSON.parse(fs.readFileSync(dataPath, "utf-8"));
const packages = seedData.packages;

if (!Array.isArray(packages) || packages.length === 0) {
  console.error("❌ Key 'packages' tidak ditemukan atau kosong di package_data.json!");
  process.exit(1);
}

// ── VALIDASI DATA ──────────────────────────────────────────────────────────

function validateData() {
  const errors = [];

  packages.forEach((pkg) => {
    // Validasi field wajib
    if (!pkg.id) {
      errors.push(`❌ Ada package tanpa field 'id'`);
    }
    if (!pkg.name) {
      errors.push(`❌ Package "${pkg.id}" tidak punya field 'name'`);
    }

    // Validasi durationDays vs durationNights
    const days = pkg.durationDays;
    const nights = pkg.durationNights;
    if (typeof days === "number" && typeof nights === "number") {
      if (nights !== days - 1) {
        errors.push(
          `❌ Package "${pkg.name ?? pkg.id}" durationNights (${nights}) tidak sesuai dengan durationDays (${days})`
        );
      }
    }

    // Validasi tiers jika ada
    if (pkg.tiers && Array.isArray(pkg.tiers)) {
      pkg.tiers.forEach((tier, i) => {
        if (!tier.name) {
          errors.push(`❌ Package "${pkg.id}" tier ke-${i + 1} tidak punya 'name'`);
        }
        if (typeof tier.price !== "number") {
          errors.push(`❌ Package "${pkg.id}" tier "${tier.name}" price bukan number`);
        }
      });
    }
  });

  return errors;
}

// ── NORMALISASI DATA ───────────────────────────────────────────────────────

function normalizeItem(item) {
  const { id, ...rest } = item;
  const payload = { ...rest };
  if (!payload.createdAt) {
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
    console.log("🔍 Memvalidasi data packages...");
    const errors = validateData();

    if (errors.length > 0) {
      console.error("\n⚠️  Ditemukan masalah pada data:");
      errors.forEach((e) => console.error(`   ${e}`));
      console.error("\nSeed dibatalkan. Perbaiki data terlebih dahulu.");
      process.exit(1);
    }

    console.log("✅ Validasi data berhasil!\n");
    console.log("🚀 Memulai seed data packages ke Firestore...");

    await seedCollection("packages", packages);

    console.log("\n🎉 Semua data berhasil di-seed!");
    console.log("📊 Total dokumen:");
    console.log(`   - packages: ${packages.length}`);

    process.exit(0);
  } catch (error) {
    console.error("❌ Error saat seed:", error);
    process.exit(1);
  }
}

main();