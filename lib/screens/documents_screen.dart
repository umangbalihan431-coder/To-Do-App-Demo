import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/app_colors.dart';
import '../models/gallery_image_model.dart';
import '../services/media_service.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  List<GalleryImageModel> documents = [];
  bool isLoading = false;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchDocuments();
  }

  Future<void> fetchDocuments() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      final data = await MediaService.fetchDocuments();

      if (!mounted) return;

      setState(() {
        documents = data;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage = "Could not load documents";
        isLoading = false;
      });
    }
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

      setState(() {
        isLoading = true;
        errorMessage = "";
      });

      await MediaService.uploadDocument(File(pickedFile.path));
      await fetchDocuments();
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
        errorMessage = "Could not open document";
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
        errorMessage = "Could not delete document";
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
              const Icon(
                Icons.delete_rounded,
                color: AppColors.danger,
                size: 42,
              ),
              const SizedBox(height: 12),
              const Text(
                "Delete document?",
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "This document will be removed.",
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.08 * 255).round()),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              documentIcon(document),
              color: AppColors.danger,
              size: 46,
            ),
            const SizedBox(height: 12),
            Text(
              document.fileName.isEmpty ? "Document" : document.fileName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Tap to open",
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text("Documents"),
        actions: [
          IconButton(
            onPressed: fetchDocuments,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: uploadDocument,
        icon: const Icon(Icons.upload_file_rounded),
        label: const Text("Upload"),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchDocuments,
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
              if (documents.isEmpty && !isLoading)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.folder_rounded,
                          color: AppColors.muted,
                          size: 64,
                        ),
                        SizedBox(height: 14),
                        Text(
                          "No documents yet",
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Tap Upload to add PDF or document.",
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
                      (context, index) => documentTile(documents[index]),
                      childCount: documents.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.92,
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