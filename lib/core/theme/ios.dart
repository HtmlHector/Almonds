import 'package:flutter/cupertino.dart';

/// Shorthand for iOS semantic colours. They resolve against the current
/// brightness, so light and dark mode work with no extra code.
extension IosColors on BuildContext {
  Color get labelColor => CupertinoColors.label.resolveFrom(this);
  Color get secondaryLabelColor =>
      CupertinoColors.secondaryLabel.resolveFrom(this);
  Color get tertiaryLabelColor =>
      CupertinoColors.tertiaryLabel.resolveFrom(this);
  Color get groupedBackground =>
      CupertinoColors.systemGroupedBackground.resolveFrom(this);
  Color get cellColor =>
      CupertinoColors.secondarySystemGroupedBackground.resolveFrom(this);
  Color get fillColor => CupertinoColors.tertiarySystemFill.resolveFrom(this);
  Color get strongFillColor => CupertinoColors.systemFill.resolveFrom(this);
  Color get separatorColor => CupertinoColors.separator.resolveFrom(this);
  Color get tint => CupertinoTheme.of(this).primaryColor;
  Color get destructive => CupertinoColors.systemRed.resolveFrom(this);
}

/// iOS text styles (system font: SF Pro).
class IosText {
  const IosText._();

  static const largeTitle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
  );
  static const title2 = TextStyle(fontSize: 22, fontWeight: FontWeight.w700);
  static const title3 = TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
  static const headline = TextStyle(fontSize: 17, fontWeight: FontWeight.w600);
  static const body = TextStyle(fontSize: 17);
  static const subhead = TextStyle(fontSize: 15);
  static const footnote = TextStyle(fontSize: 13);
  static const caption = TextStyle(fontSize: 12);
}

/// A rounded "cell" surface like the cards in iOS Settings / Health.
class IosCard extends StatelessWidget {
  const IosCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.radius = 16,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: context.cellColor,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
    return onTap == null ? card : Pressable(onTap: onTap, child: card);
  }
}

/// Dims slightly while pressed, like native tappable rows.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedOpacity(
        opacity: _down ? 0.6 : 1,
        duration: const Duration(milliseconds: 90),
        child: widget.child,
      ),
    );
  }
}

/// Thin progress bar used for the score breakdown.
class IosBar extends StatelessWidget {
  const IosBar({super.key, required this.value, required this.color});

  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 8,
        color: context.fillColor,
        alignment: Alignment.centerLeft,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value.clamp(0, 1)),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (_, v, _) => FractionallySizedBox(
            widthFactor: v,
            child: Container(color: color),
          ),
        ),
      ),
    );
  }
}

/// Small rounded label.
class Pill extends StatelessWidget {
  const Pill({super.key, required this.label, this.icon, this.color});

  final String label;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.secondaryLabelColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: c),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: IosText.footnote.copyWith(
                fontWeight: FontWeight.w600,
                color: c,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
