import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../config/supabase_config.dart';

class StorageService {
  final _supabase = SupabaseConfig.client;
  final _uuid = const Uuid();

  // Upload a single image and return its URL
  Future<String> uploadImage(dynamic imageData, String userId) async {
    try {
      String fileExt;
      String fileName;
      String filePath;
      
      if (kIsWeb) {
        // For web, imageData is Uint8List
        final bytes = imageData as Uint8List;
        // Try to determine file extension from MIME type or default to .jpg
        fileExt = '.jpg'; // Default extension for web
        fileName = '${_uuid.v4()}$fileExt';
        filePath = 'products/$userId/$fileName';
        
        await _supabase.storage.from('products').uploadBinary(
          filePath,
          bytes,
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: false,
          ),
        );
      } else {
        // For mobile, imageData is File
        final file = imageData as File;
        fileExt = path.extension(file.path);
        fileName = '${_uuid.v4()}$fileExt';
        filePath = 'products/$userId/$fileName';
        
        await _supabase.storage.from('products').upload(
          filePath,
          file,
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: false,
          ),
        );
      }

      // Get the public URL for the uploaded file
      final imageUrl = _supabase.storage.from('products').getPublicUrl(filePath);
      print('Uploaded image URL: $imageUrl'); // Debug log
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e'); // Debug log
      throw Exception('Failed to upload image: $e');
    }
  }

  // Upload multiple images and return their URLs
  Future<List<String>> uploadImages(
      List<dynamic> imageDataList, String userId) async {
    try {
      final List<String> imageUrls = [];

      for (final imageData in imageDataList) {
        final url = await uploadImage(imageData, userId);
        imageUrls.add(url);
      }

      return imageUrls;
    } catch (e) {
      print('Error uploading images: $e'); // Debug log
      throw Exception('Failed to upload images: $e');
    }
  }

  // Delete an image from storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      // Extract the file path from the URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      
      // The path should be in the format: /storage/v1/object/public/products/path/to/file
      // We need to extract the 'products/path/to/file' part
      final productsIndex = pathSegments.indexOf('products');
      if (productsIndex >= 0 && productsIndex < pathSegments.length - 1) {
        final filePath = pathSegments.sublist(productsIndex + 1).join('/');
        print('Deleting image with path: $filePath'); // Debug log
        
        await _supabase.storage.from('products').remove([filePath]);
      } else {
        print('Invalid image URL format: $imageUrl'); // Debug log
      }
    } catch (e) {
      print('Error deleting image: $e'); // Debug log
      throw Exception('Failed to delete image: $e');
    }
  }

  // Delete multiple images from storage
  Future<void> deleteImages(List<String> imageUrls) async {
    try {
      for (final imageUrl in imageUrls) {
        await deleteImage(imageUrl);
      }
    } catch (e) {
      print('Error deleting images: $e'); // Debug log
      throw Exception('Failed to delete images: $e');
    }
  }
}
