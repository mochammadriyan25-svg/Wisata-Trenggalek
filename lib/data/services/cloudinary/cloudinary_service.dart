// lib/data/services/cloudinary/cloudinary_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:aplikasi_wisata/core/constants/api_keys.dart';

class CloudinaryService {
  CloudinaryService._();
  static final CloudinaryService instance = CloudinaryService._();

  static const Duration _timeout = Duration(seconds: 30);

  /// Upload satu file gambar ke Cloudinary (unsigned upload preset).
  /// Return `secure_url` (https) yang langsung disimpan ke Firestore.
  Future<String> uploadImage(File file, {String? folder}) async {
    if (!await file.exists()) {
      throw Exception('File tidak ditemukan: ${file.path}');
    }

    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/${ApiKeys.cloudinaryCloudName}/image/upload',
    );

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = ApiKeys.cloudinaryUploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    if (folder != null && folder.isNotEmpty) {
      request.fields['folder'] = folder;
    }

    try {
      final streamed = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode != 200) {
        throw Exception(
          'Upload Cloudinary gagal (${response.statusCode}): ${response.body}',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['secure_url'] as String;
    } on SocketException {
      throw Exception('Tidak ada koneksi internet.');
    } on HttpException {
      throw Exception('Gagal terhubung ke server Cloudinary.');
    } catch (e) {
      throw Exception('Upload gagal: $e');
    }
  }

  /// Upload beberapa gambar sekaligus, mengembalikan list secure_url.
  /// Cocok untuk galeri foto destinasi wisata.
  Future<List<String>> uploadMultipleImages(
    List<File> files, {
    String? folder,
  }) async {
    final results = <String>[];
    for (final file in files) {
      final secureUrl = await uploadImage(file, folder: folder);
      results.add(secureUrl);
    }
    return results;
  }
}