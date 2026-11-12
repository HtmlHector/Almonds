import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/ios.dart';
import '../../core/widgets/product_thumb.dart';
import '../../core/widgets/score_ring.dart';
import '../../core/widgets/state_views.dart';
import '../../data/models/history_entry.dart';
import '../../state/history_controller.dart';
import '../product/product_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.onScanTap});

  final VoidCallback onScanTap;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _favoritesOnly = false;

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryController>();
    final items = _favoritesOnly ? history.favorites : history.entries;

    Widget? state;
    if (history.loading && history.entries.isEmpty) {
      state = const Center(child: CupertinoActivityIndicator(radius: 14));
    } else if (history.error != null && history.entries.isEmpty) {
      state = StateMessage(
        icon: CupertinoIcons.wifi_slash,
        title: 'Something Went Wrong',
        message: history.error,
        actionLabel: 'Try Again',
        onAction: history.load,
      );
    } else if (items.isEmpty) {
      state = StateMessage(
        icon: _favoritesOnly
            ? CupertinoIcons.heart
            : CupertinoIcons.barcode_viewfinder,
        title: _favoritesOnly ? 'No Favourites Yet' : 'Nothing Scanned Yet',
        message: _favoritesOnly
            ? 'Tap the heart on a product to keep it here.'
            : 'Products you scan will show up here with their score.',
        actionLabel: _favoritesOnly ? null : 'Scan a Product',
        onAction: widget.onScanTap,
      );
    }

    return CupertinoPageScaffold(
      backgroundColor: context.groupedBackground,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const CupertinoSliverNavigationBar(largeTitle: Text('History')),
          CupertinoSliverRefreshControl(onRefresh: history.load),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: CupertinoSlidingSegmentedControl<bool>(
                groupValue: _favoritesOnly,
                children: const {
                  false: Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text('All'),
                  ),
                  true: Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text('Favourites'),
                  ),
                },
                onValueChanged: (v) =>
                    setState(() => _favoritesOnly = v ?? false),
              ),
            ),
          ),
          if (state != null)
            SliverFillRemaining(hasScrollBody: false, child: state)
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    color: context.cellColor,
                    child: Column(
                      children: [
                        for (var i = 0; i < items.length; i++) ...[
                          if (i > 0)
                            Container(
                              height: 0.5,
                              margin: const EdgeInsets.only(left: 92),
                              color: context.separatorColor,
                            ),
                          _HistoryRow(entry: items[i]),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry});

  final HistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final history = context.read<HistoryController>();
    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: CupertinoColors.systemRed,
        child: const Icon(CupertinoIcons.delete, color: CupertinoColors.white),
      ),
      onDismissed: (_) => history.remove(entry),
      child: Pressable(
        onTap: () => Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) =>
                ProductScreen(product: entry.product, recordScan: false),
          ),
        ),
        child: Container(
          color: context.cellColor,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ProductThumb(url: entry.product.imageUrl, size: 64),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: IosText.headline,
                    ),
                    if (entry.product.brand.isNotEmpty)
                      Text(
                        entry.product.brand,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: IosText.footnote.copyWith(
                          color: context.secondaryLabelColor,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat.MMMd().add_jm().format(entry.scannedAt),
                      style: IosText.caption.copyWith(
                        color: context.tertiaryLabelColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (entry.isFavorite)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(
                    CupertinoIcons.heart_fill,
                    size: 16,
                    color: CupertinoColors.systemRed,
                  ),
                ),
              ScoreRing(score: entry.score, size: 50, stroke: 5),
            ],
          ),
        ),
      ),
    );
  }
}
