import 'package:contrast/firebase_options.dart';
import 'package:contrast/main_module.dart';
import 'package:contrast/security/session.dart';
import 'package:contrast/utils/scroll_behavior.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

const String webKey = 'BLgFNQuws2vnlVfNuYDe1N2E2DnCQA0H5LxYSc2YBscxJhb_jfouU4f-hryoyYmftLgWKQDG1Fsl1us4ylwRhSA';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async => await Firebase.initializeApp();

/// Subscribe the client to a fcm topic with a given token
Future<void> _subscribeToTopic(String? token) async {
  await Session.proxy.post('/auth/subscribe?token=$token');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
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
  FirebaseMessaging.instance.onTokenRefresh.listen((String token) async {
    /// Subscribes the token to a firebase topic
    await _subscribeToTopic(token);
  });
  if(!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    // Set the status bar text color to white
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }

  runApp(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('de')],
        path: 'assets/translations',
        child: ModularApp(
            module: MainModule(),
            child: const ProviderScope(
                child: MyApp()
            )
        ),
      )
  );
}

const Color _inputFieldBackgroundColor = Colors.white;
const Color _inputFieldBorderColor = Colors.black;
const Color _inputFieldDisabledBorderColor = Colors.grey;
const Color _inputFieldFocusedBorderColor = Colors.black;
const Color _inputFieldErrorBorderColor = Colors.red;
const Color _inputFieldHintTextColor = Colors.grey;
const Color _buttonIconSvgColor = Colors.black;
const Color _buttonBackgroundColor = Colors.white;
const Color _loadingIndicatorColor = Colors.black;

/// Application itself holding the theming and the app`s delegates
class MyApp extends StatefulWidget {

  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  /// Setup FCMs
  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from a terminated state.
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }
  /// Handle the received fc messages
  void _handleMessage(RemoteMessage message) {
    if(message.data["pageTo"] != null) {
      Future.delayed(const Duration(seconds: 3));
      Modular.to.navigate(message.data["pageTo"]);
    }
  }

  @override
  void initState() {
    setupInteractedMessage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: "Contrast",
        routerConfig: Modular.routerConfig,
        scrollBehavior: NoThumbScrollBehavior().copyWith(scrollbars: false),
        localizationsDelegates: [
          ...context.localizationDelegates,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: ThemeData(
          fontFamily: 'Slovic',
          brightness: Brightness.light,
          inputDecorationTheme: const InputDecorationTheme(
              isDense: true,
              contentPadding: EdgeInsets.all(10),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(0)),
                borderSide: BorderSide(color: _inputFieldBorderColor),
              ),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(0)),
                  borderSide: BorderSide(color: _inputFieldErrorBorderColor)
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(0)),
                borderSide: BorderSide(color: _inputFieldDisabledBorderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(0)),
                borderSide: BorderSide(color: _inputFieldFocusedBorderColor),
              ),
              filled: true,
              fillColor: _inputFieldBackgroundColor,
              hintStyle: TextStyle(color: _inputFieldHintTextColor),
              floatingLabelBehavior: FloatingLabelBehavior.never
          ),
          progressIndicatorTheme: const ProgressIndicatorThemeData(color: _loadingIndicatorColor),
          iconTheme: const IconThemeData(color: _buttonIconSvgColor),
          buttonTheme: const ButtonThemeData(
              height: 50,
              minWidth: 0,
              buttonColor: _buttonBackgroundColor,
              textTheme: ButtonTextTheme.primary
          ),
        )
    );
  }
}
