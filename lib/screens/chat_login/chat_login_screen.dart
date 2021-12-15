import 'package:auto_route/auto_route.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:lifecycle/lifecycle.dart';
import 'package:sputnikn_chatsample/constants/assets.dart';
import 'package:sputnikn_chatsample/constants/palette.dart';
import 'package:sputnikn_chatsample/di/di.dart';
import 'package:sputnikn_chatsample/screens/chat_login/chat_login_vm.dart';
import 'package:sputnikn_chatsample/screens/chat_login/chat_login_event_handler.dart';
import 'package:sputnikn_chatsample/screens/widgets/tap_reset_focus_area.dart';
import 'package:sputnikn_chatsample/services/chat_service/chat_service_base.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sputnikn_chatsample/util/extension/text_editing_controller_bind_extension.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChatLoginScreen extends StatefulWidget implements AutoRouteWrapper {
  const ChatLoginScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChatLoginScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => ChatLoginVM(
        eventHandler: ChatLoginEventHandler(ctx),
        chatService: DI.injector.get<ChatServiceBase>(),
      ),
      builder: (_, __) => this,
    );
  }
}

class _ChatLoginScreenState extends State<ChatLoginScreen> with LifecycleAware, LifecycleMixin {
  final _loginController = TextEditingController(text: "");
  final _passwordController = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      final viewModel = context.read<ChatLoginVM>();
      _loginController.bindTwoWay(
        sourceNotifier: viewModel,
        valueGetter: () => viewModel.login,
        valueSetter: (value) => viewModel.login = value,
      );
      _passwordController.bindTwoWay(
        sourceNotifier: viewModel,
        valueGetter: () => viewModel.password,
        valueSetter: (value) => viewModel.password = value,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowGlow();
          return true;
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: TapResetFocusArea(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: Svg(Assets.bgSigInPath),
                  fit: BoxFit.fitHeight,
                ),
              ),
              padding: const EdgeInsets.only(
                left: 32.0,
                right: 32.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Assets.logo(width: 100, height: 100),
                  const SizedBox(height: 8),
                  _appLabel(),
                  const SizedBox(height: 24),
                  _loginField(),
                  const SizedBox(height: 24),
                  _passwordField(),
                  const SizedBox(height: 40),
                  _btnSignIn(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _appLabel() {
    return RichText(
      text: const TextSpan(
        text: "Sputnik",
        style: TextStyle(
          fontSize: 36,
          color: Palette.color3,
        ),
        children: [
          TextSpan(
            text: "-N",
            style: TextStyle(
              fontSize: 36,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _loginField() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.chat_login_field_login,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _loginController,
          maxLines: 1,
          decoration: InputDecoration(
            filled: true,
            fillColor: Palette.color1,
            hintText: AppLocalizations.of(context)!.chat_login_field_login,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                width: 0,
                style: BorderStyle.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _passwordField() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.chat_login_field_password,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          maxLines: 1,
          decoration: InputDecoration(
            filled: true,
            fillColor: Palette.color1,
            hintText: AppLocalizations.of(context)!.chat_login_field_password,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                width: 0,
                style: BorderStyle.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _btnSignIn() {
    return TextButton(
      style: TextButton.styleFrom(
        fixedSize: const Size(150, 50),
      ),
      onPressed: context.read<ChatLoginVM>().onAuthTap,
      child: Text(AppLocalizations.of(context)!.chat_login_btn_auth),
    );
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void onLifecycleEvent(LifecycleEvent event) {
    if (event == LifecycleEvent.pop) {
      return;
    }
    context.read<ChatLoginVM>().onLifecycleEvent(event);
  }
}
