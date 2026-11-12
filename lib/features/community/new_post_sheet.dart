import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../core/theme/ios.dart';
import '../../core/widgets/dialogs.dart';
import '../../state/community_controller.dart';

/// Native page sheet for writing a post. Optionally attached to a product.
Future<void> showNewPostSheet(
  BuildContext context, {
  String? productBarcode,
  String? productName,
}) {
  return showCupertinoSheet<void>(
    context: context,
    scrollableBuilder: (_, scroll) => _NewPost(
      scroll: scroll,
      productBarcode: productBarcode,
      productName: productName,
    ),
  );
}

class _NewPost extends StatefulWidget {
  const _NewPost({
    required this.scroll,
    this.productBarcode,
    this.productName,
  });

  final ScrollController scroll;
  final String? productBarcode;
  final String? productName;

  @override
  State<_NewPost> createState() => _NewPostState();
}

class _NewPostState extends State<_NewPost> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  bool _posting = false;

  @override
  void initState() {
    super.initState();
    if (widget.productName != null) {
      _title.text = 'What do you think of ${widget.productName}?';
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  bool get _canPost => _title.text.trim().isNotEmpty && !_posting;

  Future<void> _submit() async {
    final nav = Navigator.of(context);
    final community = context.read<CommunityController>();
    setState(() => _posting = true);
    try {
      await community.create(
        title: _title.text.trim(),
        body: _body.text.trim(),
        productBarcode: widget.productBarcode,
        productName: widget.productName,
      );
      nav.pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _posting = false);
      showInfoDialog(
        context,
        title: "Couldn't Post",
        message: 'Check your connection and try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: context.groupedBackground,
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        middle: const Text('New Post'),
        trailing: _posting
            ? const CupertinoActivityIndicator()
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _canPost ? _submit : null,
                child: const Text(
                  'Post',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
      ),
      child: SafeArea(
        child: ListView(
          controller: widget.scroll,
          children: [
            if (widget.productName != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Pill(
                    label: widget.productName!,
                    icon: CupertinoIcons.tag_fill,
                    color: context.tint,
                  ),
                ),
              ),
            CupertinoListSection.insetGrouped(
              children: [
                CupertinoTextFormFieldRow(
                  controller: _title,
                  placeholder: 'Title',
                  maxLength: 120,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (_) => setState(() {}),
                ),
                CupertinoTextFormFieldRow(
                  controller: _body,
                  placeholder: 'Share details, tips or questions (optional)',
                  minLines: 5,
                  maxLines: 8,
                  maxLength: 2000,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
