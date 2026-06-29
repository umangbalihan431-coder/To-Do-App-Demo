class GalleryImageModel {
  final String id;
  final String fileUrl;
  final String imageUrl;
  final String s3Key;
  final String fileName;
  final String contentType;
  final String mediaType;
  final String createdAt;

  const GalleryImageModel({
    required this.id,
    required this.fileUrl,
    required this.imageUrl,
    required this.s3Key,
    required this.fileName,
    required this.contentType,
    required this.mediaType,
    required this.createdAt,
  });

  factory GalleryImageModel.fromJson(Map<String, dynamic> json) {
    final url = json["file_url"]?.toString() ??
        json["image_url"]?.toString() ??
        "";

    return GalleryImageModel(
      id: json["_id"]?.toString() ?? "",
      fileUrl: url,
      imageUrl: url,
      s3Key: json["s3_key"]?.toString() ?? "",
      fileName: json["file_name"]?.toString() ?? "File",
      contentType: json["content_type"]?.toString() ?? "",
      mediaType: json["media_type"]?.toString() ?? "image",
      createdAt: json["created_at"]?.toString() ?? "",
    );
  }

  bool get isImage => mediaType == "image";
}