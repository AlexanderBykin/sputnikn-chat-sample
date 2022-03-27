import 'dart:io';

class MediaFileModel {
  MediaFileModel({
    required this.file,
    required this.mimeType,
  });

  final File file;
  final String? mimeType;
}
