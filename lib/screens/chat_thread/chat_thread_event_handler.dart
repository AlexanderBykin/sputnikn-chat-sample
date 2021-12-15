import 'dart:typed_data';
import 'dart:ui';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sputnikn_chatsample/model/chat_thread_ui_message_model.dart';
import 'package:sputnikn_chatsample/screens/chat_thread/chat_thread_vm.dart';
import 'package:sputnikn_chatsample/screens/chat_thread/widget/chat_thread_image_preview.dart';
import 'package:sputnikn_chatsample/util/event_handler_base.dart';
import 'widget/chat_thread_message_action.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EventOpenChatMessageAction implements EventHandlerMessageBase {
  final ChatThreadUIEventMessage message;
  final bool isMyMessage;
  final Future<Uint8List> Function(String) onDownloadMedia;
  final Function() onForward;
  final Function() onReply;
  final Function() onCopy;
  final Function() onDelete;

  EventOpenChatMessageAction({
    required this.message,
    required this.isMyMessage,
    required this.onDownloadMedia,
    required this.onForward,
    required this.onReply,
    required this.onCopy,
    required this.onDelete,
  });
}

class EventOpenChatImagePreview implements EventHandlerMessageBase {
  final Uint8List imageData;

  EventOpenChatImagePreview(this.imageData);
}

class EventShowPhotoSourceDialog extends EventHandlerMessageBase {
  final Function() onCamera;
  final Function() onGallery;

  EventShowPhotoSourceDialog({
    required this.onCamera,
    required this.onGallery,
  });
}

class ChatThreadEventHandler extends EventHandlerBase<ChatThreadVM> {
  final BuildContext context;

  ChatThreadEventHandler(this.context);

  @override
  void processEvent(EventHandlerMessageBase event, ChatThreadVM viewModel) {
    if (event is EventOpenChatMessageAction) {
      _showChatMessageActionDialog(event);
    } else if (event is EventOpenChatImagePreview) {
      showDialog(
        context: context,
        useRootNavigator: false,
        builder: (_) {
          return ChatThreadImagePreview(
            imageData: event.imageData,
          );
        },
      );
    } else if (event is EventShowPhotoSourceDialog) {
      _showPhotoSourceDialog(event.onCamera, event.onGallery);
    } else {
      unhandledEvent(event);
    }
  }

  Future<dynamic> _showChatMessageActionDialog(
      EventOpenChatMessageAction event) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "",
      barrierColor: Colors.transparent,
      builder: (_) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 15,
            sigmaY: 15,
          ),
          child: ChatThreadMessageAction(
            message: event.message,
            isMyMessage: event.isMyMessage,
            onDownloadMedia: event.onDownloadMedia,
            onForward: () {
              event.onForward();
              AutoRouter.of(context).pop();
            },
            onReply: () {
              event.onReply();
              AutoRouter.of(context).pop();
            },
            onCopy: () {
              event.onCopy();
              AutoRouter.of(context).pop();
            },
            onDelete: () {
              event.onDelete();
              AutoRouter.of(context).pop();
            },
          ),
        );
      },
    );
  }

  Future _showPhotoSourceDialog(
    Function() onCamera,
    Function() onGallery,
  ) {
    final sheet = CupertinoActionSheet(
      message: Text(
        AppLocalizations.of(context)!.chat_thread_choose_media_title,
      ),
      cancelButton: CupertinoActionSheetAction(
        child: Text(
          AppLocalizations.of(context)!.chat_thread_choose_media_btn_cancel,
          style: const TextStyle(color: Colors.white),
        ),
        isDefaultAction: true,
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      actions: [
        CupertinoActionSheetAction(
          child: Text(
            AppLocalizations.of(context)!
                .chat_thread_choose_media_source_camera,
            style: const TextStyle(color: Colors.white),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            onCamera();
          },
        ),
        CupertinoActionSheetAction(
          child: Text(
            AppLocalizations.of(context)!
                .chat_thread_choose_media_source_gallery,
            style: const TextStyle(color: Colors.white),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            onGallery();
          },
        ),
      ],
    );

    return showCupertinoModalPopup(
      context: context,
      useRootNavigator: false,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 15,
            sigmaY: 15,
          ),
          child: sheet,
        );
      },
    );
  }
}
