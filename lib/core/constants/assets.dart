import 'package:flutter_svg/flutter_svg.dart';

class Assets {
  Assets._();

  static String bgSigInPath = "assets/bg_signin.svg";
  static SvgPicture logo({
    double? width,
    double? height,
  }) =>
      SvgPicture.asset(
        "assets/logo.svg",
        width: width,
        height: height,
      );
}
