import 'package:almonds/features/community/presentation/screens/community_screen.dart';
import 'package:almonds/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppNavigation extends StatefulWidget {
  const AppNavigation(this.activeScreenIndex, {super.key});

  final int activeScreenIndex;

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  void changeScreen(int newScreenIndex) {
    if (widget.activeScreenIndex == newScreenIndex) return;

    Widget newScreen;
    switch (newScreenIndex) {
      case 0:
        newScreen = HomeScreen();
      case 1:
      // newScreen = ScannerScreen();
      case 2:
      // newScreen = HistoryScreen();
      case 3:
        newScreen = CommunityScreen();
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(
        builder: (context) => newScreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabBar(
      currentIndex: widget.activeScreenIndex,
      backgroundColor: CupertinoColors.systemBackground,
      onTap: changeScreen,
      activeColor: CupertinoColors.black,
      inactiveColor: const Color(0xFF4F4E5B),
      items: [
        const BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(
            AssetImage(
              widget.activeScreenIndex == 1
                  ? 'assets/images/icons/barcodeblack.png'
                  : 'assets/images/icons/barcodegray.png',
            ),
          ),
          label: "Scan",
        ),
        const BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.clock),
          label: "History",
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(
            AssetImage(
              widget.activeScreenIndex == 3
                  ? 'assets/images/icons/communityblack.png'
                  : 'assets/images/icons/communitygray.png',
            ),
          ),
          label: "Community",
        ),
      ],
    );
  }
}
