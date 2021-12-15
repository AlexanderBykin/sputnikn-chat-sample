import 'package:flutter/widgets.dart';

class TapResetFocusArea extends StatelessWidget {
  final Widget child;

  const TapResetFocusArea({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: child,
    );
  }
}
