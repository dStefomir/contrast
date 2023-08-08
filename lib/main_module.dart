import 'package:contrast/modules/board/page.dart';
import 'package:contrast/modules/detail/photograph/view/page.dart';
import 'package:contrast/modules/detail/video/page.dart';
import 'package:contrast/modules/login/page.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'core/page.dart';

const String boardPageRoute = '/';
const String loginPageRoute = '/login';
const String photographDetailsPageRoute = '/photos/details';
const String videoDetailsPageRoute = '/videos/details/:path';

/// Represents the main module of the app
class MainModule extends Module {

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  // Provide a list of dependencies to inject into the project
  @override
  void binds(i) {}
  // Provide all the routes for the module
  @override
  void routes(r) {
    r.child(
        boardPageRoute,
        transition: TransitionType.fadeIn,
        duration: const Duration(milliseconds: 800),
        child: (_) => CorePage(
            pageName: 'Board',
            render: () => BoardPage(
                analytics: analytics,
                observer: observer
            )
        )
    );
    r.child(
        loginPageRoute,
        transition: TransitionType.downToUp,
        duration: const Duration(milliseconds: 800),
        child: (_) => CorePage(
            pageName: 'Login',
            render: () => LoginPage()
        )
    );
    r.child(
        photographDetailsPageRoute,
        transition: TransitionType.scale,
        duration: const Duration(milliseconds: 800),
        child: (_) => CorePage(
            pageName: 'Photograph details',
            render: () => PhotographDetailPage(
                id: int.parse(r.args.queryParams['id']!),
                category: r.args.queryParams['category']!,
                analytics: analytics,
                observer: observer
            )
        )
    );
    r.child(
        videoDetailsPageRoute,
        transition: TransitionType.scale,
        duration: const Duration(milliseconds: 800),
        child: (_) => CorePage(
            pageName: 'Video details',
            render: () => VideoDetailPage(
                path: r.args.params['path'],
                analytics: analytics,
                observer: observer
            )
        )
    );
  }
}
