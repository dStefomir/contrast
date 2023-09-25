import 'dart:convert';

import 'package:contrast/common/widgets/animation.dart';
import 'package:contrast/common/widgets/blur.dart';
import 'package:contrast/common/widgets/button.dart';
import 'package:contrast/common/widgets/icon.dart';
import 'package:contrast/common/widgets/page.dart';
import 'package:contrast/common/widgets/text.dart';
import 'package:contrast/model/video_comments.dart';
import 'package:contrast/modules/board/provider.dart';
import 'package:contrast/modules/detail/overlay/comment.dart';
import 'package:contrast/modules/detail/overlay/provider.dart';
import 'package:contrast/modules/detail/overlay/service.dart';
import 'package:contrast/security/session.dart';
import 'package:contrast/utils/date.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../common/widgets/snack.dart';

/// Renders the video details page
class VideoDetailPage extends StatefulHookConsumerWidget {
  /// Firebase plugins
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  /// Video url
  final String path;
  /// Video id
  final int id;

  const VideoDetailPage({
    required this.analytics,
    required this.observer,
    required this.path,
    required this.id,
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.close();
    ref.read(overlayVisibilityProvider(const Key('comment_video')).notifier).setOverlayVisibility(null);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  /// Renders the comments button
  Widget _renderCommentsButton() =>
      DefaultButton(
          key: const Key('VideoDetailsCommentsButton'),
          onClick: () => ref.read(overlayVisibilityProvider(const Key('comment_video')).notifier).setOverlayVisibility(true),
          color: Colors.white,
          borderColor: Colors.black,
          tooltip: FlutterI18n.translate(context, 'Comments'),
          icon: 'comment.svg'
      );

  /// Renders the share button
  Widget _renderShareButton() =>
      DefaultButton(
          key: const Key('VideoDetailsShareButton'),
          onClick: () {
            ref.read(overlayVisibilityProvider(const Key('comment_video')).notifier).setOverlayVisibility(null);
            Clipboard.setData(
                ClipboardData(text: 'https://www.dstefomir.eu/#/videos/details/${widget.path}')
            ).then((value) => showSuccessTextOnSnackBar(
                context,
                FlutterI18n.translate(context, 'Copied to clipboard'
                )
            ));},
          color: Colors.white,
          tooltip: FlutterI18n.translate(context, 'Share'),
          borderColor: Colors.black,
          icon: 'share.svg'
      );

  /// Renders the back button
  Widget _renderBackButton(BuildContext context) =>
      DefaultButton(
          key: const Key('VideoDetailsBackButton'),
          onClick: () {
            ref.read(overlayVisibilityProvider(const Key('comment_video')).notifier).setOverlayVisibility(null);
            Modular.to.navigate('/');
            },
          color: Colors.white,
          tooltip: FlutterI18n.translate(context, 'Close'),
          borderColor: Colors.black,
          icon: 'close.svg'
      );

  @override
  Widget build(BuildContext context) {
    final bool? shouldShowCommentsDialog = ref.watch(overlayVisibilityProvider(const Key('comment_video')));
    useValueChanged(shouldShowCommentsDialog, (_, __) async {
      if(shouldShowCommentsDialog == null || !shouldShowCommentsDialog) {
        _controller.close();
        _controller = YoutubePlayerController.fromVideoId(
          videoId: widget.path,
          autoPlay: false,
          params: const YoutubePlayerParams(
              showFullscreenButton: true, showControls: true),
        );
      }
    });

    return RawKeyboardListener(
      key: const Key('VideoDetailsKeyboardListener'),
      autofocus: true,
      focusNode: useFocusNode(),
      onKey: (RawKeyEvent event) {
        if (event.logicalKey == LogicalKeyboardKey.escape) {
          Modular.to.navigate('/');
        }
      },
      child: LayoutBuilder(
          key: const Key('VideoDetailsLayoutBuilder'),
          builder: (context, constraints) =>
              BackgroundPage(
                  key: const Key('VideoDetailsBackgroundPage'),
                  color: Colors.black,
                  child: YoutubePlayerScaffold(
                    key: const Key('VideoDetailsYoutubeScaffold'),
                    controller: _controller,
                    aspectRatio: 16 / 9,
                    builder: (context, player) =>
                        Stack(
                          key: const Key('VideoDetailsStack'),
                          alignment: Alignment.center,
                          children: [
                            IconRenderer(
                                key: const Key('VideoDetailsStackBackgroundSvg'),
                                asset: 'background.svg',
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                color: Colors.white.withOpacity(0.05)
                            ),
                            Align(
                              key: const Key('VideoDetailsAlignBack'),
                              alignment: Alignment.topLeft,
                              child: Padding(
                                key: const Key('VideoDetailsAlignBackPadding'),
                                padding: const EdgeInsets.all(5.0),
                                child: _renderBackButton(context),
                              ),
                            ),
                            Align(
                              key: const Key('VideoDetailsAlignShare'),
                              alignment: Alignment.topLeft,
                              child: Padding(
                                key: const Key('VideoDetailsAlignSharePadding'),
                                padding: const EdgeInsets.only(
                                  left: 60.0, top: 5.0,),
                                child: _renderShareButton(),
                              ),
                            ),
                            Align(
                              key: const Key('VideoDetailsAlignComments'),
                              alignment: Alignment.topLeft,
                              child: Padding(
                                key: const Key('VideoDetailsAlignCommentsPadding'),
                                padding: const EdgeInsets.only(
                                  left: 115.0, top: 5.0,),
                                child: _renderCommentsButton(),
                              ),
                            ),
                            if(shouldShowCommentsDialog != null && shouldShowCommentsDialog) const Blurrable(key: Key('BlurableDetailsPage'), strength: 10),
                            if (shouldShowCommentsDialog != null) Align(
                              key: const Key('CommentsDialogAlign'),
                              alignment: Alignment.bottomCenter,
                              child: SlideTransitionAnimation(
                                  key: const Key('CommentsDialogSlideAnimation'),
                                  duration: const Duration(milliseconds: 1000),
                                  getStart: () => shouldShowCommentsDialog ? const Offset(0, 1) : const Offset(0, 0),
                                  getEnd: () => shouldShowCommentsDialog ? const Offset(0, 0) : const Offset(0, 10),
                                  whenTo: (controller) {
                                    useValueChanged(shouldShowCommentsDialog, (_, __) async {
                                      controller.reset();
                                      controller.forward();
                                    });
                                  },
                                  child: CommentDialog<VideoCommentsData>(
                                      widgetKey: const Key('comment_video'),
                                      parentItemId: widget.id,
                                      serviceProvider: videoCommentsDataViewProvider,
                                      itemBuilder: (BuildContext context, VideoCommentsData item, List<String> submittedComments, SharedPreferences sharedPrefs, int index) => Padding(
                                        key: const Key('CommentDialogListPadding'),
                                        padding: const EdgeInsets.only(top: 25, left: 25, right: 25),
                                        child: Column(
                                          key: const Key('CommentDialogListColumn'),
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                StyledText(
                                                  text: utf8.decode(item.deviceName!.runes.toList()),
                                                  fontSize: 15,
                                                  weight: FontWeight.bold,
                                                  clip: false,
                                                  align: TextAlign.start,
                                                  padding: 0,
                                                ),
                                                const SizedBox(width: 5,),
                                                if(item.rating! > 0) RatingBar.builder(
                                                  initialRating: item.rating!,
                                                  minRating: 0,
                                                  direction: Axis.horizontal,
                                                  allowHalfRating: false,
                                                  ignoreGestures: true,
                                                  itemSize: 25,
                                                  glow: true,
                                                  itemCount: 5,
                                                  itemBuilder: (context, _) => const Icon(
                                                    Icons.star,
                                                    color: Colors.amber,
                                                  ),
                                                  onRatingUpdate: (rating) {},
                                                ),
                                                const Spacer(),
                                                if (submittedComments.contains('${item.id}') || Session().isLoggedIn()) DefaultButton(
                                                    key: const Key('CommentDeleteButton'),
                                                    padding: 0,
                                                    height: 25,
                                                    onClick: () => ref.read(commentsServiceProvider).deleteVideoComment(item.id!).then((value) {
                                                      ref.read(videoCommentsDataViewProvider.notifier).removeItem(index);
                                                      sharedPrefs.setStringList('submittedComments', submittedComments..remove('${value.id}'));
                                                      showSuccessTextOnSnackBar(context, FlutterI18n.translate(context, 'Comment deleted'));
                                                    }),
                                                    tooltip: FlutterI18n.translate(context, 'Delete comment'),
                                                    color: Colors.white.withOpacity(0.3),
                                                    borderColor: Colors.white,
                                                    icon: 'delete.svg'
                                                )
                                              ],),
                                            Padding(
                                              padding: EdgeInsets.only(top: submittedComments.contains('${item.id}') ? 3 : 5, bottom: 5),
                                              child: StyledText(
                                                text: formatTimeDifference(item.date),
                                                fontSize: 10,
                                                color: Colors.black38,
                                                weight: FontWeight.bold,
                                                align: TextAlign.start,
                                                letterSpacing: 3,
                                                padding: 0,
                                              ),
                                            ),
                                            StyledText(
                                              text: utf8.decode(item.comment!.runes.toList()),
                                              fontSize: 13,
                                              clip: false,
                                              align: TextAlign.start,
                                              color: Colors.black87,
                                              padding: 0,
                                            ),
                                          ],
                                        ),
                                      )
                                  )
                              ),
                            ),
                            if (shouldShowCommentsDialog == null || !shouldShowCommentsDialog) SizedBox(
                                key: const Key('VideoDetailsSizedBoxPlayer'),
                                width: constraints.maxWidth,
                                height: constraints.maxHeight - 130,
                                child: player
                            )
                          ],
                        ),
                  )
              )
      ),
    );
  }
}
