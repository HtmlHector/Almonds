import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../core/theme/ios.dart';
import '../../core/widgets/dialogs.dart';
import '../../data/models/post.dart';
import '../../data/repositories/community_repository.dart';
import '../../state/community_controller.dart';
import 'post_card.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key, required this.postId});

  final String postId;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _input = TextEditingController();
  List<Comment> _comments = [];
  bool _loading = true;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final list = await context.read<CommunityRepository>().comments(
        widget.postId,
      );
      if (!mounted) return;
      setState(() {
        _comments = list;
        _loading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load comments.';
      });
    }
  }

  Future<void> _send() async {
    final body = _input.text.trim();
    if (body.isEmpty || _sending) return;
    final repo = context.read<CommunityRepository>();
    final community = context.read<CommunityController>();
    setState(() => _sending = true);
    try {
      await repo.addComment(widget.postId, body);
      _input.clear();
      community.bumpComments(widget.postId, 1);
      await _load();
    } catch (_) {
      if (mounted) {
        showInfoDialog(context, title: "Couldn't Send Comment");
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = context.select<CommunityController, Post?>(
      (c) => c.posts.where((p) => p.id == widget.postId).firstOrNull,
    );

    return CupertinoPageScaffold(
      backgroundColor: context.groupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Post'),
        previousPageTitle: 'Community',
      ),
      child: SafeArea(
        child: post == null
            ? Center(
                child: Text(
                  'This post is no longer available.',
                  style: IosText.body.copyWith(
                    color: context.secondaryLabelColor,
                  ),
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      children: [
                        PostCard(post: post, detail: true),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 10),
                          child: Text(
                            'COMMENTS',
                            style: IosText.footnote.copyWith(
                              color: context.secondaryLabelColor,
                            ),
                          ),
                        ),
                        if (_loading)
                          const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(child: CupertinoActivityIndicator()),
                          )
                        else if (_error != null)
                          Text(
                            _error!,
                            style: TextStyle(color: context.destructive),
                          )
                        else if (_comments.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              'No comments yet. Be the first.',
                              style: IosText.subhead.copyWith(
                                color: context.secondaryLabelColor,
                              ),
                            ),
                          )
                        else
                          IosCard(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                for (var i = 0; i < _comments.length; i++) ...[
                                  if (i > 0)
                                    Container(
                                      height: 0.5,
                                      color: context.separatorColor,
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${_comments[i].author} · '
                                          '${timeAgo(_comments[i].createdAt)}',
                                          style: IosText.footnote.copyWith(
                                            color: context.secondaryLabelColor,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _comments[i].body,
                                          style: IosText.body,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: context.cellColor,
                      border: Border(
                        top: BorderSide(
                          color: context.separatorColor,
                          width: 0.5,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: CupertinoTextField(
                            controller: _input,
                            placeholder: 'Add a comment…',
                            maxLength: 1000,
                            textCapitalization: TextCapitalization.sentences,
                            onSubmitted: (_) => _send(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: context.fillColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        CupertinoButton(
                          padding: const EdgeInsets.all(8),
                          minimumSize: const Size(40, 40),
                          onPressed: _sending ? null : _send,
                          child: _sending
                              ? const CupertinoActivityIndicator()
                              : const Icon(
                                  CupertinoIcons.arrow_up_circle_fill,
                                  size: 32,
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
