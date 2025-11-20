import 'package:almonds/features/community/presentation/screens/community_screen.dart';
import 'package:almonds/features/home/presentation/screens/home_screen.dart';
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
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => newScreen,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.activeScreenIndex,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      onTap: changeScreen,
      selectedItemColor: Colors.black,
      unselectedItemColor: Color(0xFF4F4E5B),
      selectedFontSize: 12,
      unselectedFontSize: 12,
      selectedIconTheme: IconThemeData(size: 24),
      unselectedIconTheme: IconThemeData(size: 24),
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
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
        BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
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
