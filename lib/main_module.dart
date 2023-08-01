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
  final List<Bind> binds = [];

// Provide all the routes for the module
  @override
  final List<ModularRoute> routes = [
    ChildRoute(boardPageRoute,
        transition: TransitionType.fadeIn,
        child: (_, args) => CorePage(
            pageName: 'Board',
            render: () => BoardPage(
                analytics: analytics,
                observer: observer
            )
        )
    ),
    ChildRoute(loginPageRoute,
        transition: TransitionType.fadeIn,
        child: (_, args) => CorePage(
            pageName: 'Login',
            render: () => LoginPage()
        )
    ),
    ChildRoute(photographDetailsPageRoute,
        transition: TransitionType.fadeIn,
        child: (_, args) => CorePage(
            pageName: 'Photo details',
            render: () => PhotographDetailPage(
                id: int.parse(args.queryParams['id']!),
                category: args.queryParams['category']!,
                analytics: analytics,
                observer: observer
            )
        )
    ),
    ChildRoute(videoDetailsPageRoute,
        transition: TransitionType.fadeIn,
        child: (_, args) => CorePage(
            pageName: 'Video details',
            render: () => VideoDetailPage(
                path: args.params['path'],
                analytics: analytics,
                observer: observer
            )
        )
    ),
  ];
}
