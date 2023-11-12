import 'package:contrast/common/widgets/banner.dart';
import 'package:contrast/common/widgets/data/data_view.dart';
import 'package:contrast/common/widgets/data/provider.dart';
import 'package:contrast/common/widgets/load.dart';
import 'package:contrast/common/widgets/video.dart';
import 'package:contrast/model/video_data.dart';
import 'package:contrast/modules/board/overlay/delete/provider.dart';
import 'package:contrast/modules/board/provider.dart';
import 'package:contrast/modules/board/video/overlay/provider.dart';
import 'package:contrast/modules/board/video/service.dart';
import 'package:contrast/security/session.dart';
import 'package:contrast/utils/device.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:parallax_animation/parallax_animation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Renders the video board page
class VideoBoardPage extends HookConsumerWidget {
  /// What happens when the user performs an action
  final Function(WidgetRef ref, Function? action) onUserAction;

  const VideoBoardPage({super.key, required this.onUserAction});

  /// Gets the asset for the data view header
  String _getDataViewHeader() {
    if(kIsWeb) {
      return 'video_web_banner.jpg';
    }

    return 'video_banner.gif';
  }

  /// Renders a video
  Widget _renderVideo(BuildContext context, WidgetRef ref, VideoData video, BoxConstraints constraints, bool isMobile) {
    if (Session().isLoggedIn()) {
      return FocusedMenuHolder(
          menuWidth: 300,
          blurSize: 5.0,
          menuItemExtent: 45,
          duration: const Duration(milliseconds: 100),
          animateMenuItems: true,
          blurBackgroundColor: Colors.black,
          openWithTap: false,
          onPressed: () => onUserAction(ref, () => Modular.to.pushNamed('videos/details?path=${video.path}&id=${video.id}')),
          menuItems: <FocusedMenuItem>[
            FocusedMenuItem(
                title: Text(FlutterI18n.translate(context, 'Edit Video')),
                trailingIcon: const Icon(Icons.edit),
                onPressed: () => onUserAction(ref, () {
                  ref.read(overlayVisibilityProvider(const Key('edit_video')).notifier).setOverlayVisibility(true);
                  ref.read(videoEditProvider.notifier).setEditVideo(video);
                })
            ),
            FocusedMenuItem(
                title: Text(FlutterI18n.translate(context, 'Delete Video')),
                trailingIcon: const Icon(Icons.delete),
                onPressed: () => onUserAction(ref, () {
                  ref.read(overlayVisibilityProvider(const Key('delete_video')).notifier).setOverlayVisibility(true);
                  ref.read(deleteVideoProvider.notifier).setDeleteVideo(video);
                })
            ),
          ],
          child: ContrastVideo(
              widgetKey: Key('${video.id}'),
              videoPath: video.path!,
              constraints: constraints,
              onClick: () => onUserAction(ref, () => Modular.to.pushNamed('videos/details?path=${video.path}&id=${video.id}')),
              disabled: true,
              onRedirect: kIsWeb ? () => onUserAction(ref, () async {
                final Uri url = Uri.parse('https://www.youtube.com/watch?v=${video.path}');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              }) : null
          )
      );
    }

    return ContrastVideo(
        widgetKey: Key('${video.id}'),
        videoPath: video.path!,
        constraints: constraints,
        parallax: (child) => ParallaxWidget(
            key: Key('${video.id}_video_parallax_widget'),
            overflowWidthFactor: 1.2,
            overflowHeightFactor: 1.1,
            fixedVertical: !isMobile,
            fixedHorizontal: isMobile,
            alignment: isMobile ? Alignment.topCenter : Alignment.centerLeft,
            background: child,
            child: const SizedBox(width: double.infinity, height: double.infinity,)
        ),
        onClick: () => onUserAction(ref, () => Modular.to.pushNamed('videos/details?path=${video.path}&id=${video.id}')),
        onRedirect: kIsWeb ? () => onUserAction(ref, () async {
          final Uri url = Uri.parse('https://www.youtube.com/watch?v=${video.path}');
          if (await canLaunchUrl(url)) {
            await launchUrl(url);
          }
        }) : null
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = useMobileLayoutOriented(context);

    return RestfulAnimatedDataView<VideoData>(
        key: const Key('VideoDataView'),
        serviceProvider: videoServiceFetchProvider,
        loadPage: ref.read(videoBoardServiceProvider).getVideoBoard,
        itemsPerRow: isMobile ? 3 : 2,
        axis: isMobile ? Axis.vertical : Axis.horizontal,
        dimHeight: MediaQuery.of(context).size.height / 2.5,
        itemBuilder: (BuildContext context, int index, int dataLength, VideoData wrapper) =>
            LayoutBuilder(key: const Key('VideoDataViewBuilder'), builder: (context, constraints) =>
                _renderVideo(context, ref, wrapper, constraints, isMobile)
            ),
        onLeftKeyPressed: () => ref.watch(boardFooterTabProvider.notifier).switchTab('photos'),
        whenShouldAnimateGlass: (controller) {
          final String currentTab = ref.watch(
              boardFooterTabProvider);
          useValueChanged(currentTab, (_, __) async {
            controller.reset();
            controller.forward();
          });
        },
        headerWidget: !kIsWeb ? () => BannerWidget(
          banners: [_getDataViewHeader()],
          quotes: [(FlutterI18n.translate(context, 'Videos'))],
        ) : null,
        listEmptyChild: const Center(
          child: LoadingIndicator(color: Colors.black),
        )
    );
  }
}
