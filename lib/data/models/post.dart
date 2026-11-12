class Post {
  const Post({
    required this.id,
    required this.userId,
    required this.author,
    required this.title,
    required this.body,
    required this.votes,
    required this.myVote,
    required this.commentCount,
    required this.createdAt,
    this.productBarcode,
    this.productName,
  });

  final String id;
  final String userId;
  final String author;
  final String title;
  final String body;
  final int votes;

  /// The signed-in user's vote: -1, 0 or 1.
  final int myVote;
  final int commentCount;
  final DateTime createdAt;
  final String? productBarcode;
  final String? productName;

  Post copyWith({int? votes, int? myVote, int? commentCount}) => Post(
    id: id,
    userId: userId,
    author: author,
    title: title,
    body: body,
    votes: votes ?? this.votes,
    myVote: myVote ?? this.myVote,
    commentCount: commentCount ?? this.commentCount,
    createdAt: createdAt,
    productBarcode: productBarcode,
    productName: productName,
  );

  factory Post.fromRow(Map<String, dynamic> r) => Post(
    id: r['id'] as String,
    userId: r['user_id'] as String,
    author: r['author'] as String,
    title: r['title'] as String,
    body: (r['body'] as String?) ?? '',
    votes: (r['votes'] as num?)?.toInt() ?? 0,
    myVote: (r['my_vote'] as num?)?.toInt() ?? 0,
    commentCount: (r['comment_count'] as num?)?.toInt() ?? 0,
    createdAt: DateTime.parse(r['created_at'] as String).toLocal(),
    productBarcode: r['product_barcode'] as String?,
    productName: r['product_name'] as String?,
  );
}

class Comment {
  const Comment({
    required this.id,
    required this.userId,
    required this.author,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String author;
  final String body;
  final DateTime createdAt;

  factory Comment.fromRow(Map<String, dynamic> r) => Comment(
    id: r['id'] as String,
    userId: r['user_id'] as String,
    author:
        ((r['profiles'] as Map<String, dynamic>?)?['username'] as String?) ??
        'user',
    body: r['body'] as String,
    createdAt: DateTime.parse(r['created_at'] as String).toLocal(),
  );
}
