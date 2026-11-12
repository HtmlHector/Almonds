import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../core/theme/ios.dart';
import '../../core/theme/score_rating.dart';
import '../../core/widgets/product_thumb.dart';
import '../../core/widgets/score_ring.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/additive.dart';
import '../../data/models/diet.dart';
import '../../data/models/product.dart';
import '../../data/models/score_result.dart';
import '../../data/services/product_service.dart';
import '../../data/services/scoring_engine.dart';
import '../../core/widgets/dialogs.dart';
import '../../state/auth_controller.dart';
import '../../state/diet_controller.dart';
import '../../state/history_controller.dart';
import '../community/new_post_sheet.dart';
import '../compare/compare_screen.dart';
import 'share_card.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({
    super.key,
    required this.product,
    this.recordScan = true,
  });

  final Product product;

  /// False when opened from history (it's already recorded).
  final bool recordScan;

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late final ScoreResult _result;
  final _shareKey = GlobalKey();

  /// null = not loaded / not applicable; empty = nothing better found.
  List<ScoredProduct>? _alternatives;
  bool _loadingAlternatives = false;

  @override
  void initState() {
    super.initState();
    _result = context.read<ScoringEngine>().score(widget.product);
    if (_result.score < 75) _loadAlternatives();
    if (widget.recordScan) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (context.read<AuthController>().signedIn) {
          context.read<HistoryController>().record(
            widget.product,
            _result.score,
          );
        }
      });
    }
  }

  Future<void> _loadAlternatives() async {
    final service = context.read<ProductService>();
    setState(() => _loadingAlternatives = true);
    final found = await service.alternatives(widget.product, _result.score);
    if (!mounted) return;
    setState(() {
      _alternatives = found;
      _loadingAlternatives = false;
    });
  }

  Future<void> _menu() async {
    final choice = await showCupertinoModalPopup<String>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(ctx, 'compare'),
            child: const Text('Compare With…'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(ctx, 'share'),
            child: const Text('Share Score Card'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(ctx, 'discuss'),
            child: const Text('Discuss in Community'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
      ),
    );
    if (!mounted || choice == null) return;
    switch (choice) {
      case 'compare':
        await _compare();
      case 'share':
        await _share();
      case 'discuss':
        await showNewPostSheet(
          context,
          productBarcode: widget.product.barcode,
          productName: widget.product.name,
        );
    }
  }

  Future<void> _compare() async {
    final navigator = Navigator.of(context);
    final other = await pickProductToCompare(
      context,
      excludeBarcode: widget.product.barcode,
    );
    if (other == null || !mounted) return;
    await navigator.push(
      CupertinoPageRoute(
        builder: (_) => CompareScreen(a: widget.product, b: other),
      ),
    );
  }

  Future<void> _share() async {
    final size = MediaQuery.sizeOf(context);
    try {
      await shareBoundaryAsImage(
        _shareKey,
        fileName: widget.product.name,
        origin: Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: 1,
          height: 1,
        ),
      );
    } catch (_) {
      if (mounted) {
        showInfoDialog(
          context,
          title: "Couldn't Share",
          message: 'Please try again in a moment.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final result = _result;
    final history = context.watch<HistoryController>();
    final entry = history.byBarcode(product.barcode);

    return CupertinoPageScaffold(
      backgroundColor: context.groupedBackground,
      navigationBar: CupertinoNavigationBar(
        previousPageTitle: 'Back',
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (entry != null)
              CupertinoButton(
                padding: const EdgeInsets.all(6),
                minimumSize: const Size(32, 32),
                onPressed: () => history.toggleFavorite(entry),
                child: Icon(
                  entry.isFavorite
                      ? CupertinoIcons.heart_fill
                      : CupertinoIcons.heart,
                  color: entry.isFavorite
                      ? CupertinoColors.systemRed
                      : context.tint,
                ),
              ),
            CupertinoButton(
              padding: const EdgeInsets.all(6),
              minimumSize: const Size(32, 32),
              onPressed: _menu,
              child: const Icon(CupertinoIcons.ellipsis_circle),
            ),
          ],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 40),
              children: [
                _Header(product: product),
                _DietBanner(product: product),
                const SizedBox(height: 16),
                _ScoreCard(result: result),
                if (product.novaGroup != null ||
                    product.nutriScoreGrade != null)
                  _Badges(product: product),
                if (_loadingAlternatives ||
                    (_alternatives?.isNotEmpty ?? false)) ...[
                  const SectionHeader('Healthier Alternatives'),
                  _AlternativesSection(
                    loading: _loadingAlternatives,
                    items: _alternatives ?? const [],
                    currentScore: result.score,
                  ),
                ],
                const SectionHeader('Additives & Concerns'),
                _AdditiveSection(result: result),
                const SectionHeader('Nutrition per 100 g'),
                _NutritionSection(result: result),
                if (product.allergens.isNotEmpty) ...[
                  const SectionHeader('Allergens'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final a in product.allergens)
                          Pill(
                            label: _capitalize(a),
                            icon: CupertinoIcons.exclamationmark_triangle_fill,
                            color: CupertinoColors.systemOrange.resolveFrom(
                              context,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                const SectionHeader('Ingredients'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    product.hasIngredients
                        ? product.ingredientsText
                        : 'No ingredients list is available for this product yet.',
                    style: IosText.subhead.copyWith(
                      height: 1.4,
                      color: context.secondaryLabelColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
                  child: Text(
                    'Product data from Open Food Facts (ODbL), which is community-'
                    'maintained and may be incomplete. Scores are informational and '
                    'not medical advice.',
                    style: IosText.caption.copyWith(
                      color: context.tertiaryLabelColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Off-screen card that gets rendered to an image for sharing.
          Positioned(
            left: -2000,
            top: 0,
            child: RepaintBoundary(
              key: _shareKey,
              child: ScoreShareCard(product: product, result: result),
            ),
          ),
        ],
      ),
    );
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _Header extends StatelessWidget {
  const _Header({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          ProductThumb(url: product.imageUrl, size: 96, radius: 18),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: IosText.title2.copyWith(height: 1.15),
                ),
                if (product.brand.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      product.brand,
                      style: IosText.subhead.copyWith(
                        color: context.secondaryLabelColor,
                      ),
                    ),
                  ),
                if (product.quantity.isNotEmpty)
                  Text(
                    product.quantity,
                    style: IosText.footnote.copyWith(
                      color: context.tertiaryLabelColor,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.result});

  final ScoreResult result;

  @override
  Widget build(BuildContext context) {
    final rating = result.rating;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: IosCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                ScoreRing(
                  score: result.score,
                  size: 124,
                  stroke: 11,
                  showLabel: true,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [
                      _Breakdown(
                        label: 'Nutrition',
                        points: result.nutritionPoints,
                        max: 60,
                        color: rating.color,
                      ),
                      const SizedBox(height: 12),
                      _Breakdown(
                        label: 'Additives',
                        points: result.additivePoints,
                        max: 30,
                        color: rating.color,
                      ),
                      const SizedBox(height: 12),
                      _Breakdown(
                        label: 'Organic',
                        points: result.organicPoints,
                        max: 10,
                        color: rating.color,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (result.cappedByAdditive || result.partialData) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.fillColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      CupertinoIcons.info_circle_fill,
                      size: 18,
                      color: context.secondaryLabelColor,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        result.cappedByAdditive
                            ? 'Score limited to ${ScoringEngine.highRiskCap} because '
                                  'this product contains a high-risk additive.'
                            : 'Nutrition facts are missing, so this score is based '
                                  'on additives and labels only.',
                        style: IosText.footnote,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Breakdown extends StatelessWidget {
  const _Breakdown({
    required this.label,
    required this.points,
    required this.max,
    required this.color,
  });

  final String label;
  final int? points;
  final int max;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: IosText.footnote.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              points == null ? 'n/a' : '$points/$max',
              style: IosText.footnote.copyWith(
                color: context.secondaryLabelColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        IosBar(value: points == null ? 0 : points! / max, color: color),
      ],
    );
  }
}

class _Badges extends StatelessWidget {
  const _Badges({required this.product});

  final Product product;

  static const _novaText = {
    1: 'Unprocessed or minimally processed',
    2: 'Processed culinary ingredient',
    3: 'Processed food',
    4: 'Ultra-processed food',
  };

  @override
  Widget build(BuildContext context) {
    final nova = product.novaGroup;
    final grade = product.nutriScoreGrade;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (grade != null)
            Expanded(
              child: _Badge(
                title: 'Nutri-Score',
                value: grade.toUpperCase(),
                color: const {
                  'a': Color(0xFF30B35F),
                  'b': Color(0xFF86B817),
                  'c': Color(0xFFF2C200),
                  'd': Color(0xFFFF9F0A),
                  'e': Color(0xFFFF453A),
                }[grade]!,
              ),
            ),
          if (grade != null && nova != null) const SizedBox(width: 12),
          if (nova != null)
            Expanded(
              child: _Badge(
                title: _novaText[nova] ?? 'NOVA group',
                value: '$nova',
                color:
                    const {
                      1: Color(0xFF30B35F),
                      2: Color(0xFF86B817),
                      3: Color(0xFFFF9F0A),
                      4: Color(0xFFFF453A),
                    }[nova] ??
                    CupertinoColors.systemGrey,
              ),
            ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.title, required this.value, required this.color});

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IosCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Text(
              value,
              style: const TextStyle(
                color: CupertinoColors.white,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: IosText.footnote.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

Color _severityColor(Severity s) => switch (s) {
  Severity.low => const Color(0xFFFF9F0A),
  Severity.moderate => const Color(0xFFFF7A00),
  Severity.high => const Color(0xFFFF453A),
};

class _AdditiveSection extends StatelessWidget {
  const _AdditiveSection({required this.result});

  final ScoreResult result;

  @override
  Widget build(BuildContext context) {
    if (result.flagged.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: IosCard(
          child: Row(
            children: [
              Icon(
                CupertinoIcons.checkmark_seal_fill,
                color: ScoreRating.excellent.color,
                size: 30,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'No concerning additives found',
                      style: IosText.headline,
                    ),
                    Text(
                      'Based on the listed ingredients.',
                      style: IosText.subhead.copyWith(
                        color: context.secondaryLabelColor,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          for (final a in result.flagged)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _AdditiveTile(additive: a),
            ),
        ],
      ),
    );
  }
}

class _AdditiveTile extends StatefulWidget {
  const _AdditiveTile({required this.additive});

  final Additive additive;

  @override
  State<_AdditiveTile> createState() => _AdditiveTileState();
}

class _AdditiveTileState extends State<_AdditiveTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.additive;
    final color = _severityColor(a.severity);
    return IosCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Pressable(
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.exclamationmark_triangle_fill,
                    color: color,
                    size: 24,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.name, style: IosText.headline),
                        Text(
                          '${a.category} · ${a.severity.label}',
                          style: IosText.footnote.copyWith(color: color),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _open ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      CupertinoIcons.chevron_right,
                      size: 16,
                      color: context.tertiaryLabelColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: _open
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        a.description,
                        style: IosText.subhead.copyWith(
                          height: 1.4,
                          color: context.secondaryLabelColor,
                        ),
                      ),
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _NutritionSection extends StatelessWidget {
  const _NutritionSection({required this.result});

  final ScoreResult result;

  static Color _color(LevelQuality q) => switch (q) {
    LevelQuality.good => ScoreRating.excellent.color,
    LevelQuality.moderate => ScoreRating.mediocre.color,
    LevelQuality.bad => ScoreRating.poor.color,
  };

  static String _word(NutrientLevel l) {
    if (l.positive) {
      return l.quality == LevelQuality.good ? 'Good source' : 'Some';
    }
    return switch (l.quality) {
      LevelQuality.good => 'Low',
      LevelQuality.moderate => 'Moderate',
      LevelQuality.bad => 'High',
    };
  }

  static String _fmt(double v) =>
      v >= 100 ? v.round().toString() : v.toStringAsFixed(v >= 10 ? 0 : 1);

  @override
  Widget build(BuildContext context) {
    if (result.levels.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          'No nutrition facts are available for this product yet.',
          style: IosText.subhead.copyWith(color: context.secondaryLabelColor),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: IosCard(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            for (var i = 0; i < result.levels.length; i++) ...[
              if (i > 0) Container(height: 0.5, color: context.separatorColor),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 13),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _color(result.levels[i].quality),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(result.levels[i].label, style: IosText.body),
                    ),
                    Text(
                      '${_fmt(result.levels[i].value)} ${result.levels[i].unit}',
                      style: IosText.body.copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      width: 84,
                      child: Text(
                        _word(result.levels[i]),
                        textAlign: TextAlign.end,
                        style: IosText.subhead.copyWith(
                          color: _color(result.levels[i].quality),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DietBanner extends StatelessWidget {
  const _DietBanner({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<DietController>().prefs;
    if (prefs.isEmpty) return const SizedBox.shrink();

    final check = DietCheck.of(product, prefs);
    final Color color;
    final IconData icon;
    final String title;
    final List<String> lines;

    if (check.hasConflict) {
      color = ScoreRating.poor.color;
      icon = CupertinoIcons.xmark_octagon_fill;
      title = 'Not a match for you';
      lines = [for (final f in check.conflicts) f.message];
    } else if (check.unknowns.isNotEmpty) {
      color = ScoreRating.mediocre.color;
      icon = CupertinoIcons.question_circle_fill;
      title = 'No conflicts found';
      lines = [for (final f in check.unknowns) f.message];
    } else {
      color = ScoreRating.excellent.color;
      icon = CupertinoIcons.checkmark_circle_fill;
      title = 'Fits your preferences';
      lines = const [];
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: IosText.headline.copyWith(color: color)),
                  for (final l in lines)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(l, style: IosText.subhead),
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

class _AlternativesSection extends StatelessWidget {
  const _AlternativesSection({
    required this.loading,
    required this.items,
    required this.currentScore,
  });

  final bool loading;
  final List<ScoredProduct> items;
  final int currentScore;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SizedBox(
        height: 120,
        child: Center(child: CupertinoActivityIndicator()),
      );
    }
    return SizedBox(
      height: 196,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final item = items[i];
          return SizedBox(
            width: 150,
            child: IosCard(
              padding: const EdgeInsets.all(12),
              onTap: () => Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (_) =>
                      ProductScreen(product: item.product, recordScan: false),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ProductThumb(
                        url: item.product.imageUrl,
                        size: 56,
                        radius: 12,
                      ),
                      const Spacer(),
                      ScoreRing(score: item.result.score, size: 44, stroke: 5),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: IosText.subhead.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '+${item.result.score - currentScore} points',
                    style: IosText.footnote.copyWith(
                      color: ScoreRating.excellent.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
