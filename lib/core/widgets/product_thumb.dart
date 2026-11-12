import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

import '../theme/ios.dart';

/// Product photo that is never cropped: the whole image is fitted
/// ("contain") on a white tile, since Open Food Facts photos come in every
/// aspect ratio. Falls back to an icon when there is no usable image.
class ProductThumb extends StatelessWidget {
  const ProductThumb({super.key, this.url, this.size = 56, this.radius = 14});

  final String? url;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: size,
      height: size,
      color: context.fillColor,
      child: Icon(
        CupertinoIcons.photo,
        size: size * 0.4,
        color: context.tertiaryLabelColor,
      ),
    );
    final hasUrl = url != null && url!.isNotEmpty;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: !hasUrl
          ? placeholder
          : Container(
              width: size,
              height: size,
              color: CupertinoColors.white,
              padding: EdgeInsets.all(size * 0.06),
              child: CachedNetworkImage(
                imageUrl: url!,
                fit: BoxFit.contain,
                fadeInDuration: const Duration(milliseconds: 150),
                placeholder: (_, _) => const SizedBox.shrink(),
                errorWidget: (_, _, _) => placeholder,
              ),
            ),
    );
  }
}
