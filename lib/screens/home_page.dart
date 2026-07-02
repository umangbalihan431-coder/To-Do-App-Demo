import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'upload_hub_screen.dart';
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
    MaterialPageRoute(builder: (_) => const UploadHubScreen()),
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
              icon: const Icon(Icons.notifications_none_rounded, size: 20),
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
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.4,
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
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.black, size: 16),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              "$value $label",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
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
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 162,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
        child: Row(
          children: [
            Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                color: AppColors.cardSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.black, size: 21),
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
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 9,
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
    width: 190,
    margin: const EdgeInsets.only(right: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.line, width: 1),
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
          borderRadius: BorderRadius.zero,
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
                  fontSize: 16,
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
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
  height: 34,
  child: FilledButton(
    style: FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      textStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
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
    final width = MediaQuery.of(context).size.width;
    final horizontalPadding = width < 380 ? 18.0 : 24.0;

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
                      radius: 17,
                      backgroundColor: AppColors.black,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : "U",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                   const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.search_rounded, size: 20),
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
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(8),
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
                      const SizedBox(height: 12),
                      const Text(
                        "Digital Ownership Wallet",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                          letterSpacing: -1.2,
                        ),
                      ),
                      const SizedBox(height: 18),
                      
                     SizedBox(
  height: 38,
  width: double.infinity,
  child: FilledButton(
    onPressed: openInvoiceVault,
    style: FilledButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.black,
      padding: EdgeInsets.zero,
    ),
    child: const Text(
      "Upload invoice",
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
      ),
    ),
  ),
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
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
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
  child: sectionTitle("Your Products", action: "view all ›"),
),

SliverToBoxAdapter(
  child: SizedBox(
    height: 285,
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
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
                
                ],
              ),
            ),

                       const SliverToBoxAdapter(
              child: SizedBox(height: 128),
            ),
          ],
        ),
      ),
    );
  }
}