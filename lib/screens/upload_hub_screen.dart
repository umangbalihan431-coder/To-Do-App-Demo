import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../app/app_colors.dart';
import '../services/media_service.dart';

class UploadHubScreen extends StatefulWidget {
  const UploadHubScreen({super.key});

  @override
  State<UploadHubScreen> createState() => _UploadHubScreenState();
}

class _UploadHubScreenState extends State<UploadHubScreen>
    with SingleTickerProviderStateMixin {
  final ImagePicker picker = ImagePicker();

  late final AnimationController lineController;

  @override
  void initState() {
    super.initState();
    lineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    lineController.dispose();
    super.dispose();
  }

  Future<void> uploadFromCamera() async {
    final image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image != null) {
      await MediaService.uploadDocument(File(image.path));
    }
  }

  Future<void> uploadFromGallery() async {
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image != null) {
      await MediaService.uploadDocument(File(image.path));
    }
  }

  Future<void> uploadDocument() async {
    const documentTypes = XTypeGroup(
      label: 'Documents',
      extensions: ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx', 'ppt', 'pptx'],
    );

    final file = await openFile(acceptedTypeGroups: [documentTypes]);

    if (file != null) {
      await MediaService.uploadDocument(File(file.path));
    }
  }

  Widget animatedInvoiceIcon() {
    return SizedBox(
      height: 82,
      width: 82,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(
            Icons.receipt_long_rounded,
            color: Colors.black26,
            size: 58,
          ),
          AnimatedBuilder(
            animation: lineController,
            builder: (context, child) {
              final y = -28 + (lineController.value * 56);

              return Transform.translate(
                offset: Offset(0, y),
                child: Container(
                  height: 3,
                  width: 50,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget instructionRow({
    required String number,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget exampleProductCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withAlpha(18)),
      ),
      child: const Row(
        children: [
          Icon(Icons.headphones_rounded, color: Colors.black, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Example wireless headphones",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  "2-year warranty · tap to view tracking",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: Colors.black45),
        ],
      ),
    );
  }

  Widget navAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 86,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.navActive, size: 25),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.navActive,
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget cameraButton() {
    return GestureDetector(
      onTap: uploadFromCamera,
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
          Icons.photo_camera_rounded,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 125),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Warranty Wallet",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "0 protected products",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Container(height: 1, color: Colors.grey),
              const SizedBox(height: 26),

              Center(child: animatedInvoiceIcon()),

              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "No invoices yet",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  "Scan a receipt or invoice below. We'll start tracking its warranty automatically.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              instructionRow(
                number: "1",
                title: "Scan, photograph, or upload",
                subtitle:
                    "Use the buttons below to capture an invoice or receipt.",
              ),
              instructionRow(
                number: "2",
                title: "Set the warranty and track it",
                subtitle:
                    "Tap any product to see its coverage status and history.",
              ),

              const SizedBox(height: 4),
              exampleProductCard(),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: cameraButton(),
      bottomNavigationBar: BottomAppBar(
        height: 88,
        color: AppColors.navBg,
        elevation: 18,
        shape: const CircularNotchedRectangle(),
        notchMargin: 7,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            navAction(Icons.photo_library_rounded, "GALLERY", uploadFromGallery),
            const SizedBox(width: 76),
            navAction(Icons.picture_as_pdf_rounded, "DOCUMENT", uploadDocument),
          ],
        ),
      ),
    );
  }
}