import 'package:almonds/features/community/domain/entities/post.dart';
import 'package:almonds/features/community/domain/viewmodel/community_viewmodel.dart';
import 'package:almonds/features/community/presentation/widgets/post_card.dart';
import 'package:almonds/widgets/global/app_navigation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<CommunityViewModel>().getPosts();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CommunityViewModel>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
              ),
              child: TabBar(
                indicatorColor: Colors.black,
                indicatorWeight: 2,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                tabs: const [
                  Tab(text: "Community", icon: Icon(Icons.list)),
                  Tab(text: "Almonds", icon: Icon(Icons.person)),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // For You Tab
            Padding(
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
            ),
            // Following Tab
            Padding(
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
          ],
        ),
        bottomNavigationBar: AppNavigation(3),
      ),
    );
  }
}
