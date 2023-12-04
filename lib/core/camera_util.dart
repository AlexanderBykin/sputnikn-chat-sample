import 'dart:async';
import 'dart:io';
import 'package:av_gallery_saver/av_gallery_saver.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sputnikn_chatsample/core/core.dart';

class ImageUtil {
  static Future<XFile?> takePictureFromCamera({
    bool preferFront = true,
  }) {
    return ImagePicker().pickImage(
      source: ImageSource.camera,
      preferredCameraDevice:
          preferFront ? CameraDevice.front : CameraDevice.rear,
    );
  }

  static Future<XFile?> takePictureFromGallery() {
    return ImagePicker().pickImage(source: ImageSource.gallery);
  }

  static Future<CroppedFile?> cropImage(File imageFile) {
    final result = Completer<CroppedFile?>();
    ImageCropper()
        .cropImage(
          sourcePath: imageFile.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.original,
          ],
          uiSettings: [
            AndroidUiSettings(
              toolbarColor: Colors.black,
              toolbarWidgetColor: Colors.white,
              activeControlsWidgetColor: Palette.color4,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
            ),
          ],
        )
        .then(result.complete)
        .catchError(result.completeError);
    return result.future;
  }

  static Future<bool?> saveImageToGallery(File file) {
    return GallerySaver.saveImage(file.path);
  }
}
