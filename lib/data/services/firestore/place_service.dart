// lib/data/services/firestore/place_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aplikasi_wisata/data/models/place_model.dart';

class PlaceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _collection => _firestore.collection('places');

  // ── READ

  Stream<List<PlaceModel>> getAllPlaces() {
    return _collection.orderBy('name').snapshots().map(
          (snap) =>
              snap.docs.map((doc) => PlaceModel.fromFirestore(doc)).toList(),
        );
  }

  Stream<List<PlaceModel>> getByType(PlaceType type) {
    return _collection
        .where('placeType', isEqualTo: type.name)
        .orderBy('name')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => PlaceModel.fromFirestore(doc)).toList(),
        );
  }

  // ✅ NEW: Filter by categoryId
  Stream<List<PlaceModel>> getByCategoryId(String categoryId) {
    return _collection
        .where('categoryId', isEqualTo: categoryId)
        .orderBy('name')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => PlaceModel.fromFirestore(doc)).toList(),
        );
  }

  Future<PlaceModel?> getById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return PlaceModel.fromFirestore(doc);
  }

  // ── WRITE

  Future<String> createPlace(PlaceModel place) async {
    final ref = await _collection.add(place.toCreateMap());
    return ref.id;
  }

  Future<void> updatePlace(String id, PlaceModel place) async {
    await _collection.doc(id).update(place.toUpdateMap());
  }

  Future<void> deletePlace(String id) async {
    await _collection.doc(id).delete();
  }
}