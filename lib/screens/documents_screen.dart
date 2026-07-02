import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'full_screen_image.dart';

import '../app/app_colors.dart';
import '../models/gallery_image_model.dart';
import '../services/media_service.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen>
    with SingleTickerProviderStateMixin {
  List<GalleryImageModel> allMedia = [];
int selectedTab = 0; // 0 = Photos, 1 = Documents

List<GalleryImageModel> get photos =>
    allMedia.where((item) => item.isImage).toList();

List<GalleryImageModel> get documents =>
    allMedia.where((item) => !item.isImage).toList();
  bool isLoading = false;
  String errorMessage = "";

  final ImagePicker picker = ImagePicker();

  late final AnimationController uploadController;
  late final Animation<double> uploadMove;
  late final Animation<double> uploadScale;

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

    fetchDocuments();
  }

  @override
  void dispose() {
    uploadController.dispose();
    super.dispose();
  }

  Future<void> fetchDocuments() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      final data = await MediaService.fetchAllMedia();

      if (!mounted) return;

      setState(() {
        allMedia = data;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage = "Could not load invoices";
        isLoading = false;
      });
    }
  }

  Future<void> uploadPickedFile(File file) async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = "";
      });

      await MediaService.uploadDocument(file);
      await fetchDocuments();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage = "Could not upload invoice";
        isLoading = false;
      });
    }
  }

  Future<void> uploadFromCamera() async {
    await uploadController.forward();

    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image == null) {
        await uploadController.reverse();
        return;
      }

      await uploadPickedFile(File(image.path));
    } finally {
      if (mounted) {
        uploadController.reverse();
      }
    }
  }

  Future<void> uploadFromGallery() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) return;

    await uploadPickedFile(File(image.path));
  }

  Future<void> uploadDocument() async {
    try {
      const documentTypes = XTypeGroup(
        label: 'Documents',
        extensions: [
          'pdf',
          'doc',
          'docx',
          'txt',
          'xls',
          'xlsx',
          'ppt',
          'pptx',
        ],
      );

      final XFile? pickedFile = await openFile(
        acceptedTypeGroups: [documentTypes],
      );

      if (pickedFile == null) return;

      await uploadPickedFile(File(pickedFile.path));
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage = "Could not upload document";
        isLoading = false;
      });
    }
  }

  Future<void> openDocument(String url) async {
    final uri = Uri.parse(url);

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && mounted) {
      setState(() {
        errorMessage = "Could not open invoice";
      });
    }
  }

  Future<void> deleteDocument(String id) async {
    try {
      await MediaService.deleteMedia(id);
      await fetchDocuments();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage = "Could not delete invoice";
      });
    }
  }

  void confirmDelete(String id) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.delete_rounded, color: AppColors.danger, size: 42),
              const SizedBox(height: 12),
              const Text(
                "Delete invoice?",
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "This invoice will be removed from your vault.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                        deleteDocument(id);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Delete"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  IconData documentIcon(GalleryImageModel doc) {
    final name = doc.fileName.toLowerCase();

    if (doc.mediaType == "pdf" || name.endsWith(".pdf")) {
      return Icons.picture_as_pdf_rounded;
    }

    if (name.endsWith(".jpg") ||
        name.endsWith(".jpeg") ||
        name.endsWith(".png") ||
        name.endsWith(".webp")) {
      return Icons.image_rounded;
    }

    if (name.endsWith(".doc") || name.endsWith(".docx")) {
      return Icons.description_rounded;
    }

    if (name.endsWith(".xls") || name.endsWith(".xlsx")) {
      return Icons.table_chart_rounded;
    }

    if (name.endsWith(".ppt") || name.endsWith(".pptx")) {
      return Icons.slideshow_rounded;
    }

    return Icons.insert_drive_file_rounded;
  }

  Widget documentTile(GalleryImageModel document) {
    return GestureDetector(
      onTap: () => openDocument(document.fileUrl),
      onLongPress: () => confirmDelete(document.id),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              documentIcon(document),
              color: AppColors.danger,
              size: 34,
            ),
            const SizedBox(height: 10),
            Text(
              document.fileName.isEmpty ? "Invoice" : document.fileName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "Tap to open",
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget photoTile(GalleryImageModel image) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FullScreenImage(
  imageUrl: image.imageUrl,
  heroTag: image.id,
),
        ),
      );
    },
    child: Hero(
      tag: image.id,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              image.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;

                return Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.image_not_supported),
              ),
            ),

            
          ],
        ),
      ),
    ),
  );
}

  Widget navAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
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

  Widget uploadCameraButton() {
    return AnimatedBuilder(
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
      ),
    );
  }

  Widget vaultTabs() {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
    child: Container(
      height: 48,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.cardSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          tabButton("Photos", 0),
          tabButton("Documents", 1),
        ],
      ),
    ),
  );
}

Widget tabButton(String title, int index) {
  final selected = selectedTab == index;

  return Expanded(
    child: GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.muted,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text("Invoice Vault"),
        actions: [
          IconButton(
            onPressed: fetchDocuments,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: uploadCameraButton(),
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
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchDocuments,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
  child: vaultTabs(),
),
              if (errorMessage.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withAlpha(30),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        errorMessage,
                        style: const TextStyle(color: AppColors.danger),
                      ),
                    ),
                  ),
                ),
              if (isLoading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
              if (documents.isEmpty && !isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.folder_rounded, color: AppColors.muted, size: 56),
                        SizedBox(height: 14),
                        Text(
                          "No invoices yet",
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Use Camera, Gallery, or Document below.",
                          style: TextStyle(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
  padding: const EdgeInsets.symmetric(horizontal: 18),
  sliver: SliverGrid(
    delegate: SliverChildBuilderDelegate(
      (context, index) {
        final items = selectedTab == 0 ? photos : documents;

        return selectedTab == 0
            ? photoTile(items[index])
            : documentTile(items[index]);
      },
      childCount:
          selectedTab == 0 ? photos.length : documents.length,
    ),
    gridDelegate:
        SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: selectedTab == 0 ? 2 : 2,
  crossAxisSpacing: 14,
  mainAxisSpacing: 14,
  childAspectRatio: selectedTab == 0 ? 0.82 : 0.92,
),
  ),
),
            ],
          ),
        ),
      ),
    );
  }
}