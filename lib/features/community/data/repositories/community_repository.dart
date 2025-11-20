import '../../../../../utilities/database.dart';
import '../../domain/entities/post.dart';

class CommunityRepository {
  static Future<List<Post>> getPostsHandler() async {
    final database = Database.supabase;

    List<Post> posts = [];

    // Gets all posts from Posts table
    final response = await database.from('posts').select();

    // Loops through fetched posts and adds to array
    for (var post in response) {
      posts.add(
        Post(
          id: post["id"],
          title: post["title"],
          description: post["description"],
          author: "Hector",
          upvotes: post["votes"],
        ),
      );
    }

    return posts;
  }
}
