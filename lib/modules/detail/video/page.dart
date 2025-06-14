import 'dart:convert';
import 'dart:io';

import 'package:contrast/common/widgets/animation.dart';
import 'package:contrast/common/widgets/blur.dart';
import 'package:contrast/common/widgets/button.dart';
import 'package:contrast/common/widgets/page.dart';
import 'package:contrast/common/widgets/text.dart';
import 'package:contrast/model/video_comments.dart';
import 'package:contrast/modules/board/provider.dart';
import 'package:contrast/modules/detail/overlay/comment.dart';
import 'package:contrast/modules/detail/overlay/provider.dart';
import 'package:contrast/modules/detail/overlay/service.dart';
import 'package:contrast/security/session.dart';
import 'package:contrast/utils/date.dart';
import 'package:contrast/utils/overlay.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
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
  ConsumerState createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends ConsumerState<VideoDetailPage> {
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
          parameters: <String, String>{
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
  }

  @override
  void dispose() {
    _controller.close();
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
          onClick: () async {
            await _controller.pauseVideo();
            ref.read(overlayVisibilityProvider(commentKey).notifier).setOverlayVisibility(true);
          },
          color: Colors.white,
          borderColor: Colors.black,
          tooltip: 'Comments'.tr(),
          icon: 'comment.svg'
      );

  /// Renders the share button
  Widget _renderShareButton() =>
      DefaultButton(
          onClick: () async {
            await _controller.pauseVideo();
            ref.read(overlayVisibilityProvider(commentKey).notifier).setOverlayVisibility(null);
            Clipboard.setData(
                ClipboardData(text: 'https://www.youtube.com/watch?v=${widget.path}')
            ).then((value) => showSuccessTextOnSnackBar(
                context.mounted
                    ? context
                    : null,
                'Copied to clipboard'.tr()
            ));},
          color: Colors.white,
          tooltip: 'Share'.tr(),
          borderColor: Colors.black,
          icon: 'share.svg'
      );

  /// Renders the back button
  Widget _renderBackButton(BuildContext context) =>
      DefaultButton(
          onClick: () {
            ref.read(overlayVisibilityProvider(commentKey).notifier).setOverlayVisibility(null);
            Modular.to.navigate('/');
            },
          color: Colors.white,
          tooltip: 'Close'.tr(),
          borderColor: Colors.black,
          icon: 'close.svg'
      );

  /// Render video details page actions
  List<Widget> _renderActions() => [
    Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: _renderBackButton(context),
    ),
    Padding(
      padding: const EdgeInsets.only(top: 5.0,),
      child: _renderShareButton(),
    ),
    if (!kIsWeb || Session().isLoggedIn()) Padding(
      padding: const EdgeInsets.only(top: 5.0,),
      child: _renderCommentsButton(),
    ),
  ];

  /// Renders the comment overlay
  Widget _renderCommentsOverlay(bool? shouldShowCommentsDialog) => Align(
    alignment: Alignment.bottomCenter,
    child: SlideTransitionAnimation(
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
              padding: const EdgeInsets.only(top: 25, left: 25, right: 25),
              child: Row(
                children: [
                  Container(
                    width: 5.0,
                    height: 5.0,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Column(
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
                              const SizedBox(width: 5),
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
                              if (Session().isLoggedIn() && !item.approved!) DefaultButton(
                                  padding: 0,
                                  height: 25,
                                  onClick: () => ref.read(commentsServiceProvider).approveVideoComment(item.id!).then((value) {
                                    ref.read(videoCommentsDataViewProvider.notifier).updateItem(item, value);
                                    showSuccessTextOnSnackBar(
                                        context.mounted
                                            ? context
                                            : null,
                                        'Comment approved'.tr()
                                    );
                                  }),
                                  tooltip: 'Approve comment'.tr(),
                                  color: Colors.white.withValues(alpha: 0.3),
                                  borderColor: Colors.white,
                                  icon: 'check.svg'
                              ),
                              if (Session().isLoggedIn() && !item.approved!) const SizedBox(width: 20),
                              if (deviceId == item.deviceId || Session().isLoggedIn()) DefaultButton(
                                  padding: 0,
                                  height: 25,
                                  onClick: () => Session().isLoggedIn() ?
                                  ref.read(commentsServiceProvider).deleteVideoCommentAsAdmin(item.id!).then((value) {
                                    ref.read(videoCommentsDataViewProvider.notifier).removeItem(index);
                                    showSuccessTextOnSnackBar(
                                        context.mounted
                                            ? context
                                            : null,
                                        'Comment deleted'.tr()
                                    );
                                  }) :
                                  ref.read(commentsServiceProvider).deleteVideoComment(item.id!, deviceId!).then((value) {
                                    ref.read(videoCommentsDataViewProvider.notifier).removeItem(index);
                                    showSuccessTextOnSnackBar(
                                        context.mounted
                                            ? context
                                            : null,
                                        'Comment deleted'.tr()
                                    );
                                  }),
                                  tooltip: 'Delete comment'.tr(),
                                  color: Colors.white.withValues(alpha: 0.3),
                                  borderColor: Colors.black,
                                  icon: 'delete.svg'
                              )
                            ],),
                          Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 5),
                            child: StyledText(
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

    return KeyboardListener(
      autofocus: true,
      focusNode: useFocusNode(),
      onKeyEvent: (event) {
        if (event is KeyUpEvent && event.logicalKey == LogicalKeyboardKey.escape) {
          closeOverlayIfOpened(ref, 'comment_video');
          Modular.to.navigate('/');
        }
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (_, __) {
          final isCommentOpen = ref.read(overlayVisibilityProvider(const Key('comment_video')));
          if(isCommentOpen != null && isCommentOpen) {
            closeOverlayIfOpened(ref, 'comment_video');
          } else if (!kIsWeb && Platform.isAndroid) {
            Modular.to.navigate('/');
          }
        },
        child: GestureDetector(
          onTap: () => closeOverlayIfOpened(ref, 'comment_video'),
          child: BackgroundPage(
              color: Colors.black,
              child: OrientationBuilder(
                builder: (BuildContext context, Orientation orientation) => Stack(
                  alignment: Alignment.center,
                  children: [
                    if (!shouldHideOverlay(shouldShowCommentsDialog)) Padding(
                      padding: EdgeInsets.only(top: kIsWeb && orientation == Orientation.landscape ? 60 : 0),
                      child: YoutubePlayerScaffold(
                          key: const Key('VideoDetailsYoutubeScaffold'),
                          aspectRatio: 16 / 9,
                          backgroundColor: Colors.transparent,
                          controller: _controller,
                          builder: (context, player) => player
                      ),
                    ),
                    if (!(!kIsWeb && orientation == Orientation.landscape)) Align(
                        alignment: Alignment.topLeft,
                        child: Row(children: _renderActions())
                    ),
                    if((!kIsWeb || Session().isLoggedIn()) && shouldShowCommentsDialog != null && shouldShowCommentsDialog) const Blurrable(strength: 10),
                    if ((!kIsWeb || Session().isLoggedIn()) && shouldShowCommentsDialog != null) _renderCommentsOverlay(shouldShowCommentsDialog)
                  ],
                ),
              )
          ),
        ),
      )
    );
  }
}
