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
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_translate/flutter_translate.dart';
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
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.2),
                  ],
                ),
              ),
            ),
            IconRenderer(
              width: double.infinity,
              height: double.infinity,
              asset: 'background_portrait.svg',
              color: Colors.black.withOpacity(0.05),
              fit: BoxFit.cover,
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Text(
                    translate('L O G I N'),
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
                          labelText: translate('User'),
                          onChange: (text) => ref.read(userNameProvider.notifier).setUserName(text),
                          prefixIcon: Icons.person,
                          validator: (value) {
                            if (value != null && value.isEmpty) {
                              return translate('This field is mandatory');
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
                          labelText: translate('Password'),
                          onChange: (text) => ref.read(userPasswordProvider.notifier).setUserPassword(text),
                          prefixIcon: Icons.password,
                          password: true,
                          validator: (value) {
                            if (value != null && value.isEmpty) {
                              return translate('This field is mandatory');
                            }
                            return null;
                            },
                        )
                    ),
                  ),
                  OutlinedButton(
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
                          showSuccessTextOnSnackBar(context, translate('Logged in successfully'));
                          Modular.to.navigate('/', arguments: session);
                        }).onError((error, stackTrace) {
                          showErrorTextOnSnackBar(context, translate('Wrong user or password'));
                        });
                      }},
                    child: Text(translate('Log In')),
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
                  tooltip: translate('Close'),
                  icon: 'close.svg'
              ),
            ),
          ],
        )
    ),
  );
}
