import 'package:almonds/features/community/domain/entities/post.dart';
import 'package:almonds/features/community/presentation/widgets/post_card.dart';
import 'package:flutter/material.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            PostCard(
              post: Post(
                id: 2,
                title: "Exploring Flutter 3.0",
                description:
                    "An in-depth look at the new features and improvements in Flutter 3.0, including performance enhancements and new widgets.",
                author: "Jane Doe",
                upvotes: 128,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
