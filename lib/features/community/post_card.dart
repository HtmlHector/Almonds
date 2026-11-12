import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/ios.dart';
import '../../core/widgets/dialogs.dart';
import '../../data/models/post.dart';
import '../../state/auth_controller.dart';
import '../../state/community_controller.dart';
import 'post_detail_screen.dart';

String timeAgo(DateTime t) {
  final d = DateTime.now().difference(t);
  if (d.inMinutes < 1) return 'just now';
  if (d.inMinutes < 60) return '${d.inMinutes}m ago';
  if (d.inHours < 24) return '${d.inHours}h ago';
  if (d.inDays < 7) return '${d.inDays}d ago';
  return DateFormat.MMMd().format(t);
}

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post, this.detail = false});

  final Post post;

  /// In the detail view the card isn't tappable and shows the full body.
  final bool detail;

  Future<void> _more(BuildContext context, {required bool mine}) async {
    final community = context.read<CommunityController>();
    final choice = await showCupertinoModalPopup<String>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        actions: [
          if (mine)
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(ctx, 'delete'),
              child: const Text('Delete Post'),
            )
          else ...[
            CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(ctx, 'report'),
              child: const Text('Report Post'),
            ),
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(ctx, 'block'),
              child: Text('Block ${post.author}'),
            ),
          ],
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
      ),
    );
    if (choice == null || !context.mounted) return;

    switch (choice) {
      case 'delete':
        final ok = await confirmDestructive(
          context,
          title: 'Delete Post?',
          message: "This can't be undone.",
          actionLabel: 'Delete',
        );
        if (!ok) return;
        community.delete(post);
        if (detail && context.mounted) Navigator.pop(context);
      case 'report':
        final reason = await showCupertinoModalPopup<String>(
          context: context,
          builder: (ctx) => CupertinoActionSheet(
            title: const Text('Why are you reporting this?'),
            actions: [
              for (final r in const [
                'Spam',
                'Inappropriate or abusive',
                'Misleading health claim',
                'Other',
              ])
                CupertinoActionSheetAction(
                  onPressed: () => Navigator.pop(ctx, r),
                  child: Text(r),
                ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
          ),
        );
        if (reason == null || !context.mounted) return;
        try {
          await community.report(post, reason);
          if (!context.mounted) return;
          if (detail) Navigator.pop(context);
          await showInfoDialog(
            context,
            title: 'Thanks for Reporting',
            message: "We've hidden this post and will review it.",
          );
        } catch (_) {
          if (context.mounted) {
            showInfoDialog(context, title: "Couldn't Send Report");
          }
        }
      case 'block':
        final ok = await confirmDestructive(
          context,
          title: 'Block ${post.author}?',
          message: "You won't see their posts anymore.",
          actionLabel: 'Block',
        );
        if (!ok || !context.mounted) return;
        try {
          await community.block(post);
          if (detail && context.mounted) Navigator.pop(context);
        } catch (_) {
          if (context.mounted) {
            showInfoDialog(context, title: "Couldn't Block User");
          }
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final community = context.read<CommunityController>();
    final mine = context.read<AuthController>().userId == post.userId;

    void vote(int direction) {
      HapticFeedback.selectionClick();
      community.vote(post, direction);
    }

    return IosCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 6),
      onTap: detail
          ? null
          : () => Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (_) => PostDetailScreen(postId: post.id),
              ),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.tint.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  post.author.isEmpty ? '?' : post.author[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: context.tint,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${post.author} · ${timeAgo(post.createdAt)}',
                  style: IosText.footnote.copyWith(
                    color: context.secondaryLabelColor,
                  ),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: const Size(32, 32),
                onPressed: () => _more(context, mine: mine),
                child: Icon(
                  CupertinoIcons.ellipsis,
                  size: 20,
                  color: context.secondaryLabelColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(post.title, style: IosText.headline),
          ),
          if (post.body.isNotEmpty) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                post.body,
                maxLines: detail ? null : 3,
                overflow: detail ? null : TextOverflow.ellipsis,
                style: IosText.subhead.copyWith(
                  color: context.secondaryLabelColor,
                  height: 1.35,
                ),
              ),
            ),
          ],
          if (post.productName != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Pill(
                label: post.productName!,
                icon: CupertinoIcons.tag_fill,
                color: context.tint,
              ),
            ),
          ],
          const SizedBox(height: 2),
          Row(
            children: [
              CupertinoButton(
                padding: const EdgeInsets.all(8),
                minimumSize: const Size(36, 36),
                onPressed: () => vote(1),
                child: Icon(
                  CupertinoIcons.arrow_up,
                  size: 20,
                  color: post.myVote == 1
                      ? context.tint
                      : context.secondaryLabelColor,
                ),
              ),
              Text(
                '${post.votes}',
                style: IosText.subhead.copyWith(fontWeight: FontWeight.w700),
              ),
              CupertinoButton(
                padding: const EdgeInsets.all(8),
                minimumSize: const Size(36, 36),
                onPressed: () => vote(-1),
                child: Icon(
                  CupertinoIcons.arrow_down,
                  size: 20,
                  color: post.myVote == -1
                      ? context.destructive
                      : context.secondaryLabelColor,
                ),
              ),
              const Spacer(),
              Icon(
                CupertinoIcons.chat_bubble,
                size: 17,
                color: context.secondaryLabelColor,
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Text('${post.commentCount}', style: IosText.subhead),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
