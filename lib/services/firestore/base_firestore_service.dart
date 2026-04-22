//services/base_firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BaseFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Getter untuk akses ke database instance
  FirebaseFirestore get db => _db;
  
  // Helper method untuk error handling
  Exception handleError(String operation, dynamic error) {
    return Exception('$operation: $error');
  }
  
  // Helper method untuk batch operations
  WriteBatch createBatch() => _db.batch();
  
  // Helper method untuk transactions
  Future<T> runTransaction<T>(TransactionHandler<T> updateFunction) {
    return _db.runTransaction<T>(updateFunction);
  }
}