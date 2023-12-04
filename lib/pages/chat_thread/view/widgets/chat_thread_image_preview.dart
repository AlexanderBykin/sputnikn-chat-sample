import 'dart:typed_data';
import 'package:flutter/material.dart';

class ChatThreadImagePreview extends StatefulWidget {
  const ChatThreadImagePreview({
    required this.imageData,
    super.key,
  });

  final Uint8List imageData;

  @override
  State<ChatThreadImagePreview> createState() => _ChatThreadImagePreviewState();
}

class _ChatThreadImagePreviewState extends State<ChatThreadImagePreview> {
  final _transformController = TransformationController();

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

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
              image: MemoryImage(widget.imageData),
              fit: imageFit,
            ),
          );
        },
      ),
    );
  }
}
