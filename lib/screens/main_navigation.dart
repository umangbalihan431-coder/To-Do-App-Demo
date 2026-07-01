import 'package:flutter/material.dart';

import '../app/app_colors.dart';
import 'documents_screen.dart';
import 'home_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;

  late final List<Widget> pages = [
    HomePage(),
    const DocumentsScreen(),
    const Center(child: Text("Upload")),
    const Center(child: Text("Reminders")),
    const Center(child: Text("Profile")),
  ];

  void openUpload() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DocumentsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

floatingActionButton: Container(
  height: 78,
  width: 78,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: AppColors.black,
    border: Border.all(color: Colors.white.withAlpha(90), width: 1.4),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withAlpha(90),
        blurRadius: 24,
        spreadRadius: 1,
      ),
    ],
  ),
  child: IconButton(
    onPressed: openUpload,
    icon: const Icon(
      Icons.upload_file_rounded,
      color: Colors.white,
      size: 32,
    ),
  ),
),
      bottomNavigationBar: BottomAppBar(
  height: 92,
  color: AppColors.navBg,
  shape: const CircularNotchedRectangle(),
  notchMargin: 10,
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      navItem(Icons.home_rounded, "HOME", 0),
      navItem(Icons.inventory_2_rounded, "WALLET", 1),
      const SizedBox(width: 74),
      navItem(Icons.notifications_rounded, "ALERTS", 3),
      navItem(Icons.person_rounded, "PROFILE", 4),
    ],
  ),
),
    );
  }

  Widget navItem(IconData icon, String label, int index) {
    final selected = currentIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          currentIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 58,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? AppColors.navActive : AppColors.navInactive,
              size: 27,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.navActive : AppColors.navInactive,
                fontSize: 7,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}