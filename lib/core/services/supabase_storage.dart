import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class FileStorageService {
  FileStorageService(this.bucketName);

  final String bucketName;
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<String?> uploadFile({
    required String filePath,
    required Uint8List fileBytes,
  }) async {
    try {
      await _supabaseClient.storage
          .from(bucketName)
          .uploadBinary(
            filePath,
            fileBytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final String publicUrl = _supabaseClient.storage
          .from(bucketName)
          .getPublicUrl(filePath);

      return publicUrl;
    } on StorageException catch (e) {
      print('Supabase Storage Upload Error: ${e.message}');
      return null;
    } catch (e) {
      print('An unexpected error occurred during upload: $e');
      return null;
    }
  }

  Future<Uint8List?> downloadFile(String filePath) async {
    try {
      final Uint8List fileBytes = await _supabaseClient.storage
          .from(bucketName)
          .download(filePath);
      return fileBytes;
    } on StorageException catch (e) {
      print('Supabase Storage Download Error: ${e.message}');
      return null;
    } catch (e) {
      print('An unexpected error occurred during download: $e');
      return null;
    }
  }

  Future<List<FileObject>?> listFiles({String path = ''}) async {
    try {
      final List<FileObject> files = await _supabaseClient.storage
          .from(bucketName)
          .list(path: path);
      return files;
    } on StorageException catch (e) {
      print('Supabase Storage List Error: ${e.message}');
      return null;
    } catch (e) {
      print('An unexpected error occurred during list: $e');
      return null;
    }
  }

  Future<bool> deleteFiles(List<String> filePaths) async {
    try {
      await _supabaseClient.storage.from(bucketName).remove(filePaths);
      return true;
    } on StorageException catch (e) {
      print('Supabase Storage Delete Error: ${e.message}');
      return false;
    } catch (e) {
      print('An unexpected error occurred during delete: $e');
      return false;
    }
  }
}
