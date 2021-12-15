import 'package:flutter/material.dart';
import '../../third_party/modal_progress_hud.dart';
import 'tap_reset_focus_area.dart';

typedef ShouldPopFunc = Future<bool> Function();

class BaseScreenWithLoading extends StatefulWidget {
  final Widget child;
  final Stream<bool>? isLoadingStream;
  final Color backgroundColor;
  final bool resizeToAvoidBottomInset;
  final ShouldPopFunc? onShouldPop;
  final Function()? onBackButtonTap;
  final Widget? bottomTabBar;
  final PreferredSizeWidget? appBar;

  const BaseScreenWithLoading({
    Key? key,
    required this.child,
    this.backgroundColor = Colors.black,
    this.resizeToAvoidBottomInset = true,
    this.onShouldPop,
    this.onBackButtonTap,
    this.isLoadingStream,
    this.bottomTabBar,
    this.appBar,
  }) : super(key: key);

  @override
  _BaseScreenWithLoadingState createState() => _BaseScreenWithLoadingState();
}

class _BaseScreenWithLoadingState extends State<BaseScreenWithLoading> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar,
      backgroundColor: widget.backgroundColor,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      bottomNavigationBar: widget.bottomTabBar,
      body: WillPopScope(
        onWillPop: () {
          if (widget.onShouldPop == null) {
            widget.onBackButtonTap?.call();
            return Future.value(true);
          } else {
            widget.onBackButtonTap?.call();
            return widget.onShouldPop!();
          }
        },
        child: TapResetFocusArea(
          child: StreamBuilder<bool>(
            stream: widget.isLoadingStream,
            builder: (_, snapShot) {
              final enabled = snapShot.data == true;
              return ModalProgressHUD(
                inAsyncCall: enabled,
                color: Colors.black,
                child: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  child: widget.child,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
