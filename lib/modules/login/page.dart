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
          children: [
            IconRenderer(
                asset: 'background.svg',
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.05)
            ),
            const Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 50),
                child: Text('L O G I N', style: TextStyle(fontSize: 40)),
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
                          labelText: 'User',
                          onChange: (text) => ref.read(userNameProvider.notifier).setUserName(text),
                          prefixIcon: Icons.person,
                          validator: (value) {
                            if (value != null && value.isEmpty) {
                              return 'This field is mandatory.';
                            }
                            return null;
                            },
                        )
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                        width: 400,
                        child: SimpleInput(
                          widgetKey: const Key('password'),
                          labelText: 'Password',
                          onChange: (text) => ref.read(userPasswordProvider.notifier).setUserPassword(text),
                          prefixIcon: Icons.password,
                          password: true,
                          validator: (value) {
                            if (value != null && value.isEmpty) {
                              return 'This field is mandatory.';
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
                          showSuccessTextOnSnackBar(context, 'Logged in successfully');
                          Modular.to.navigate('/', arguments: session);
                        }).onError((error, stackTrace) {
                          showErrorTextOnSnackBar(context, 'Wrong user or password.');
                        });
                      }},
                    child: const Text('Log In'),
                  ).translateOnPhotoHover,
                ],
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: RoundedButton(
                  onClick: () => Modular.to.navigate("/"),
                  color: Colors.black,
                  borderColor: Colors.black,
                  icon: 'close.svg'
              ),
            ),
          ],
        )
    ),
  );
}
