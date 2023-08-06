import 'package:contrast/common/widgets/load.dart';
import 'package:contrast/common/widgets/map/provider.dart';
import 'package:contrast/common/widgets/text.dart';
import 'package:contrast/model/image_data.dart';
import 'package:contrast/modules/detail/photograph/provider.dart';
import 'package:contrast/modules/detail/photograph/view/details.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
  ConsumerState createState() => PhotographDetailPageState();
}

class PhotographDetailPageState extends ConsumerState<PhotographDetailPage> {

  @override
  void initState() {
    // Send analytics when the widget is first built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.analytics.logEvent(
          name: 'photo_details',
          parameters: <String, dynamic>{
            'id': widget.id,
          });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = ref.watch(fetchBoardProvider);

    return dataProvider.when(
        data: (data) {
          final int photoIndex = data.indexWhere((element) => element.id == widget.id);
          // Photograph geo providers has to be initialized with with geo data if there is any.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final ImageData photograph = data[photoIndex];
            if (photograph.lat != null) {
              ref.read(mapLatProvider.notifier).setCurrentLat(photograph.lat!);
            }
            if (photograph.lng != null) {
              ref.read(mapLngProvider.notifier).setCurrentLng(photograph.lng!);
            }
          });

          return PhotographDetailsView(images: data, photoIndex: photoIndex, category: widget.category);
        },
        error: (error, stackTrace) => Center(
            child: StyledText(
              text: error.toString(),
              color: Colors.white,
              weight: FontWeight.bold,
              clip: false,
            )
        ),
        loading: () => const LoadingIndicator(color: Colors.white)
    );
  }
}
