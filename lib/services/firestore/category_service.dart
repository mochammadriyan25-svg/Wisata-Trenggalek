import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference get _collection =>
      _firestore.collection('category');

  // =====================================================
  // GET ALL CATEGORIES (Realtime)
  // =====================================================
  Stream<List<CategoryModel>> getAllCategories() {
    return _collection
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data =
            doc.data() as Map<String, dynamic>;

        return CategoryModel.fromFirestore(
          doc.id,
          data,
        );
      }).toList();
    });
  }

  // =====================================================
  // GET CATEGORY BY ID
  // =====================================================
  Future<CategoryModel?> getById(
      String id) async {
    final doc =
        await _collection.doc(id).get();

    if (!doc.exists) return null;

    final data =
        doc.data() as Map<String, dynamic>;

    return CategoryModel.fromFirestore(
      doc.id,
      data,
    );
  }
}