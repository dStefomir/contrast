import 'package:contrast/modules/about/page.dart';
import 'package:contrast/modules/board/page.dart';
import 'package:contrast/modules/board/provider.dart';
import 'package:contrast/modules/detail/photograph/view/page.dart';
import 'package:contrast/modules/detail/video/page.dart';
import 'package:contrast/modules/login/page.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'core/page.dart';

const String _boardPageRoute = '/';
const String _loginPageRoute = '/login';
const String _photographDetailsPageRoute = '/photos/details';
const String _videoDetailsPageRoute = '/videos/details';
const String _aboutPageRoute = '/about';

/// Represents the main module of the app
class MainModule extends Module {

  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver _observer = FirebaseAnalyticsObserver(analytics: _analytics);

  // Provide a list of dependencies to inject into the project
  @override
  void binds(i) {}
  // Provide all the routes for the module
  @override
  void routes(r) {
    r.child(
        _boardPageRoute,
        transition: TransitionType.scale,
        duration: const Duration(milliseconds: 800),
        child: (_) => CorePage(
            pageName: 'Board',
            render: () => BoardPage(
                analytics: _analytics,
                observer: _observer,
            )
        )
    );
    r.child(
        _loginPageRoute,
        transition: TransitionType.downToUp,
        duration: const Duration(milliseconds: 800),
        child: (_) => CorePage(
            onPageDismissed: (_) => Modular.to.navigate(_boardPageRoute),
            pageName: 'Login',
            render: () => LoginPage()
        )
    );
    r.child(
        _photographDetailsPageRoute,
        transition: TransitionType.scale,
        duration: const Duration(milliseconds: 800),
        child: (_) => CorePage(
            onPageDismissed: (ref) {
              ref.read(overlayVisibilityProvider(const Key('comment_photograph')).notifier).setOverlayVisibility(null);
              ref.read(overlayVisibilityProvider(const Key('trip_planning_photograph')).notifier).setOverlayVisibility(null);
              Modular.to.navigate(_boardPageRoute);
            },
            pageName: 'Photograph details',
            render: () {
              /// Handles a bug when navigating with the back button of the browser
              if (r.args.queryParams['id'] == null || r.args.queryParams['category'] == null) {
                Modular.to.navigate('/');
              }
              return PhotographDetailPage(
                  id: int.parse(r.args.queryParams['id']!),
                  category: r.args.queryParams['category']!,
                  analytics: _analytics,
                  observer: _observer
              );
            }
        )
    );
    r.child(
        _videoDetailsPageRoute,
        transition: TransitionType.scale,
        duration: const Duration(milliseconds: 800),
        child: (_) => CorePage(
            onPageDismissed: (ref) {
              ref.read(overlayVisibilityProvider(const Key('comment_video')).notifier).setOverlayVisibility(null);
              Modular.to.navigate(_boardPageRoute);
            },
            pageName: 'Video details',
            render: () {
              /// Handles a bug when navigating with the back button of the browser
              if (r.args.queryParams['path'] == null || r.args.queryParams['id'] == null) {
                Modular.to.navigate('/');
              }
              return VideoDetailPage(
                  path: r.args.queryParams['path'] ?? '',
                  id: int.parse('${r.args.queryParams['id']}'),
                  analytics: _analytics,
                  observer: _observer
              );
            }
        )
    );
    r.child(
        _aboutPageRoute,
        transition: TransitionType.scale,
        duration: const Duration(milliseconds: 800),
        child: (_) => CorePage(
            onPageDismissed: (_) => Modular.to.navigate(_boardPageRoute),
            pageName: 'About',
            render: () => AboutPage(
                analytics: _analytics,
                observer: _observer
            )
        )
    );
  }
}
