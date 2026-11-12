import 'package:flutter/foundation.dart';

import '../data/models/post.dart';
import '../data/repositories/community_repository.dart';

class CommunityController extends ChangeNotifier {
  CommunityController(this._repo);

  final CommunityRepository _repo;

  List<Post> posts = [];
  bool loading = false;
  String? error;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      posts = await _repo.feed();
    } catch (_) {
      error = 'Could not load the community feed.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void clear() {
    posts = [];
    notifyListeners();
  }

  Future<void> create({
    required String title,
    required String body,
    String? productBarcode,
    String? productName,
  }) async {
    await _repo.createPost(
      title: title,
      body: body,
      productBarcode: productBarcode,
      productName: productName,
    );
    await load();
  }

  Future<void> delete(Post post) async {
    posts = posts.where((p) => p.id != post.id).toList();
    notifyListeners();
    try {
      await _repo.deletePost(post.id);
    } catch (_) {
      await load();
    }
  }

  /// Optimistic up/down vote. Tapping the active direction clears the vote.
  Future<void> vote(Post post, int direction) async {
    final next = post.myVote == direction ? 0 : direction;
    final updated = post.copyWith(
      votes: post.votes - post.myVote + next,
      myVote: next,
    );
    _swap(updated);
    try {
      await _repo.vote(post.id, next);
    } catch (_) {
      _swap(post);
    }
  }

  Future<void> report(Post post, String reason) async {
    await _repo.reportPost(post.id, reason);
    // Hide it right away; the report is reviewed separately.
    posts = posts.where((p) => p.id != post.id).toList();
    notifyListeners();
  }

  Future<void> block(Post post) async {
    await _repo.blockUser(post.userId);
    posts = posts.where((p) => p.userId != post.userId).toList();
    notifyListeners();
  }

  void bumpComments(String postId, int delta) {
    for (final p in posts) {
      if (p.id == postId) {
        _swap(p.copyWith(commentCount: p.commentCount + delta));
        break;
      }
    }
  }

  void _swap(Post post) {
    posts = [for (final p in posts) p.id == post.id ? post : p];
    notifyListeners();
  }
}
