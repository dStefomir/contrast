import 'dart:io';

import 'package:contrast/common/widgets/page.dart';
import 'package:contrast/core/provider.dart';
import 'package:contrast/modules/login/overlay/cookie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Responsible for wrapping all pages and handling the app bar and the app drawer
class CorePage extends HookConsumerWidget {
  /// Specifies the page path
  final String pageName;
  /// Should resize when keyboard pops
  final bool resizeToAvoidBottomInset;
  /// Renders the holding page
  final Widget Function() render;

  const CorePage({
    Key? key,
    required this.pageName,
    required this.render,
    this.resizeToAvoidBottomInset = true,
  }) : super(key: key);

  /// Should the app display a cookie warning or not
  bool _shouldShowCookie(SharedPreferences prefs, WidgetRef ref) {
    final bool shouldShowCookieOverlay = ref.watch(corePageProvider(prefs.getBool('showCookieWarning') ?? true)) ?? true;

    return shouldShowCookieOverlay;
  }

  /// Submit the cookie warning
  void _onCookieSubmit(SharedPreferences prefs, WidgetRef ref) async {
    final bool shouldShowCookieOverlay = ref.read(
        corePageProvider(
            prefs.getBool('showCookieWarning') ?? true
        )
    ) ?? true;

    ref.read(
        corePageProvider(shouldShowCookieOverlay).notifier
    ).setCookieOverlayDisplay(
        await prefs.setBool('showCookieWarning', false)
    );
  }

  /// Renders the default page widget
  Widget _renderDefaultPage(BuildContext context, WidgetRef ref) => MainScaffold(
    body: FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
          final List<Widget> children = [
            kIsWeb ? render() : BackgroundPage(
              color: Colors.black.withOpacity(0.8),
              child: SafeArea(
                bottom: Platform.isAndroid,
                child: render(),
              ),
            )
          ];
          if (snapshot.hasData && kIsWeb && _shouldShowCookie(snapshot.requireData, ref)) {
            children.add(
                CookieWarningDialog(onSubmit: () => _onCookieSubmit(snapshot.requireData, ref))
            );
          }

          return Stack(children: children);
        }),
    resizeToAvoidBottomInset: resizeToAvoidBottomInset,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return _renderDefaultPage(context, ref);
  }
}

/// Scaffold wrapper for each page
class MainScaffold extends StatelessWidget {
  /// Represent each page`s content
  final Widget body;
  /// Should resize when keyboard pops
  final bool resizeToAvoidBottomInset;

  const MainScaffold(
      {Key? key, required this.body, this.resizeToAvoidBottomInset = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: body,
    );
  }
}
