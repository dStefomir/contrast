import 'package:contrast/firebase_options.dart';
import 'package:contrast/main_module.dart';
import 'package:contrast/security/session.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const String webKey = 'BLgFNQuws2vnlVfNuYDe1N2E2DnCQA0H5LxYSc2YBscxJhb_jfouU4f-hryoyYmftLgWKQDG1Fsl1us4ylwRhSA';

/// Subscribe the client to a fcm topic with a given token
Future<void> _subscribeToTopic(String? token) async {
  if(token != null) {
    await Session.proxy.post('/auth/subscribe?token=$token');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  /// Initialize the firebase app
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  /// Request a permission for showing notifications
  FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: true,
    badge: true,
    carPlay: true,
    criticalAlert: true,
    provisional: false,
    sound: true,
  ).then((permission) async {
    if (permission.authorizationStatus == AuthorizationStatus.authorized) {
      /// Fetches the firebase token
      final fcmToken = await FirebaseMessaging.instance.getToken(vapidKey: webKey);
      /// Subscribes the token to a firebase topic
      await _subscribeToTopic(fcmToken);
    }
  });

  runApp(
      ModularApp(
          module: MainModule(),
          child: const ProviderScope(
              child: MyApp()
          )
      )
  );
}

const Color inputFieldBackgroundColor = Colors.white;
const Color inputFieldBorderColor = Colors.black;
const Color inputFieldDisabledBorderColor = Colors.grey;
const Color inputFieldFocusedBorderColor = Colors.black;
const Color inputFieldErrorBorderColor = Colors.red;
const Color inputFieldTextColor = Colors.black;
const Color inputFieldHintTextColor = Colors.grey;
const Color buttonIconSvgColor = Colors.black;
const Color buttonBackgroundColor = Colors.white;

/// Application itself holding the theming and the app`s delegates
class MyApp extends StatelessWidget {

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      MaterialApp.router(
          title: "Contrast",
          routeInformationParser: Modular.routeInformationParser,
          routerDelegate: Modular.routerDelegate,
          supportedLocales: const [
            Locale('en', '')
          ],
          theme: ThemeData(
            fontFamily: 'Slovic',
            brightness: Brightness.light,
            inputDecorationTheme: const InputDecorationTheme(
                isDense: true,
                contentPadding: EdgeInsets.all(10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(0)),
                  borderSide: BorderSide(color: inputFieldBorderColor),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(0)),
                  borderSide: BorderSide(color: inputFieldErrorBorderColor)
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(0)),
                  borderSide: BorderSide(color: inputFieldDisabledBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(0)),
                    borderSide: BorderSide(color: inputFieldFocusedBorderColor),
                ),
                filled: true,
                fillColor: inputFieldBackgroundColor,
                hintStyle: TextStyle(color: inputFieldHintTextColor),
                floatingLabelBehavior: FloatingLabelBehavior.never
            ),
            iconTheme: const IconThemeData(color: buttonIconSvgColor),
            buttonTheme: const ButtonThemeData(
                height: 50,
                minWidth: 0,
                buttonColor: buttonBackgroundColor,
                textTheme: ButtonTextTheme.primary
            ),
          )
      );
}
