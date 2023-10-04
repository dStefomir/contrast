import 'package:audioplayers/audioplayers.dart';
import 'package:contrast/common/widgets/page.dart';
import 'package:contrast/common/widgets/load.dart';
import 'package:contrast/common/widgets/map/provider.dart';
import 'package:contrast/common/widgets/text.dart';
import 'package:contrast/modules/board/provider.dart';
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
  /// Web audio player
  late AudioPlayer player;

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
    player = AudioPlayer();
    player.onPlayerComplete.listen((_) => _resetMusicWhenEnded());
    super.initState();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  /// Reset the currentTime to 0 and play music again
  void _resetMusicWhenEnded() async {
    await player.stop();
    await player.play(AssetSource('background_music.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = ref.watch(fetchBoardProvider);

    return WillPopScope(
      onWillPop: () async {
        if(ref.read(overlayVisibilityProvider(const Key('comment_photograph'))) != null) {
          ref.read(overlayVisibilityProvider(const Key('comment_photograph')).notifier).setOverlayVisibility(null);

          return false;
        }

        return true;
      },
      child: BackgroundPage(
        key: const Key('PhotographDetailsBackground'),
        color: Colors.black,
        child: dataProvider.when(
            data: (data) {
              final int photoIndex = data.indexWhere((element) => element.id == widget.id);
              // Photograph geo providers has to be initialized with with geo data if there is any.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (data[photoIndex].lat != null) {
                  ref.read(mapLatProvider.notifier).setCurrentLat(data[photoIndex].lat!);
                }
                if (data[photoIndex].lng != null) {
                  ref.read(mapLngProvider.notifier).setCurrentLng(data[photoIndex].lng!);
                }
              });

              return PhotographDetailsView(
                  key: const Key('PhotographDetailsPage'),
                  images: data,
                  photoIndex: photoIndex,
                  category: widget.category,
                  audio: player
              );
            },
            error: (error, stackTrace) => Center(
                key: const Key('PhotographDetailsCenterError'),
                child: StyledText(
                  key: const Key('PhotographDetailsCenterErrorText'),
                  text: error.toString(),
                  color: Colors.white,
                  weight: FontWeight.bold,
                  clip: false,
                )
            ),
            loading: () => const Center(
              key: Key('PhotographDetailsCenterLoading'),
              child: LoadingIndicator(
                  key: Key('PhotographDetailsCenterLoadingIndicator'),
                  color: Colors.white
              ),
            )
        ),
      ),
    );
  }
}
