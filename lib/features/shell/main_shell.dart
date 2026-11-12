import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:uikit_tab_bar/uikit_tab_bar.dart';

import '../../core/theme/app_theme.dart';
import '../../state/community_controller.dart';
import '../../state/diet_controller.dart';
import '../../state/history_controller.dart';
import '../community/community_screen.dart';
import '../history/history_screen.dart';
import '../profile/profile_screen.dart';
import '../scanner/scanner_screen.dart';

const _tabIds = ['scan', 'history', 'community', 'profile'];

/// Root navigation. On iOS 26+ this is the real system tab bar (Liquid
/// Glass); on older iOS and other platforms it falls back to a standard
/// [CupertinoTabBar].
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  String _selected = _tabIds.first;

  /// Tells the scanner whether its tab is visible (camera on/off).
  final _scanActive = ValueNotifier<bool>(true);

  void _select(String id) {
    setState(() => _selected = id);
    _scanActive.value = id == 'scan';
  }

  @override
  void dispose() {
    _scanActive.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryController>().load();
      context.read<CommunityController>().load();
      context.read<DietController>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final index = _tabIds.indexOf(_selected);
    final onScan = _selected == 'scan';

    return UIKitTabScaffold(
      tabBar: UIKitTabBar(
        tabs: const [
          UIKitTab(
            id: 'scan',
            label: 'Scan',
            icon: UIKitTabIcon.symbol('barcode.viewfinder'),
            fallbackIcon: Icon(CupertinoIcons.barcode_viewfinder),
          ),
          UIKitTab(
            id: 'history',
            label: 'History',
            icon: UIKitTabIcon.symbol('clock'),
            selectedIcon: UIKitTabIcon.symbol('clock.fill'),
            fallbackIcon: Icon(CupertinoIcons.clock),
            fallbackSelectedIcon: Icon(CupertinoIcons.clock_fill),
          ),
          UIKitTab(
            id: 'community',
            label: 'Community',
            icon: UIKitTabIcon.symbol('bubble.left.and.bubble.right'),
            selectedIcon: UIKitTabIcon.symbol(
              'bubble.left.and.bubble.right.fill',
            ),
            fallbackIcon: Icon(CupertinoIcons.chat_bubble_2),
            fallbackSelectedIcon: Icon(CupertinoIcons.chat_bubble_2_fill),
          ),
          UIKitTab(
            id: 'profile',
            label: 'Profile',
            icon: UIKitTabIcon.symbol('person'),
            selectedIcon: UIKitTabIcon.symbol('person.fill'),
            fallbackIcon: Icon(CupertinoIcons.person),
            fallbackSelectedIcon: Icon(CupertinoIcons.person_fill),
          ),
        ],
        selectedId: _selected,
        onSelected: _select,
        style: UIKitTabBarStyle(
          // The camera tab is always dark, so use the dark glass and the
          // brighter brand green there to stay legible.
          tintColor: onScan
              ? AppTheme.brand.darkColor
              : AppTheme.brand.resolveFrom(context),
          brightness: onScan ? Brightness.dark : null,
        ),
      ),
      // Each tab keeps its own Navigator, so pushed screens (product,
      // post detail) keep the tab bar visible and tabs keep their state.
      body: IndexedStack(
        index: index,
        children: [
          CupertinoTabView(
            builder: (_) => ValueListenableBuilder<bool>(
              valueListenable: _scanActive,
              builder: (_, active, _) => ScannerScreen(active: active),
            ),
          ),
          CupertinoTabView(
            builder: (_) => HistoryScreen(onScanTap: () => _select('scan')),
          ),
          CupertinoTabView(builder: (_) => const CommunityScreen()),
          CupertinoTabView(builder: (_) => const ProfileScreen()),
        ],
      ),
    );
  }
}
