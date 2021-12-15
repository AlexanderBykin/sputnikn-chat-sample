import 'dart:io';

class MediaFileModel {
  final File file;
  final String? mimeType;

  MediaFileModel({
    required this.file,
    required this.mimeType,
  });
}
