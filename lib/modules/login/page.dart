import 'package:contrast/common/extentions/zoom.dart';
import 'package:contrast/common/widgets/button.dart';
import 'package:contrast/common/widgets/input.dart';
import 'package:contrast/common/widgets/page.dart';
import 'package:contrast/common/widgets/snack.dart';
import 'package:contrast/modules/login/provider.dart';
import 'package:contrast/modules/login/service.dart';
import 'package:contrast/security/session.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.0),
                    Colors.black.withValues(alpha: 0.2),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Text(
                    'L O G I N'.tr(),
                    style: const TextStyle(fontSize: 40)
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                        width: 400,
                        child: SimpleInput(
                          widgetKey: const Key('user'),
                          labelText: 'User'.tr(),
                          onChange: (text) => ref.read(userNameProvider.notifier).setUserName(text),
                          prefixIcon: Icons.person,
                          validator: (value) {
                            if (value != null && value.isEmpty) {
                              return 'This field is mandatory'.tr();
                            }
                            return null;
                            },
                        )
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(width: 400,
                        child: SimpleInput(
                          widgetKey: const Key('password'),
                          labelText: 'Password'.tr(),
                          onChange: (text) => ref.read(userPasswordProvider.notifier).setUserPassword(text),
                          prefixIcon: Icons.password,
                          password: true,
                          validator: (value) {
                            if (value != null && value.isEmpty) {
                              return 'This field is mandatory'.tr();
                            }
                            return null;
                            },
                        )
                    ),
                  ),
                  OutlinedButton(
                    style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.black),
                        elevation: WidgetStateProperty.all(2),
                        foregroundColor: WidgetStateProperty.all(Colors.white),
                        textStyle: WidgetStateProperty.all(const TextStyle(color: Colors.white))
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
                          showSuccessTextOnSnackBar(
                              context.mounted
                                  ? context
                                  : null,
                              'Logged in successfully'.tr()
                          );
                          Modular.to.navigate('/', arguments: session);
                        }).onError((error, stackTrace) {
                          showErrorTextOnSnackBar(
                              context.mounted
                                  ? context
                                  : null,
                              'Wrong user or password'.tr()
                          );
                        });
                      }},
                    child: Text('Log In'.tr()),
                  ).translateOnPhotoHover,
                ],
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: DefaultButton(
                  onClick: () => Modular.to.navigate("/"),
                  color: Colors.white,
                  borderColor: Colors.black,
                  tooltip: 'Close'.tr(),
                  icon: 'close.svg'
              ),
            ),
          ],
        )
    ),
  );
}
