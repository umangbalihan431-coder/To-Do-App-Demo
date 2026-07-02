import 'package:flutter/material.dart';

import '../app/app_colors.dart';
import 'documents_screen.dart';
import 'home_page.dart';
import 'upload_hub_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;

  late final AnimationController uploadController;
  late final Animation<double> uploadMove;
  late final Animation<double> uploadScale;

  late final List<Widget> pages = [
    const HomePage(),
    const DocumentsScreen(),
    const SizedBox(),
    const Center(child: Text("Warranty")),
    const Center(child: Text("Profile")),
  ];

  @override
  void initState() {
    super.initState();

    uploadController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );

    uploadMove = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: uploadController, curve: Curves.easeOutCubic),
    );

    uploadScale = Tween<double>(begin: 1, end: 1.06).animate(
      CurvedAnimation(parent: uploadController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    uploadController.dispose();
    super.dispose();
  }

  Future<void> openUpload() async {
    await uploadController.forward();

    if (!mounted) return;

    await Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 420),
        pageBuilder: (_, animation, __) => const UploadHubScreen(),
        transitionsBuilder: (_, animation, __, child) {
          final curve = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          return FadeTransition(
            opacity: curve,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.08),
                end: Offset.zero,
              ).animate(curve),
              child: child,
            ),
          );
        },
      ),
    );

    uploadController.reverse();
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
      floatingActionButton: AnimatedBuilder(
        animation: uploadController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, uploadMove.value),
            child: Transform.scale(
              scale: uploadScale.value,
              child: child,
            ),
          );
        },
        child: GestureDetector(
          onTap: openUpload,
          child: Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.black,
              border: Border.all(color: Colors.white.withAlpha(150), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(110),
                  blurRadius: 26,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.upload_file_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 88,
        color: AppColors.navBg,
        elevation: 18,
        shape: const CircularNotchedRectangle(),
        notchMargin: 7,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            navItem(Icons.home_rounded, "HOME", 0),
            navItem(Icons.receipt_long_rounded, "INVOICE", 1),
            const SizedBox(width: 76),
            navItem(Icons.verified_user_rounded, "WARRANTY", 3),
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
              size: 25,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? AppColors.navActive : AppColors.navInactive,
                fontSize: 7.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}