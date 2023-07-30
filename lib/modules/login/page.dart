import 'package:contrast/common/widgets/icon.dart';
import 'package:contrast/common/widgets/input/input.dart';
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
  /// Constraints of the page
  final BoxConstraints constraints;

  const LoginPage({required this.constraints, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    String user = "";
    String password = "";

    return BackgroundPage(
        child: Form(
            key: formKey,
            child: Stack(
              children: [
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
                              labelText: 'User',
                              isRequired: true,
                              onChange: (text) => user = text,
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
                              labelText: 'Password',
                              isRequired: true,
                              onChange: (text) => password = text,
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
                            backgroundColor: MaterialStateProperty.all(Colors.white),
                            elevation: MaterialStateProperty.all(2),
                            foregroundColor: MaterialStateProperty.all(Colors.black),
                            textStyle: MaterialStateProperty.all(const TextStyle(color: Colors.black))
                        ),
                        onPressed: () async {
                          final form = formKey.currentState;
                          if (form != null && form.validate()) {
                            ref.read(authenticationServiceProvider).login(user, password).then((value) {
                              final Session session = ref.read(sessionProvider);
                              session.eMail = user;
                              session.token = value;
                              session.isGuest = false;
                              showSuccessTextOnSnackBar(context, 'Logged in successfully');
                              Modular.to.navigate('/', arguments: session);
                            }).onError((error, stackTrace) {
                              showErrorTextOnSnackBar(context, 'Wrong user or password.');
                            });
                          }
                        },
                        child: const Text('Log In'),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: IconTheme(
                      data: const IconThemeData(),
                      child: IconButton(
                          onPressed: () => Modular.to.navigate("/"),
                          icon: const IconRenderer(
                            asset: 'close.svg',
                            width: 20,
                            height: 20,
                            color: Colors.grey,
                          )
                      ),
                    ),
                  ),
                ),
              ],
            )
        )
    );
  }
}
