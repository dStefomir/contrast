import 'package:contrast/common/extentions/zoom.dart';
import 'package:contrast/common/widgets/button.dart';
import 'package:contrast/common/widgets/icon.dart';
import 'package:contrast/common/widgets/input.dart';
import 'package:contrast/common/widgets/page.dart';
import 'package:contrast/common/widgets/snack.dart';
import 'package:contrast/modules/login/provider.dart';
import 'package:contrast/modules/login/service.dart';
import 'package:contrast/security/session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Renders the login page
class LoginPage extends HookConsumerWidget {
  /// Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Form(
    key: formKey,
    child: BackgroundPage(
        key: const Key('LoginBackgroundPage'),
        child: Stack(
          key: const Key('LoginStack'),
          children: [
            Container(
              key: const Key('LoginStackGradient'),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.2),
                  ],
                ),
              ),
            ),
            IconRenderer(
                key: const Key('LogicStackBackgroundSvg'),
                asset: 'background.svg',
                color: Colors.black.withOpacity(0.05),
                fit: BoxFit.fill
            ),
            Align(
              key: const Key('LoginTitleAlign'),
              alignment: Alignment.topCenter,
              child: Padding(
                key: const Key('LoginTitlePadding'),
                padding: const EdgeInsets.only(top: 50),
                child: Text(
                    key: const Key('LoginTitleText'),
                    FlutterI18n.translate(context, 'L O G I N'),
                    style: const TextStyle(fontSize: 40)
                ),
              ),
            ),
            Center(
              key: const Key('LoginInputCenter'),
              child: Column(
                key: const Key('LoginInputColumn'),
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    key: const Key('LoginInputUserPadding'),
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                        key: const Key('LoginInputUserSizedBox'),
                        width: 400,
                        child: SimpleInput(
                          widgetKey: const Key('user'),
                          labelText: FlutterI18n.translate(context, 'User'),
                          onChange: (text) => ref.read(userNameProvider.notifier).setUserName(text),
                          prefixIcon: Icons.person,
                          validator: (value) {
                            if (value != null && value.isEmpty) {
                              return FlutterI18n.translate(context, 'This field is mandatory');
                            }
                            return null;
                            },
                        )
                    ),
                  ),
                  Padding(
                    key: const Key('LoginInputPasswordPadding'),
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                        key: const Key('LoginInputPasswordSizedBox'),
                        width: 400,
                        child: SimpleInput(
                          widgetKey: const Key('password'),
                          labelText: FlutterI18n.translate(context, 'Password'),
                          onChange: (text) => ref.read(userPasswordProvider.notifier).setUserPassword(text),
                          prefixIcon: Icons.password,
                          password: true,
                          validator: (value) {
                            if (value != null && value.isEmpty) {
                              return FlutterI18n.translate(context, 'This field is mandatory');
                            }
                            return null;
                            },
                        )
                    ),
                  ),
                  OutlinedButton(
                    key: const Key('LoginSubmitButton'),
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.black),
                        elevation: MaterialStateProperty.all(2),
                        foregroundColor: MaterialStateProperty.all(Colors.white),
                        textStyle: MaterialStateProperty.all(const TextStyle(color: Colors.white))
                    ),
                    onPressed: () {
                      final form = formKey.currentState;
                      if (form != null && form.validate()) {
                        final String userName = ref.read(userNameProvider);
                        final String userPassword = ref.read(userPasswordProvider);
                        ref.read(authenticationServiceProvider).login(userName, userPassword).then((value) {
                          final Session session = ref.read(sessionProvider);
                          session.eMail = userName;
                          session.token = value;
                          session.isGuest = false;
                          showSuccessTextOnSnackBar(context, FlutterI18n.translate(context, 'Logged in successfully'));
                          Modular.to.navigate('/', arguments: session);
                        }).onError((error, stackTrace) {
                          showErrorTextOnSnackBar(context, FlutterI18n.translate(context, 'Wrong user or password'));
                        });
                      }},
                    child: Text(
                        key: const Key('LoginSubmitButtonText'),
                        FlutterI18n.translate(context, 'Log In')
                    ),
                  ).translateOnPhotoHover,
                ],
              ),
            ),
            Align(
              key: const Key('LoginCloseButtonAlign'),
              alignment: Alignment.topLeft,
              child: DefaultButton(
                  key: const Key('LoginCloseButton'),
                  onClick: () => Modular.to.navigate("/"),
                  color: Colors.black,
                  borderColor: Colors.black,
                  tooltip: FlutterI18n.translate(context, 'Close'),
                  icon: 'close.svg'
              ),
            ),
          ],
        )
    ),
  );
}
