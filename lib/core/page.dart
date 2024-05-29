import 'dart:io';

import 'package:contrast/common/widgets/page.dart';
import 'package:contrast/core/provider.dart';
import 'package:contrast/modules/login/overlay/cookie.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Responsible for wrapping all pages and handling the app bar and the app drawer
class CorePage extends HookConsumerWidget {
  /// Specifies the page path
  final String pageName;
  /// Should the page warn for coockies or not
  final bool shouldWarnForCookies;
  /// Should resize when keyboard pops
  final bool resizeToAvoidBottomInset;
  /// Renders the holding page
  final Widget Function() render;
  /// What happens when a page is dismissed
  final void Function(WidgetRef ref)? onPageDismissed;

  const CorePage({
    Key? key,
    required this.pageName,
    required this.render,
    this.shouldWarnForCookies = true,
    this.resizeToAvoidBottomInset = true,
    this.onPageDismissed
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
          final mobileChildPage = BackgroundPage(
            color: Colors.black54,
            child: SafeArea(
              bottom: kIsWeb ? false : Platform.isAndroid,
              left: false,
              right: false,
              child: ClipPath(
                  child: render()
              ),
            ),
          );
          final List<Widget> children = [
            kIsWeb ? render() : onPageDismissed != null ? DismissiblePage(
              onDismissed: () => onPageDismissed!(ref),
              direction: DismissiblePageDismissDirection.multi,
              isFullScreen: false,
                child: mobileChildPage,
            ) : mobileChildPage
          ];
          if (snapshot.hasData && kIsWeb && _shouldShowCookie(snapshot.requireData, ref) && shouldWarnForCookies) {
            children.add(
                CookieWarningDialog(onSubmit: () => _onCookieSubmit(snapshot.requireData, ref))
            );
          }

          return Stack(children: children);
        }),
    resizeToAvoidBottomInset: resizeToAvoidBottomInset,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) => _renderDefaultPage(context, ref);
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
