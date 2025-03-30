import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'dart:html' as html;

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<String?> uploadImage(XFile imageFile) async {
    try {
      // For web, we only need to handle XFile
      final bytes = await imageFile.readAsBytes();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.name)}';

      final response = await _client.storage
          .from('images')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final imageUrl = _client.storage.from('images').getPublicUrl(fileName);

      // Log upload success based on environment
      final isLocalhost =
          html.window.location.href.contains('localhost') ||
          html.window.location.href.contains('127.0.0.1');

      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}
