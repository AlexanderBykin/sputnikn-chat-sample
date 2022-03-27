import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ChatThreadImagePreview extends StatelessWidget {
  final Uint8List imageData;
  final _transformController = TransformationController();

  ChatThreadImagePreview({
    required this.imageData,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final viewPadding = MediaQuery.of(context).padding;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black12,
      ),
      body: InteractiveViewer.builder(
        transformationController: _transformController,
        maxScale: 3.5,
        builder: (_, quad) {
          final imageFit =
              (size.width > size.height) ? BoxFit.fitHeight : BoxFit.fitWidth;
          return SizedBox(
            width: size.width,
            height: size.height -
                kToolbarHeight -
                viewPadding.top -
                viewPadding.bottom,
            child: Image(
              image: MemoryImage(imageData),
              fit: imageFit,
            ),
          );
        },
      ),
    );
  }
}
