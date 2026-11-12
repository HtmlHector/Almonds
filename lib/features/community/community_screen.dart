import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/state_views.dart';
import '../../core/theme/ios.dart';
import '../../state/community_controller.dart';
import 'new_post_sheet.dart';
import 'post_card.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final community = context.watch<CommunityController>();

    Widget? state;
    if (community.loading && community.posts.isEmpty) {
      state = const Center(child: CupertinoActivityIndicator(radius: 14));
    } else if (community.error != null && community.posts.isEmpty) {
      state = StateMessage(
        icon: CupertinoIcons.wifi_slash,
        title: 'Something Went Wrong',
        message: community.error,
        actionLabel: 'Try Again',
        onAction: community.load,
      );
    } else if (community.posts.isEmpty) {
      state = StateMessage(
        icon: CupertinoIcons.chat_bubble_2,
        title: 'Start the Conversation',
        message: 'Ask about an ingredient or share a find with other scanners.',
        actionLabel: 'Write a Post',
        onAction: () => showNewPostSheet(context),
      );
    }

    return CupertinoPageScaffold(
      backgroundColor: context.groupedBackground,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('Community'),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size(32, 32),
              onPressed: () => showNewPostSheet(context),
              child: const Icon(CupertinoIcons.square_pencil),
            ),
          ),
          CupertinoSliverRefreshControl(onRefresh: community.load),
          if (state != null)
            SliverFillRemaining(hasScrollBody: false, child: state)
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              sliver: SliverList.separated(
                itemCount: community.posts.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, i) => PostCard(post: community.posts[i]),
              ),
            ),
        ],
      ),
    );
  }
}
