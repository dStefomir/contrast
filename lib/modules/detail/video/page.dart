import 'package:contrast/common/widgets/button.dart';
import 'package:contrast/common/widgets/page.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// Renders the video details page
class VideoDetailPage extends StatefulHookConsumerWidget {
  /// Firebase plugins
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  /// Video url
  final String path;

  const VideoDetailPage({
    required this.analytics,
    required this.observer,
    required this.path,
    super.key
  });

  @override
  ConsumerState createState() => VideoDetailPageState();
}

class VideoDetailPageState extends ConsumerState<VideoDetailPage> {
  /// Youtube controller
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Send analytics when the widget is first built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.analytics.logEvent(
          name: 'video_details',
          parameters: <String, dynamic>{
            'id': widget.path,
          });
    });
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.path,
      autoPlay: false,
      params: const YoutubePlayerParams(
          showFullscreenButton: true, showControls: true),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.close();
  }

  /// Renders the back button
  Widget _renderBackButton() =>
      RoundedButton(
          onClick: () => Modular.to.navigate('/'),
          color: Colors.white,
          borderColor: Colors.black,
          icon: 'close.svg'
      );

  @override
  Widget build(BuildContext context) => LayoutBuilder(
      builder: (context, constraints) => BackgroundPage(
          color: Colors.black,
          child: YoutubePlayerScaffold(
            controller: _controller,
            aspectRatio: 16 / 9,
            builder: (context, player) =>
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _renderBackButton(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: SizedBox(
                          width: constraints.maxWidth,
                          height: constraints.maxHeight - 100,
                          child: player
                      ),
                    ),
                  ],
                ),
          )
      )
  );
}
