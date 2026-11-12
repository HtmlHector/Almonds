import 'package:flutter/cupertino.dart';

import '../../core/theme/ios.dart';

class _Page {
  const _Page(this.icon, this.title, this.body);

  final IconData icon;
  final String title;
  final String body;
}

const _pages = [
  _Page(
    CupertinoIcons.barcode_viewfinder,
    'Scan Any Food',
    'Point your camera at a barcode and see what is really inside, in '
        'seconds.',
  ),
  _Page(
    CupertinoIcons.exclamationmark_shield,
    'Know What Matters',
    'Get a clear 0–100 score, plus the additives worth avoiding and exactly '
        'why they are flagged.',
  ),
  _Page(
    CupertinoIcons.camera,
    'Camera Access',
    'Almonds uses your camera only to read barcodes. Nothing is recorded or '
        'uploaded. iOS will ask for permission the first time you scan.',
  ),
];

/// Shown once on first launch.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index == _pages.length - 1) {
      widget.onDone();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final last = _index == _pages.length - 1;
    return CupertinoPageScaffold(
      backgroundColor: context.groupedBackground,
      child: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: CupertinoButton(
                onPressed: widget.onDone,
                child: Text(last ? '' : 'Skip'),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _index = i),
                children: [
                  for (final p in _pages)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: context.tint.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(p.icon, size: 56, color: context.tint),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            p.title,
                            textAlign: TextAlign.center,
                            style: IosText.largeTitle.copyWith(fontSize: 30),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            p.body,
                            textAlign: TextAlign.center,
                            style: IosText.body.copyWith(
                              color: context.secondaryLabelColor,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _pages.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _index ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _index
                          ? context.tint
                          : context.strongFillColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  onPressed: _next,
                  child: Text(last ? 'Get Started' : 'Continue'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
