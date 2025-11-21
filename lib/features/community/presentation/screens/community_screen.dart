import 'package:almonds/features/community/domain/entities/post.dart';
import 'package:almonds/features/community/domain/viewmodel/community_viewmodel.dart';
import 'package:almonds/features/community/presentation/widgets/post_card.dart';
import 'package:almonds/widgets/global/app_navigation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    context.read<CommunityViewModel>().getPosts();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CommunityViewModel>();

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground,
        border: null,
        middle: CupertinoSlidingSegmentedControl<int>(
          groupValue: _selectedTab,
          onValueChanged: (int? value) {
            if (value != null) {
              setState(() {
                _selectedTab = value;
              });
            }
          },
          children: const {
            0: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.list_bullet, size: 18),
                  SizedBox(width: 6),
                  Text('Community'),
                ],
              ),
            ),
            1: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.person, size: 18),
                  SizedBox(width: 6),
                  Text('Almonds'),
                ],
              ),
            ),
          },
        ),
      ),
      child: SafeArea(
        child: _selectedTab == 0
            ? Padding(
                padding: const EdgeInsets.all(18.0),
                child: ListView(
                  children: [
                    ...viewModel.posts.map((post) {
                      return PostCard(
                        post: post,
                      );
                    }).toList(),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(18.0),
                child: ListView(
                  children: [
                    PostCard(
                      post: Post(
                        id: 3,
                        title: "Following Content",
                        description:
                            "Content from people you follow will appear here.",
                        author: "John Smith",
                        upvotes: 45,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
