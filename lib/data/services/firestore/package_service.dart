// lib/data/services/firestore/package_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aplikasi_wisata/data/models/package_model.dart';

class PackageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _collection =>
      _firestore.collection('packages');

  // GET ALL ACTIVE PACKAGES (Realtime)
  Stream<List<PackageModel>> getActivePackages() {
    return _collection
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PackageModel.fromFirestore(doc))
          .toList();
    });
  }

  // GET ALL PACKAGES (Realtime)
  Stream<List<PackageModel>> getAllPackages() {
    return _collection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => PackageModel.fromFirestore(doc))
          .toList();
    });
  }

  // GET SINGLE PACKAGE BY ID
  Future<PackageModel?> getById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return PackageModel.fromFirestore(doc);
  }
}