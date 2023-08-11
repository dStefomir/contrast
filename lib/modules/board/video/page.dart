import 'package:contrast/common/widgets/data/data_view.dart';
import 'package:contrast/common/widgets/data/provider.dart';
import 'package:contrast/common/widgets/photograph.dart';
import 'package:contrast/common/widgets/text.dart';
import 'package:contrast/common/widgets/video.dart';
import 'package:contrast/model/image_data.dart';
import 'package:contrast/model/video_data.dart';
import 'package:contrast/modules/board/overlay/delete/provider.dart';
import 'package:contrast/modules/board/photograph/service.dart';
import 'package:contrast/modules/board/provider.dart';
import 'package:contrast/modules/board/video/overlay/provider.dart';
import 'package:contrast/modules/board/video/service.dart';
import 'package:contrast/security/session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Renders the video board page
class VideoBoardPage extends HookConsumerWidget {
  /// What happens when the user performs an action
  final Function(WidgetRef ref, Function? action) onUserAction;

  const VideoBoardPage({super.key, required this.onUserAction});

  /// Renders a video
  Widget _renderVideo(BuildContext context, WidgetRef ref, VideoData video, BoxConstraints constraints) {
    final serviceProvider = ref.read(photographyBoardServiceProvider);

    if (Session().isLoggedIn()) {
      return FocusedMenuHolder(
          menuWidth: 300,
          blurSize: 5.0,
          menuItemExtent: 45,
          duration: const Duration(milliseconds: 100),
          animateMenuItems: true,
          blurBackgroundColor: Colors.black,
          openWithTap: false,
          onPressed: () => onUserAction(ref, () => Modular.to.pushNamed('videos/details/${video.path}')),
          menuItems: <FocusedMenuItem>[
            FocusedMenuItem(
                title: const Text("Edit Video"),
                trailingIcon: const Icon(Icons.edit),
                onPressed: () => onUserAction(ref, () {
                  ref.read(overlayVisibilityProvider(const Key('edit_video')).notifier).setOverlayVisibility(true);
                  ref.read(videoEditProvider.notifier).setEditVideo(video);
                })
            ),
            FocusedMenuItem(
                title: const Text("Delete Video"),
                trailingIcon: const Icon(Icons.delete),
                onPressed: () => onUserAction(ref, () {
                  ref.read(overlayVisibilityProvider(const Key('delete_video')).notifier).setOverlayVisibility(true);
                  ref.read(deleteVideoProvider.notifier).setDeleteVideo(video);
                })
            ),
          ],
          child: ContrastPhotograph(
            widgetKey: Key('${video.id}'),
            image: ImageData(path: video.path),
            fetch: (path) => serviceProvider.getCompressedPhotograph(context, path, true),
            quality: FilterQuality.high,
            borderColor: Colors.black,
            compressed: false,
            isThumbnail: true,
            height: double.infinity,
          )
      );
    }

    return ContrastVideo(
        widgetKey: Key('${video.id}'),
        videoPath: video.path!,
        constraints: constraints,
        onClick: () => onUserAction(ref, () => Modular.to.pushNamed('videos/details/${video.path}')),
        onRedirect: kIsWeb ? () => onUserAction(ref, () async {
          final Uri url = Uri.parse('https://www.dstefomir.eu/#/videos/details/${video.path}');
          if (await canLaunchUrl(url)) {
            await launchUrl(url);
          }
        }) : null
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => RestfulAnimatedDataView<VideoData>(
      serviceProvider: videoServiceFetchProvider,
      loadPage: ref.read(videoBoardServiceProvider).getVideoBoard,
      itemsPerRow: 3,
      dimHeight: MediaQuery.of(context).size.height / 2.5,
      itemBuilder: (BuildContext context, int index, int dataLength, VideoData wrapper) => LayoutBuilder(builder: (context, constraints) =>
          _renderVideo(context, ref, wrapper, constraints)
      ),
      onLeftKeyPressed: () => ref.watch(boardFooterTabProvider.notifier).switchTab('photos'),
      listEmptyChild: const Padding(
        padding: EdgeInsets.all(15),
        child: StyledText(
          text: 'Nothing here so far',
          color: Colors.black,
        ),
      )
  );
}
