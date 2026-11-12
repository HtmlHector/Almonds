import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/dialogs.dart';
import '../../data/services/open_food_facts_client.dart';
import '../../data/services/product_service.dart';
import '../search/search_screen.dart';
import '../product/product_screen.dart';
import 'manual_entry_sheet.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key, required this.active});

  /// Camera only runs while this tab is visible.
  final bool active;

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final _controller = MobileScannerController(
    autoStart: false,
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
    ],
  );

  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (widget.active) _start();
  }

  @override
  void didUpdateWidget(ScannerScreen old) {
    super.didUpdateWidget(old);
    if (widget.active != old.active) {
      widget.active ? _start() : _stop();
    }
  }

  Future<void> _start() async {
    try {
      await _controller.start();
    } catch (_) {
      /* surfaced through errorBuilder */
    }
  }

  Future<void> _stop() async {
    try {
      await _controller.stop();
    } catch (_) {}
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _lookup(String barcode) async {
    if (_busy) return;
    final navigator = Navigator.of(context);
    final service = context.read<ProductService>();
    setState(() => _busy = true);
    try {
      await Haptics.vibrate(HapticsType.success);
    } catch (_) {}

    try {
      final product = await service.lookup(barcode);
      if (!mounted) return;
      await navigator.push(
        CupertinoPageRoute(builder: (_) => ProductScreen(product: product)),
      );
    } on ProductNotFoundException {
      if (!mounted) return;
      await showInfoDialog(
        context,
        title: 'Product Not Found',
        message: "We couldn't find that barcode in Open Food Facts yet.",
      );
    } on LookupFailedException catch (e) {
      if (!mounted) return;
      await showInfoDialog(
        context,
        title: "Couldn't Look Up Product",
        message: e.message,
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
              _lookup(barcode);
            },
            child: const Text('Try Again'),
          ),
        ],
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _search() {
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (_) => const SearchScreen()),
    );
  }

  Future<void> _manual() async {
    final code = await showManualEntrySheet(context);
    if (code != null) _lookup(code);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // The camera view is always dark, so use light status-bar content.
      value: SystemUiOverlayStyle.light,
      child: CupertinoPageScaffold(
        backgroundColor: CupertinoColors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(
              controller: _controller,
              onDetect: (capture) {
                final code = capture.barcodes
                    .map((b) => b.rawValue)
                    .whereType<String>()
                    .firstOrNull;
                if (code != null) _lookup(code);
              },
              errorBuilder: (context, error) => const _CameraUnavailable(),
            ),
            // Only draw the viewfinder when the camera is actually running.
            ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, state, _) => state.error != null
                  ? const SizedBox.shrink()
                  : const IgnorePointer(child: _ViewfinderOverlay()),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Scan',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      ValueListenableBuilder(
                        valueListenable: _controller,
                        builder: (context, state, _) {
                          if (state.torchState == TorchState.unavailable) {
                            return const SizedBox.shrink();
                          }
                          final on = state.torchState == TorchState.on;
                          return CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: _controller.toggleTorch,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: on
                                    ? CupertinoColors.systemYellow
                                    : CupertinoColors.black.withValues(
                                        alpha: 0.4,
                                      ),
                              ),
                              child: Icon(
                                on
                                    ? CupertinoIcons.bolt_fill
                                    : CupertinoIcons.bolt_slash_fill,
                                size: 20,
                                color: on
                                    ? CupertinoColors.black
                                    : CupertinoColors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: _GlassButton(
                        icon: CupertinoIcons.search,
                        label: 'Search',
                        onPressed: _busy ? null : _search,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: _GlassButton(
                        icon: CupertinoIcons.keyboard,
                        label: 'Enter Barcode',
                        onPressed: _busy ? null : _manual,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_busy)
              Container(
                color: CupertinoColors.black.withValues(alpha: 0.5),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CupertinoActivityIndicator(
                        radius: 16,
                        color: CupertinoColors.white,
                      ),
                      SizedBox(height: 14),
                      Text(
                        'Looking up product…',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CameraUnavailable extends StatelessWidget {
  const _CameraUnavailable();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF111413),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CupertinoIcons.camera_fill,
                size: 52,
                color: Color(0x80FFFFFF),
              ),
              const SizedBox(height: 16),
              const Text(
                'Camera Not Available',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Allow camera access in Settings, or enter a barcode by hand below.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewfinderOverlay extends StatelessWidget {
  const _ViewfinderOverlay();

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _ViewfinderPainter(), size: Size.infinite);
}

class _ViewfinderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final frame = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.44),
      width: size.width * 0.78,
      height: size.width * 0.5,
    );
    final rrect = RRect.fromRectAndRadius(frame, const Radius.circular(24));

    final dim = Path()
      ..addRect(Offset.zero & size)
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(
      dim,
      Paint()..color = CupertinoColors.black.withValues(alpha: 0.45),
    );

    final corner = Paint()
      ..color = CupertinoColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    const len = 34.0;
    void bracket(Offset c, double dx, double dy) {
      canvas.drawLine(c, c + Offset(dx * len, 0), corner);
      canvas.drawLine(c, c + Offset(0, dy * len), corner);
    }

    bracket(frame.topLeft, 1, 1);
    bracket(frame.topRight, -1, 1);
    bracket(frame.bottomLeft, 1, -1);
    bracket(frame.bottomRight, -1, -1);

    final tp = TextPainter(
      text: const TextSpan(
        text: 'Point at the barcode on the package',
        style: TextStyle(color: CupertinoColors.white, fontSize: 15),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((size.width - tp.width) / 2, frame.bottom + 20));
  }

  @override
  bool shouldRepaint(_ViewfinderPainter old) => false;
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      color: CupertinoColors.white.withValues(alpha: 0.22),
      borderRadius: BorderRadius.circular(14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: CupertinoColors.white),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: CupertinoColors.white),
            ),
          ),
        ],
      ),
    );
  }
}
