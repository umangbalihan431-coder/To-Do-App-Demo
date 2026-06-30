import 'dart:convert';
import 'dart:io';

import '../models/gallery_image_model.dart';
import 'api_service.dart';

class MediaService {
  static Future<List<GalleryImageModel>> fetchImages() async {
    final response = await ApiService.get(ApiService.userImagesUrl);

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch images");
    }

    final List data = jsonDecode(response.body);

    return data
        .map<GalleryImageModel>((item) => GalleryImageModel.fromJson(item))
        .where((item) => item.isImage)
        .toList();
  }

  static Future<List<GalleryImageModel>> fetchDocuments() async {
    final response = await ApiService.get(ApiService.userMediaUrl);

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch documents");
    }

    final List data = jsonDecode(response.body);

    return data
        .map<GalleryImageModel>((item) => GalleryImageModel.fromJson(item))
        .where((item) => !item.isImage)
        .toList();
  }

  static Future<void> uploadImage(File file) async {
    final response = await ApiService.uploadImage(
      ApiService.uploadImageUrl,
      file,
      fieldName: "image",
    );

    if (response.statusCode != 201) {
      throw Exception("Failed to upload image");
    }
  }

  static Future<void> uploadDocument(File file) async {
    final response = await ApiService.uploadImage(
      ApiService.uploadMediaUrl,
      file,
      fieldName: "file",
    );

    if (response.statusCode != 201) {
      throw Exception("Failed to upload document");
    }
  }

  static Future<void> deleteMedia(String id) async {
    final response = await ApiService.delete(
      ApiService.deleteImageUrl(id),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to delete media");
    }
  }
}