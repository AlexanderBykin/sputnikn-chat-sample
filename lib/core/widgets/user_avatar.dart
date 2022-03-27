import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sputnikn_chatsample/core/app_config.dart';
import 'package:sputnikn_chatsample/core/themes/palette.dart';

/// Refactor to use [CircleAvatar]
class UserAvatar extends StatelessWidget {
  final String userName;
  final String? avatarPath;
  final double avatarSize;
  final Color backgroundColor;
  final double borderRadius;
  final TextStyle noAvatarTextStyle;

  const UserAvatar({
    required this.userName,
    required this.avatarPath,
    this.avatarSize = 40.0,
    this.backgroundColor = Palette.color4,
    double? borderRadius,
    this.noAvatarTextStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
    ),
    Key? key,
  })  : borderRadius = borderRadius ?? avatarSize / 2,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasAvatar = (avatarPath ?? '').isNotEmpty;
    if (hasAvatar) {
      final appConfig = context.read<AppConfig>();
      return CachedNetworkImage(
        imageUrl: '${appConfig.serverMediaUrl}/$avatarPath',
        imageBuilder: (context, imageProvider) => Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        errorWidget: (context, url, dynamic error) =>
            _noAvatarPlaceholder(context),
      );
    }

    return _noAvatarPlaceholder(context);
  }

  Widget _noAvatarPlaceholder(BuildContext context) {
    final avatarChars = userName.characters.take(2).join().toUpperCase();
    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: SizedBox(
          width: avatarSize / 2,
          height: avatarSize / 2,
          child: FittedBox(
            child: Text(
              avatarChars,
              style: noAvatarTextStyle,
            ),
          ),
        ),
      ),
    );
  }
}
