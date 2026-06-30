import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../app/app_colors.dart';
import '../models/gallery_image_model.dart';
import '../services/media_service.dart';
import 'full_screen_image.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final ImagePicker imagePicker = ImagePicker();

  List<GalleryImageModel> images = [];
  bool isLoading = false;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchImages();
    recoverLostCameraImage();
  }

  Future<void> fetchImages() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      final data = await MediaService.fetchImages();

      if (!mounted) return;

      setState(() {
        images = data;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage = "Could not load images";
        isLoading = false;
      });
    }
  }

  Future<void> uploadImageFile(File file) async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      await MediaService.uploadImage(file);
      await fetchImages();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage = "Could not upload image";
        isLoading = false;
      });
    }
  }

  Future<void> recoverLostCameraImage() async {
    try {
      final LostDataResponse response = await imagePicker.retrieveLostData();

      if (response.isEmpty) return;

      final XFile? file = response.file;

      if (file != null) {
        await uploadImageFile(File(file.path));
      }
    } catch (_) {}
  }

  Future<void> uploadFromCamera() async {
    if (isLoading) return;

    try {
      final XFile? pickedImage = await imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 45,
        maxWidth: 1080,
        maxHeight: 1080,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (pickedImage == null) return;

      final file = File(pickedImage.path);

      if (!await file.exists()) {
        setState(() {
          errorMessage = "Camera file not found";
        });
        return;
      }

      await Future.delayed(const Duration(milliseconds: 300));
      await uploadImageFile(file);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage = "Camera failed";
        isLoading = false;
      });
    }
  }

  Future<void> uploadFromGallery() async {
    try {
      final XFile? pickedImage = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 82,
      );

      if (pickedImage == null) return;

      await uploadImageFile(File(pickedImage.path));
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage = "Gallery upload failed";
        isLoading = false;
      });
    }
  }

  void showUploadOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 5,
                  width: 46,
                  decoration: BoxDecoration(
                    color: AppColors.cardSoft,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Upload Image",
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.cardSoft,
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: AppColors.accent,
                    ),
                  ),
                  title: const Text("Take photo"),
                  subtitle: const Text("Open camera and upload image"),
                  onTap: () {
                    Navigator.pop(context);
                    uploadFromCamera();
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.cardSoft,
                    child: Icon(
                      Icons.photo_library_rounded,
                      color: AppColors.accent,
                    ),
                  ),
                  title: const Text("Choose image"),
                  subtitle: const Text("Upload image from gallery"),
                  onTap: () {
                    Navigator.pop(context);
                    uploadFromGallery();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> deleteImage(String imageId) async {
    try {
      await MediaService.deleteMedia(imageId);
      await fetchImages();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage = "Could not delete image";
      });
    }
  }

  void confirmDelete(String imageId) {
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
              const Icon(
                Icons.delete_rounded,
                color: AppColors.danger,
                size: 42,
              ),
              const SizedBox(height: 12),
              const Text(
                "Delete image?",
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "This image will be removed from your gallery.",
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
                        deleteImage(imageId);
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
String formatDate(String value) {
  try {
    final d = DateTime.parse(value).toLocal();
    return "${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}";
  } catch (_) {
    return value;
  }
}
 Widget imageTile(GalleryImageModel image) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, animation, __) =>
              FullScreenImage(imageUrl: image.imageUrl),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    },
    onLongPress: () => confirmDelete(image.id),
    child: Hero(
      tag: image.imageUrl,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: AppColors.card,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.08 * 255).round()),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.network(
                image.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.broken_image_rounded,
                      color: AppColors.muted,
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              color: Colors.white,
              child: Text(
                formatDate(image.createdAt),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
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
        title: const Text("Gallery"),
        actions: [
          IconButton(
            onPressed: fetchImages,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showUploadOptions,
        icon: const Icon(Icons.add_rounded),
        label: const Text("Upload"),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchImages,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (errorMessage.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withAlpha((0.12 * 255).round()),
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
              if (images.isEmpty && !isLoading)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.photo_library_rounded,
                          color: AppColors.muted,
                          size: 64,
                        ),
                        SizedBox(height: 14),
                        Text(
                          "No images yet",
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Tap Upload to add images.",
                          style: TextStyle(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => imageTile(images[index]),
                      childCount: images.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
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