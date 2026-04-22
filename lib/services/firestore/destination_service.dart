import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/destination_model.dart';

class DestinationService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference get _collection =>
      _firestore.collection('destinations');

  // =====================================================
  // GET ALL DESTINATIONS (Realtime)
  // =====================================================
Stream<List<DestinationModel>> getAllDestinations() {
return _collection.snapshots().map((snapshot) {
return snapshot.docs
.map((doc) =>
DestinationModel.fromFirestore(doc))
.toList();
});
}

  // =====================================================
  // GET RECOMMENDED DESTINATIONS
  // =====================================================
  Stream<List<DestinationModel>>
      getRecommendedDestinations() {
    return _collection
        .where('isRecommended',
            isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              DestinationModel
                  .fromFirestore(doc))
          .toList();
    });
  }

  // =====================================================
  // GET DESTINATIONS BY CATEGORY
  // =====================================================
  Stream<List<DestinationModel>>
      getByCategory(String category) {
    return _collection
        .where('category',
            isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              DestinationModel
                  .fromFirestore(doc))
          .toList();
    });
  }

  // =====================================================
  // SEARCH DESTINATIONS BY NAME
  // =====================================================
  Stream<List<DestinationModel>>
      searchByName(String keyword) {
    return _collection
        .where('name',
            isGreaterThanOrEqualTo:
                keyword)
        .where('name',
            isLessThanOrEqualTo:
                '$keyword\uf8ff')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              DestinationModel
                  .fromFirestore(doc))
          .toList();
    });
  }

  // =====================================================
  // GET SINGLE DESTINATION BY ID
  // =====================================================
  Future<DestinationModel?>
      getById(String id) async {
    final doc =
        await _collection.doc(id).get();

    if (!doc.exists) return null;

    return DestinationModel
        .fromFirestore(doc);
  }
}