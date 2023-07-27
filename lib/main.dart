import 'package:contrast/main_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
      ModularApp(
          module: MainModule(),
          child: const ProviderScope(
              child: MyApp()
          )
      )
  );
}

/// Application itself holding the theming and the app`s delegates
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
        title: "Contrast",
        routeInformationParser: Modular.routeInformationParser,
        routerDelegate: Modular.routerDelegate,
        supportedLocales: const [
          Locale('en', ''),
        ],
        theme: ThemeData(
          fontFamily: 'Slovic',
          brightness: Brightness.light,
        ));
  }
}
