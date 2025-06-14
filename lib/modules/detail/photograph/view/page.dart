import 'dart:io';

import 'package:contrast/common/widgets/page.dart';
import 'package:contrast/common/widgets/map/provider.dart';
import 'package:contrast/modules/board/provider.dart';
import 'package:contrast/modules/detail/photograph/provider.dart';
import 'package:contrast/modules/detail/photograph/view/details.dart';
import 'package:contrast/utils/overlay.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loading_indicator/loading_indicator.dart';

/// Renders the photograph details page
class PhotographDetailPage extends StatefulHookConsumerWidget {
  /// Firebase plugins
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  /// Id of the photograph
  final int id;
  /// Selected photograph category
  final String category;

  const PhotographDetailPage({
    required this.analytics,
    required this.observer,
    required this.id,
    required this.category,
    super.key
  });

  @override
  ConsumerState createState() => _PhotographDetailPageState();
}

class _PhotographDetailPageState extends ConsumerState<PhotographDetailPage> {

  @override
  void initState() {
    // Send analytics when the widget is first built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.analytics.logEvent(
          name: 'photo_details',
          parameters: <String, int>{
            'id': widget.id,
          });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = ref.watch(fetchBoardProvider);
    final halfWidth = MediaQuery.of(context).size.width / 2;
    /// Renders a loading indicator
    renderLoadingIndicator() => Center(
      child: SizedBox(
        width: halfWidth,
        child: LoadingIndicator(
          indicatorType: Indicator.triangleSkewSpin,
          colors: [Colors.white.withValues(alpha: 0.2)],
          strokeWidth: 2,
        ),
      ),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) {
        final isCommentOpen = ref.read(overlayVisibilityProvider(const Key('comment_photograph')));
        final isPlanningOpen = ref.read(overlayVisibilityProvider(const Key('trip_planning_photograph')));
        if ((isCommentOpen != null && isCommentOpen) || (isPlanningOpen != null && isPlanningOpen)) {
          closeOverlayIfOpened(ref, 'comment_photograph');
          closeOverlayIfOpened(ref, 'trip_planning_photograph');
        } else if (!kIsWeb && Platform.isAndroid) {
          Modular.to.navigate('/');
        }
      },
      child: GestureDetector(
        onTap: () {
          closeOverlayIfOpened(ref, 'comment_photograph');
          closeOverlayIfOpened(ref, 'trip_planning_photograph');
        },
        child: BackgroundPage(
          color: Colors.black,
          child: dataProvider.when(
              data: (data) {
                final int photoIndex = data.isNotEmpty ? data.indexWhere((element) => element.id == widget.id) : -1;
                // Photograph geo providers has to be initialized with with geo data if there is any.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (data.isNotEmpty && data[photoIndex].lat != null) {
                    ref.read(mapLatProvider.notifier).setCurrentLat(data[photoIndex].lat!);
                  }
                  if (data.isNotEmpty && data[photoIndex].lng != null) {
                    ref.read(mapLngProvider.notifier).setCurrentLng(data[photoIndex].lng!);
                  }
                });

                return PhotographDetailsView(
                    images: data,
                    photoIndex: photoIndex,
                    category: widget.category,
                );
              },
              error: (error, stackTrace) => renderLoadingIndicator(),
              loading: () => renderLoadingIndicator()
          ),
        ),
      ),
    );
  }
}
