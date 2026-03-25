import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post_model.dart';
import 'package:uuid/uuid.dart';

class PostRepository {
  final _supabase = Supabase.instance.client;

  Future<bool> createPost(String userId, String text, File? imageFile) async {
    try {
      String? imageUrl;

      // 1. Upload image if provided
      if (imageFile != null) {
        final fileExt = imageFile.path.split('.').last;
        final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        final storagePath = 'posts/$fileName';

        await _supabase.storage.from('posts').upload(
              storagePath,
              imageFile,
              fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
            );

        imageUrl = _supabase.storage.from('posts').getPublicUrl(storagePath);
      }

      // 2. Insert record into 'posts' table
      final newPost = PostModel(
        id: const Uuid().v4(),
        userId: userId,
        text: text,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      );

      await _supabase.from('posts').insert(newPost.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<PostModel>> getUserPosts(String userId) async {
    try {
      final response = await _supabase
          .from('posts')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
          
      return (response as List).map((json) => PostModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}
