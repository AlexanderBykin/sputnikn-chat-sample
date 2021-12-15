import 'dart:io';
import 'dart:typed_data';

class MediaCacheManager {
  final String path;

  MediaCacheManager._({
    required this.path,
  });

  static Future<MediaCacheManager> create({
    required String path,
  }) async {
    final directory = Directory(path);
    if ((await directory.exists()) == false) {
      await directory.create(recursive: true);
    }
    return MediaCacheManager._(path: path);
  }

  Future<Uint8List?> getMedia(String mediaId) async {
    final mediaFile = _getMediaFile(mediaId);
    if (await mediaFile.exists()) {
      return mediaFile.readAsBytes();
    } else {
      return Future.value();
    }
  }

  Future<File> saveMedia(String mediaId, List<int> bytes) {
    final mediaFile = _getMediaFile(mediaId);
    return mediaFile.writeAsBytes(bytes, flush: true);
  }

  File _getMediaFile(String mediaId) {
    return File("$path/$mediaId");
  }
}
