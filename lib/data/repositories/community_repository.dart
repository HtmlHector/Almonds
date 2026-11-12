import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/post.dart';

class CommunityRepository {
  CommunityRepository(this._client);

  final SupabaseClient _client;

  Future<List<Post>> feed() async {
    final rows = await _client
        .from('post_feed')
        .select()
        .order('created_at', ascending: false)
        .limit(100);
    return rows.map(Post.fromRow).toList();
  }

  Future<void> createPost({
    required String title,
    required String body,
    String? productBarcode,
    String? productName,
  }) async {
    await _client.from('posts').insert({
      'title': title,
      'body': body,
      'product_barcode': productBarcode,
      'product_name': productName,
    });
  }

  Future<void> deletePost(String id) async {
    await _client.from('posts').delete().eq('id', id);
  }

  /// [value] is 1, -1 or 0 (remove vote).
  Future<void> vote(String postId, int value) async {
    final uid = _client.auth.currentUser!.id;
    if (value == 0) {
      await _client
          .from('post_votes')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', uid);
    } else {
      await _client.from('post_votes').upsert({
        'post_id': postId,
        'user_id': uid,
        'value': value,
      }, onConflict: 'post_id,user_id');
    }
  }

  Future<List<Comment>> comments(String postId) async {
    final rows = await _client
        .from('comments')
        .select('id,user_id,body,created_at,profiles(username)')
        .eq('post_id', postId)
        .order('created_at');
    return rows.map(Comment.fromRow).toList();
  }

  Future<void> addComment(String postId, String body) async {
    await _client.from('comments').insert({'post_id': postId, 'body': body});
  }

  Future<void> reportPost(String postId, String reason) async {
    await _client.from('post_reports').upsert({
      'post_id': postId,
      'reason': reason,
    }, onConflict: 'post_id,reporter_id');
  }

  Future<void> blockUser(String userId) async {
    await _client.from('blocked_users').upsert({
      'blocked_id': userId,
    }, onConflict: 'blocker_id,blocked_id');
  }
}
