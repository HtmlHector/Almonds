import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../core/theme/ios.dart';
import '../../core/widgets/product_thumb.dart';
import '../../core/widgets/score_ring.dart';
import '../../core/widgets/state_views.dart';
import '../../data/services/open_food_facts_client.dart';
import '../../data/services/product_service.dart';
import '../product/product_screen.dart';

/// Search the Open Food Facts catalogue by product name.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

enum _Phase { idle, loading, results, empty, error }

class _SearchScreenState extends State<SearchScreen> {
  final _field = TextEditingController();
  Timer? _debounce;
  int _requestId = 0; // ignore responses from superseded searches

  _Phase _phase = _Phase.idle;
  List<ScoredProduct> _results = const [];
  String _errorMessage = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _field.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    _debounce?.cancel();
    if (text.trim().length < 2) {
      _requestId++;
      setState(() => _phase = _Phase.idle);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 450), () => _search(text));
  }

  Future<void> _search(String text) async {
    final service = context.read<ProductService>();
    final id = ++_requestId;
    setState(() => _phase = _Phase.loading);
    try {
      final results = await service.search(text);
      if (!mounted || id != _requestId) return;
      setState(() {
        _results = results;
        _phase = results.isEmpty ? _Phase.empty : _Phase.results;
      });
    } on LookupFailedException catch (e) {
      if (!mounted || id != _requestId) return;
      setState(() {
        _errorMessage = e.message;
        _phase = _Phase.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    switch (_phase) {
      case _Phase.idle:
        body = const StateMessage(
          icon: CupertinoIcons.search,
          title: 'Search Products',
          message:
              'Type a product name or brand, like “nutella” or “oat milk”.',
        );
      case _Phase.loading:
        body = const Center(child: CupertinoActivityIndicator(radius: 14));
      case _Phase.empty:
        body = const StateMessage(
          icon: CupertinoIcons.question_circle,
          title: 'No Results',
          message: 'Try a different spelling or a more general name.',
        );
      case _Phase.error:
        body = StateMessage(
          icon: CupertinoIcons.wifi_slash,
          title: "Couldn't Search",
          message: _errorMessage,
          actionLabel: 'Try Again',
          onAction: () => _search(_field.text),
        );
      case _Phase.results:
        body = ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.only(top: 4, bottom: 24),
          children: [
            CupertinoListSection.insetGrouped(
              children: [for (final r in _results) _ResultTile(item: r)],
            ),
          ],
        );
    }

    return CupertinoPageScaffold(
      backgroundColor: context.groupedBackground,
      navigationBar: const CupertinoNavigationBar(middle: Text('Search')),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: CupertinoSearchTextField(
                controller: _field,
                autofocus: true,
                placeholder: 'Product name or brand',
                onChanged: _onChanged,
                onSubmitted: (t) {
                  _debounce?.cancel();
                  if (t.trim().length >= 2) _search(t);
                },
              ),
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.item});

  final ScoredProduct item;

  @override
  Widget build(BuildContext context) {
    final p = item.product;
    return CupertinoListTile(
      leading: ProductThumb(url: p.imageUrl, size: 52, radius: 12),
      leadingSize: 52,
      title: Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: p.brand.isEmpty ? null : Text(p.brand),
      trailing: ScoreRing(score: item.result.score, size: 40, stroke: 4.5),
      onTap: () => Navigator.of(context).push(
        CupertinoPageRoute(builder: (_) => ProductScreen(product: p)),
      ),
    );
  }
}
