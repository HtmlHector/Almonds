import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/widgets/product_thumb.dart';
import '../../core/widgets/score_ring.dart';
import '../../data/models/product.dart';
import '../../data/models/score_result.dart';

/// Fixed-size, theme-independent card that gets rendered to an image for
/// sharing. Colours are hard-coded so the picture looks the same in light
/// and dark mode.
class ScoreShareCard extends StatelessWidget {
  const ScoreShareCard({
    super.key,
    required this.product,
    required this.result,
  });

  final Product product;
  final ScoreResult result;

  static const _ink = Color(0xFF111111);
  static const _muted = Color(0xFF6B6B6B);

  @override
  Widget build(BuildContext context) {
    final flagged = result.flagged.length;
    return Container(
      width: 360,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Color(0xFFFFFFFF)),
      child: DefaultTextStyle(
        style: const TextStyle(
          color: _ink,
          fontSize: 15,
          decoration: TextDecoration.none,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ProductThumb(url: product.imageUrl, size: 84, radius: 16),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                      ),
                      if (product.brand.isNotEmpty)
                        Text(
                          product.brand,
                          style: const TextStyle(color: _muted),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: ScoreRing(
                score: result.score,
                size: 150,
                stroke: 14,
                showLabel: true,
              ),
            ),
            const SizedBox(height: 22),
            _row(
              'Nutrition',
              result.nutritionPoints == null
                  ? 'n/a'
                  : '${result.nutritionPoints}/60',
            ),
            _row('Additives', '${result.additivePoints}/30'),
            _row('Organic', '${result.organicPoints}/10'),
            const SizedBox(height: 10),
            Text(
              flagged == 0
                  ? 'No concerning additives found'
                  : '$flagged concerning additive${flagged == 1 ? '' : 's'} found',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 18),
            const Text(
              'Scanned with Almonds',
              style: TextStyle(color: _muted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: _muted)),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

/// Renders the [RepaintBoundary] behind [boundaryKey] to a PNG and opens the
/// system share sheet. [origin] anchors the popover on iPad.
Future<void> shareBoundaryAsImage(
  GlobalKey boundaryKey, {
  required String fileName,
  Rect? origin,
}) async {
  final boundary =
      boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) throw StateError('Share card is not ready yet.');

  final image = await boundary.toImage(pixelRatio: 3);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  if (bytes == null) throw StateError('Could not render the share image.');

  final dir = await getTemporaryDirectory();
  final safe = fileName.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_');
  final file = File('${dir.path}/almonds_$safe.png');
  await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);

  await SharePlus.instance.share(
    ShareParams(files: [XFile(file.path)], sharePositionOrigin: origin),
  );
}
