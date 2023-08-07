import 'package:contrast/common/widgets/data/data_view.dart';
import 'package:contrast/common/widgets/data/provider.dart';
import 'package:contrast/common/widgets/photograph.dart';
import 'package:contrast/common/widgets/snack.dart';
import 'package:contrast/common/widgets/text.dart';
import 'package:contrast/common/widgets/video.dart';
import 'package:contrast/model/image_data.dart';
import 'package:contrast/model/video_data.dart';
import 'package:contrast/modules/board/overlay/delete/delete.dart';
import 'package:contrast/modules/board/photograph/service.dart';
import 'package:contrast/modules/board/provider.dart';
import 'package:contrast/modules/board/video/overlay/upload.dart';
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

  const VideoBoardPage({super.key});

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
          onPressed: () => Modular.to.pushNamed('videos/details/${video.path}'),
          menuItems: <FocusedMenuItem>[
            FocusedMenuItem(
                title: const Text("Edit Video"),
                trailingIcon: const Icon(Icons.edit),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) => UploadVideoDialog(
                        data: video,
                      )).then((value) {
                        if(value != null) {
                          ref.read(videoServiceFetchProvider.notifier).updateItem(video, value);
                          showSuccessTextOnSnackBar(context, "Video was successfully edited.");
                        }
                      });
                }
            ),
            FocusedMenuItem(
                title: const Text("Delete Video"),
                trailingIcon: const Icon(Icons.delete),
                onPressed: () => showDialog(
                    context: context,
                    builder: (context) => DeleteDialog<VideoData>(data: video,)
                ).then((value) {
                  if(value != null) {
                    ref.read(videoServiceFetchProvider.notifier).removeItem(video);
                    showSuccessTextOnSnackBar(context, "Video was successfully deleted.");
                  }
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
        onClick: () => Modular.to.pushNamed('videos/details/${video.path}'),
        onRedirect: kIsWeb ? () async {
          final Uri url = Uri.parse('https://www.dstefomir.eu/#/videos/details/${video.path}');
          if (await canLaunchUrl(url)) {
            await launchUrl(url);
          }
        } : null
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => RestfulAnimatedDataView<VideoData>(
      serviceProvider: videoServiceFetchProvider,
      loadPage: ref.read(videoBoardServiceProvider).getVideoBoard,
      itemsPerRow: 3,
      dimHeight: MediaQuery.of(context).size.height / 2,
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
