import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../core/theme/ios.dart';
import '../../core/theme/score_rating.dart';
import '../../core/widgets/product_thumb.dart';
import '../../core/widgets/score_ring.dart';
import '../../data/models/history_entry.dart';
import '../../data/models/product.dart';
import '../../data/models/score_result.dart';
import '../../data/services/scoring_engine.dart';
import '../../state/history_controller.dart';

/// Lets the user choose a previously scanned product to compare against.
/// Resolves to the chosen product, or null if dismissed.
Future<Product?> pickProductToCompare(
  BuildContext context, {
  required String excludeBarcode,
}) {
  return showCupertinoSheet<Product>(
    context: context,
    scrollableBuilder: (_, scroll) =>
        _Picker(scroll: scroll, excludeBarcode: excludeBarcode),
  );
}

class _Picker extends StatelessWidget {
  const _Picker({required this.scroll, required this.excludeBarcode});

  final ScrollController scroll;
  final String excludeBarcode;

  @override
  Widget build(BuildContext context) {
    final entries = context
        .watch<HistoryController>()
        .entries
        .where((e) => e.product.barcode != excludeBarcode)
        .toList();

    return CupertinoPageScaffold(
      backgroundColor: context.groupedBackground,
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        middle: const Text('Compare With'),
      ),
      child: SafeArea(
        child: entries.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'Scan another product first, then you can compare it here.',
                    textAlign: TextAlign.center,
                    style: IosText.body.copyWith(
                      color: context.secondaryLabelColor,
                    ),
                  ),
                ),
              )
            : ListView(
                controller: scroll,
                children: [
                  CupertinoListSection.insetGrouped(
                    header: const Text('FROM YOUR HISTORY'),
                    children: [
                      for (final HistoryEntry e in entries)
                        CupertinoListTile(
                          leading: ProductThumb(
                            url: e.product.imageUrl,
                            size: 44,
                            radius: 10,
                          ),
                          leadingSize: 44,
                          title: Text(e.product.name),
                          subtitle: e.product.brand.isEmpty
                              ? null
                              : Text(e.product.brand),
                          additionalInfo: Text('${e.score}'),
                          trailing: const CupertinoListTileChevron(),
                          onTap: () => Navigator.pop(context, e.product),
                        ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key, required this.a, required this.b});

  final Product a;
  final Product b;

  @override
  Widget build(BuildContext context) {
    final engine = context.read<ScoringEngine>();
    final ra = engine.score(a);
    final rb = engine.score(b);

    final rows = <CompareRow>[
      CompareRow(
        'Additives flagged',
        ra.flagged.length.toDouble(),
        rb.flagged.length.toDouble(),
        '',
        lowerIsBetter: true,
        decimals: 0,
      ),
      ...nutrientRows(ra, rb),
    ];

    return CupertinoPageScaffold(
      backgroundColor: context.groupedBackground,
      navigationBar: const CupertinoNavigationBar(middle: Text('Compare')),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Header(
                  product: a,
                  result: ra,
                  better: ra.score > rb.score,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Header(
                  product: b,
                  result: rb,
                  better: rb.score > ra.score,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          IosCard(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0)
                    Container(height: 0.5, color: context.separatorColor),
                  _Row(row: rows[i]),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Per 100 g. Green marks the better value for each row.',
            style: IosText.caption.copyWith(color: context.tertiaryLabelColor),
          ),
        ],
      ),
    );
  }

  /// Side-by-side nutrient rows for nutrients both products report.
  static List<CompareRow> nutrientRows(ScoreResult ra, ScoreResult rb) {
    NutrientLevel? find(ScoreResult r, String label) {
      for (final l in r.levels) {
        if (l.label == label) return l;
      }
      return null;
    }

    final rows = <CompareRow>[];
    for (final label in const [
      'Calories',
      'Sugars',
      'Saturated fat',
      'Salt',
      'Fibre',
      'Protein',
    ]) {
      final x = find(ra, label);
      final y = find(rb, label);
      if (x == null || y == null) continue;
      rows.add(
        CompareRow(label, x.value, y.value, x.unit, lowerIsBetter: !x.positive),
      );
    }
    return rows;
  }
}

class CompareRow {
  const CompareRow(
    this.label,
    this.a,
    this.b,
    this.unit, {
    required this.lowerIsBetter,
    this.decimals = 1,
  });

  final String label;
  final double a;
  final double b;
  final String unit;
  final bool lowerIsBetter;
  final int decimals;

  /// -1: A better, 1: B better, 0: tie.
  int get winner {
    if ((a - b).abs() < 0.05) return 0;
    final aBetter = lowerIsBetter ? a < b : a > b;
    return aBetter ? -1 : 1;
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.row});

  final CompareRow row;

  @override
  Widget build(BuildContext context) {
    Widget cell(double v, bool wins) => Expanded(
      child: Text(
        '${v.toStringAsFixed(row.decimals)}'
        '${row.unit.isEmpty ? '' : ' ${row.unit}'}',
        textAlign: TextAlign.center,
        style: IosText.body.copyWith(
          fontWeight: wins ? FontWeight.w700 : FontWeight.w400,
          color: wins ? ScoreRating.excellent.color : null,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Text(
            row.label,
            style: IosText.footnote.copyWith(
              color: context.secondaryLabelColor,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              cell(row.a, row.winner == -1),
              cell(row.b, row.winner == 1),
            ],
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.product,
    required this.result,
    required this.better,
  });

  final Product product;
  final ScoreResult result;
  final bool better;

  @override
  Widget build(BuildContext context) {
    return IosCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          ProductThumb(url: product.imageUrl, size: 72, radius: 14),
          const SizedBox(height: 10),
          Text(
            product.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: IosText.subhead.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ScoreRing(score: result.score, size: 84, stroke: 8, showLabel: true),
          if (better) ...[
            const SizedBox(height: 10),
            Pill(
              label: 'Better choice',
              icon: CupertinoIcons.checkmark_seal_fill,
              color: ScoreRating.excellent.color,
            ),
          ],
        ],
      ),
    );
  }
}
