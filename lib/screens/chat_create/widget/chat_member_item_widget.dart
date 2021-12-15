import 'package:cached_network_image/cached_network_image.dart';
import 'package:sputnikn_chatsample/di/app_config.dart';
import 'package:sputnikn_chatsample/di/di.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sputnikn_chatsample/screens/widgets/user_avatar.dart';
import '../selectable_member_vm.dart';

class ChatMemberItemWidget extends StatelessWidget {
  final avatarSize = 48.0;

  const ChatMemberItemWidget({
    Key? key,
  }) : super(key: key);

  static Widget builder(SelectableMemberVM viewModel) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      builder: (_, __) => const ChatMemberItemWidget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: UserAvatar(
        userName: context.read<SelectableMemberVM>().member.fullName,
        avatarPath: context.read<SelectableMemberVM>().member.avatar,
      ),
      title: Text(
        context.read<SelectableMemberVM>().member.fullName,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: Selector<SelectableMemberVM, bool>(
        selector: (_, vm) => vm.isSelected,
        builder: (_, data, __) => Checkbox(
          value: data,
          onChanged: (value) {
            context.read<SelectableMemberVM>().isSelected = value ?? false;
          },
        ),
      ),
    );
  }

  Widget _avatar(BuildContext context) {
    final vm = context.read<SelectableMemberVM>();
    final hasAvatar = (vm.member.avatar ?? "").isNotEmpty;
    if (hasAvatar) {
      final injector = DI.injector;
      return CachedNetworkImage(
        imageUrl: "${injector.get<AppConfig>()}${vm.member.avatar}",
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
        errorWidget: (context, url, error) => _noAvatarPlaceholder(context),
      );
    }

    return _noAvatarPlaceholder(context);
  }

  Widget _noAvatarPlaceholder(BuildContext context) {
    final vm = context.read<SelectableMemberVM>();
    final memberChars =
        vm.member.fullName.characters.take(2).join().toUpperCase();
    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: const BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SizedBox(
          width: avatarSize / 2,
          height: avatarSize / 2,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Text(
              memberChars,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
