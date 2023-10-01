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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
  /// Key used for the comments overlay
  late Key commentKey;

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
    commentKey = const Key('comment_video');
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  void dispose() {
    _controller.close();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  /// Determines if the video player should be visible or not
  bool shouldHideOverlay(bool? shouldHideOverlay) {
    if (kIsWeb) {
      if(shouldHideOverlay != null && shouldHideOverlay) {
        return true;
      }

      return false;
    }

    return false;
  }

  /// Renders the comments button
  Widget _renderCommentsButton() =>
      DefaultButton(
          key: const Key('VideoDetailsCommentsButton'),
          onClick: () async {
            await _controller.pauseVideo();
            ref.read(overlayVisibilityProvider(commentKey).notifier).setOverlayVisibility(true);
          },
          color: Colors.white,
          borderColor: Colors.black,
          tooltip: FlutterI18n.translate(context, 'Comments'),
          icon: 'comment.svg'
      );

  /// Renders the share button
  Widget _renderShareButton() =>
      DefaultButton(
          key: const Key('VideoDetailsShareButton'),
          onClick: () async {
            await _controller.pauseVideo();
            ref.read(overlayVisibilityProvider(commentKey).notifier).setOverlayVisibility(null);
            Clipboard.setData(
                ClipboardData(text: 'https://www.youtube.com/watch?v=${widget.path}')
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
            ref.read(overlayVisibilityProvider(commentKey).notifier).setOverlayVisibility(null);
            Modular.to.navigate('/');
            },
          color: Colors.white,
          tooltip: FlutterI18n.translate(context, 'Close'),
          borderColor: Colors.black,
          icon: 'close.svg'
      );

  /// Render video details page actions
  List<Widget> _renderActions() => [
    Padding(
      key: const Key('VideoDetailsAlignBackPadding'),
      padding: const EdgeInsets.only(top: 5.0),
      child: _renderBackButton(context),
    ),
    Padding(
      key: const Key('VideoDetailsAlignSharePadding'),
      padding: const EdgeInsets.only(top: 5.0,),
      child: _renderShareButton(),
    ),
    if (!kIsWeb || Session().isLoggedIn()) Padding(
      key: const Key('VideoDetailsAlignCommentsPadding'),
      padding: const EdgeInsets.only(top: 5.0,),
      child: _renderCommentsButton(),
    ),
  ];

  /// Renders the comment overlay
  Widget _renderCommentsOverlay(bool? shouldShowCommentsDialog) => Align(
    key: const Key('CommentsDialogAlign'),
    alignment: Alignment.bottomCenter,
    child: SlideTransitionAnimation(
        key: const Key('CommentsDialogSlideAnimation'),
        duration: const Duration(milliseconds: 1000),
        getStart: () => shouldShowCommentsDialog != null && shouldShowCommentsDialog ? const Offset(0, 1) : const Offset(0, 0),
        getEnd: () => shouldShowCommentsDialog != null && shouldShowCommentsDialog ? const Offset(0, 0) : const Offset(0, 10),
        whenTo: (controller) {
          useValueChanged(shouldShowCommentsDialog, (_, __) async {
            controller.reset();
            controller.forward();
          });
        },
        child: CommentDialog<VideoCommentsData>(
            widgetKey: commentKey,
            parentItemId: widget.id,
            serviceProvider: videoCommentsDataViewProvider,
            itemBuilder: (BuildContext context, VideoCommentsData item, String? deviceId, int index) => Padding(
              key: Key('CommentDialogListPadding$index}'),
              padding: const EdgeInsets.only(top: 25, left: 25, right: 25),
              child: Row(
                children: [
                  Container(
                    key: Key("CommentDialogCircleDivider$index"),
                    width: 5.0,
                    height: 5.0,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    key: Key("CommentDialogExpandedDivider$index"),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Column(
                        key: Key('CommentDialogListColumn$index'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            key: Key('CommentDialogListRow$index'),
                            children: [
                              StyledText(
                                key: Key('CommentDeviceName$index'),
                                text: utf8.decode(item.deviceName!.runes.toList()),
                                fontSize: 15,
                                weight: FontWeight.bold,
                                clip: false,
                                align: TextAlign.start,
                                padding: 0,
                              ),
                              SizedBox(
                                key: Key('CommentDeviceNameSizedBox$index'),
                                width: 5
                              ),
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
                              Spacer(key: Key('CommentRatingBarSpacer$index')),
                              if (deviceId == item.deviceId || Session().isLoggedIn()) DefaultButton(
                                  key: Key('CommentDeleteButton$index'),
                                  padding: 0,
                                  height: 25,
                                  onClick: () => ref.read(commentsServiceProvider).deleteVideoComment(item.id!).then((value) {
                                    ref.read(videoCommentsDataViewProvider.notifier).removeItem(index);
                                    showSuccessTextOnSnackBar(context, FlutterI18n.translate(context, 'Comment deleted'));
                                  }),
                                  tooltip: FlutterI18n.translate(context, 'Delete comment'),
                                  color: Colors.white.withOpacity(0.3),
                                  borderColor: Colors.black,
                                  icon: 'delete.svg'
                              )
                            ],),
                          Padding(
                            key: Key('CommentDialogDatePadding$index'),
                            padding: const EdgeInsets.only(top: 10, bottom: 5),
                            child: StyledText(
                              key: Key('CommentDialogDate$index'),
                              text: formatTimeDifference(context, item.date),
                              fontSize: 10,
                              color: Colors.black38,
                              weight: FontWeight.bold,
                              align: TextAlign.start,
                              letterSpacing: 3,
                              padding: 0,
                            ),
                          ),
                          StyledText(
                            key: Key('CommentDialogTextComment$index'),
                            text: utf8.decode(item.comment!.runes.toList()),
                            fontSize: 13,
                            clip: false,
                            align: TextAlign.start,
                            color: Colors.black87,
                            padding: 0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
        )
    ),
  );

  @override
  Widget build(BuildContext context) {
    final bool? shouldShowCommentsDialog = ref.watch(overlayVisibilityProvider(commentKey));
    /// If its web reset the controller when the comments overlay is closed
    useValueChanged(shouldShowCommentsDialog, (_, __) async {
      if(kIsWeb && shouldShowCommentsDialog != null && !shouldShowCommentsDialog) {
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
      child: BackgroundPage(
          key: const Key('VideoDetailsBackgroundPage'),
          color: Colors.black,
          child: OrientationBuilder(
            builder: (BuildContext context, Orientation orientation) => Stack(
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
                if(!shouldHideOverlay(shouldShowCommentsDialog)) Padding(
                  key: const Key('VideoDetailsYoutubeScaffoldPadding'),
                  padding: EdgeInsets.only(
                      top: orientation == Orientation.landscape && kIsWeb ? 40 : 0,
                      bottom: orientation == Orientation.landscape && kIsWeb ? 40 : 0,
                      left: orientation == Orientation.portrait ? 0 : kIsWeb ? 35 : 60,
                      right: orientation == Orientation.portrait ? 0 : kIsWeb ? 35 : 0
                  ),
                  child: YoutubePlayerScaffold(
                      key: const Key('VideoDetailsYoutubeScaffold'),
                      aspectRatio: 16 / 9,
                      backgroundColor: Colors.transparent,
                      controller: _controller,
                      builder: (context, player) => player
                  ),
                ),
                Align(
                  key: const Key('VideoDetailsActionsOrientationAlign'),
                  alignment: orientation == Orientation.portrait ? Alignment.topCenter : Alignment.topLeft,
                  child: orientation == Orientation.portrait ? Row(
                      key: const Key('VideoDetailsActionsRow'),
                      children: _renderActions()
                  ) : Padding(
                    key: const Key('VideoDetailsActionsColumnPadding'),
                    padding: const EdgeInsets.only(top: 40),
                    child: Column(
                      key: const Key('VideoDetailsActionsColumn'),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: _renderActions(),
                    ),
                  ),
                ),
                if((!kIsWeb || Session().isLoggedIn()) && shouldShowCommentsDialog != null && shouldShowCommentsDialog) const Blurrable(key: Key('BlurableDetailsPage'), strength: 10),
                if ((!kIsWeb || Session().isLoggedIn()) && shouldShowCommentsDialog != null) _renderCommentsOverlay(shouldShowCommentsDialog)
              ],
            ),
          )
      )
    );
  }
}
