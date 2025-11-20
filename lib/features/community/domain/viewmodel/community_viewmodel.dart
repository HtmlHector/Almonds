import 'package:flutter/cupertino.dart';

import '../../data/repositories/community_repository.dart';
import '../entities/post.dart';

class CommunityViewModel extends ChangeNotifier {
  List posts = [];

  Future<void> getPosts() async {
    print("Hello World!");
    List<Post> fetchedPosts = await CommunityRepository.getPostsHandler();
    posts.clear(); // Clear existing posts before adding new ones
    posts.addAll(fetchedPosts);
    print(posts);
    notifyListeners();
  }
}
