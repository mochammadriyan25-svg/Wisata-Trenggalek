// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'package:intl/date_symbol_data_local.dart'; // ← tambah import ini

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null); // ← tambah baris ini

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const TrenggalekTourismApp());
}
