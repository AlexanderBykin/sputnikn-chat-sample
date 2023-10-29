import 'package:flutter/material.dart';
import 'package:sputnikn_chatsample/core/core.dart';

abstract class ChatLoaderScopeBase<T extends StatefulWidget> extends State<T> {
  void changeLoaderVisibility(bool value) {}
}

class ChatLoaderScope extends StatefulWidget {
  const ChatLoaderScope({
    required this.child,
    super.key,
  });

  final Widget child;

  static ChatLoaderScopeBase of(BuildContext context) {
    return context
        .findAncestorStateOfType<ChatLoaderScopeBase<ChatLoaderScope>>()!;
  }

  @override
  State<ChatLoaderScope> createState() {
    return _ChatLoaderScopeState();
  }
}

class _ChatLoaderScopeState extends State<ChatLoaderScope>
    implements ChatLoaderScopeBase<ChatLoaderScope> {
  final _loadingNotifier = ValueNotifier(false);

  @override
  void dispose() {
    _loadingNotifier.dispose();
    super.dispose();
  }

  @override
  void changeLoaderVisibility(bool value) {
    _loadingNotifier.value = value;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(child: widget.child),
        ValueListenableBuilder(
          valueListenable: _loadingNotifier,
          builder: (_, value, __) {
            if (!value) {
              return const SizedBox.shrink();
            }
            return Container(
              width: double.infinity,
              height: double.infinity,
              alignment: Alignment.center,
              color: Palette.color0.withOpacity(0.7),
              child: const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  color: Palette.color4,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
