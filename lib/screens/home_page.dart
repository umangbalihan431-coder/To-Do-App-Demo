import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../app/app_colors.dart';
import '../services/auth_service.dart';
import 'documents_screen.dart';
import 'gallery_screen.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String getEmail() => AuthService.getEmail() ?? "User";

  String getFirstName() {
    final email = getEmail();
    if (!email.contains("@")) return email;
    return email.split("@").first;
  }

  Future<void> resetNotificationCount() async {
    final box = Hive.box('myBox');
    await box.put("NOTIFICATION_COUNT", 0);
  }

  Future<void> logout() async {
    await AuthService.logout();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  void openInvoiceVault() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DocumentsScreen()),
    );
  }

  void openProductPhotos() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GalleryScreen()),
    );
  }

  Widget notificationBell() {
    final box = Hive.box('myBox');

    return ValueListenableBuilder(
      valueListenable: box.listenable(keys: ["NOTIFICATION_COUNT"]),
      builder: (context, Box box, _) {
        final count = box.get("NOTIFICATION_COUNT", defaultValue: 0);

        return Stack(
          children: [
            IconButton(
              onPressed: resetNotificationCount,
              icon: const Icon(Icons.notifications_none_rounded),
            ),
            if (count > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget sectionTitle(String title, {String? action}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 14),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.8,
            ),
          ),
          const Spacer(),
          if (action != null)
            Text(
              action,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }

  Widget insightCard({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        height: 116,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppColors.line),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.black, size: 24),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget featureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: 162,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.line),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.black, size: 32),
            const SizedBox(height: 22),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 17,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget quickRow(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: AppColors.cardSoft,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: AppColors.black, size: 26),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
  Widget productImageCard({
  required String imagePath,
  required String title,
  required String subtitle,
}) {
  return Container(
    width: 250,
    margin: const EdgeInsets.only(right: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(18),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: FilledButton(
                  onPressed: openInvoiceVault,
                  child: const Text("View details"),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final name = getFirstName();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 6),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 27,
                      backgroundColor: AppColors.black,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : "U",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                   const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.search_rounded, size: 31),
                    ),
                    notificationBell(),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(34),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(60),
                        blurRadius: 30,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text(
                            "FIXBRIDGE",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3,
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.verified_rounded,
                            color: AppColors.gold,
                            size: 24,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "digital ownership\nwallet",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                          letterSpacing: -1.2,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        "store invoices, track warranties and protect every product you own.",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: openInvoiceVault,
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.black,
                              ),
                              child: const Text("Upload invoice"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(18),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
  child: sectionTitle("Ownership Insights"),
),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        insightCard(
                          value: "24",
                          label: "products",
                          icon: Icons.inventory_2_rounded,
                        ),
                        const SizedBox(width: 12),
                        insightCard(
                          value: "18",
                          label: "active warranties",
                          icon: Icons.verified_user_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        insightCard(
                          value: "₹5.2L",
                          label: "protected value",
                          icon: Icons.shield_rounded,
                        ),
                        const SizedBox(width: 12),
                        insightCard(
                          value: "3",
                          label: "expiring soon",
                          icon: Icons.timer_rounded,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
  child: sectionTitle("For You", action: "view all ›"),
),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 190,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
SliverToBoxAdapter(
  child: sectionTitle("Your Products", action: "view all ›"),
),

SliverToBoxAdapter(
  child: SizedBox(
    height: 360,
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        productImageCard(
          imagePath: "assets/products/macbook.jpg",
          title: "MacBook Pro",
          subtitle: "Warranty active",
        ),
        productImageCard(
          imagePath: "assets/products/iphone.jpg",
          title: "iPhone 17",
          subtitle: "Invoice stored",
        ),
        productImageCard(
          imagePath: "assets/products/sony_camera.jpg",
          title: "Sony Camera",
          subtitle: "Service ready",
        ),
      ],
    ),
  ),
),

SliverToBoxAdapter(
  child: SizedBox(
    height: 360,
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        productImageCard(
          imagePath: "assets/products/macbook.jpg",
          title: "MacBook Pro",
          subtitle: "Warranty active",
        ),
        productImageCard(
          imagePath: "assets/products/iphone.jpg",
          title: "iPhone 17",
          subtitle: "Invoice stored",
        ),
        productImageCard(
          imagePath: "assets/products/sony_camera.jpg",
          title: "Sony Camera",
          subtitle: "Service ready",
        ),
      ],
    ),
  ),
),            SliverToBoxAdapter(
  child: sectionTitle("Explore FixBridge"),
),

            SliverToBoxAdapter(
              child: Column(
                children: [
                  quickRow(
                    Icons.history_rounded,
                    "invoice history",
                    "view every uploaded invoice",
                    openInvoiceVault,
                  ),
                  quickRow(
                    Icons.inventory_rounded,
                    "product ownership wallet",
                    "manage appliances, electronics and vehicles",
                    () {},
                  ),
                  quickRow(
                    Icons.notifications_active_rounded,
                    "warranty reminders",
                    "never miss an expiry date",
                    () {},
                  ),
                  quickRow(
                    Icons.help_outline_rounded,
                    "contact support",
                    "get help with products and claims",
                    () {},
                  ),
                  quickRow(
                    Icons.logout_rounded,
                    "logout",
                    "securely sign out from this device",
                    logout,
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 128),
            ),
          
        ),
      ),
    )
              ],
        ),
      ),
    );
    
  }
}