import 'package:contrast/common/widgets/data/data_view.dart';
import 'package:contrast/common/widgets/data/provider.dart';
import 'package:contrast/common/widgets/photograph.dart';
import 'package:contrast/common/widgets/text.dart';
import 'package:contrast/model/image_data.dart';
import 'package:contrast/modules/board/overlay/delete/provider.dart';
import 'package:contrast/modules/board/photograph/overlay/provider.dart';
import 'package:contrast/modules/board/photograph/service.dart';
import 'package:contrast/modules/board/provider.dart';
import 'package:contrast/security/session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Renders the photographs board page
class PhotographBoardPage extends HookConsumerWidget {

  const PhotographBoardPage({super.key});

  /// Renders a photograph
  Widget _renderPhoto(WidgetRef ref, BuildContext context, ImageWrapper wrapper, BoxConstraints constraints) {
    final String selectedFilter = ref.read(boardHeaderTabProvider);
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
          onPressed: () => Modular.to.pushNamed('photos/details?id=${wrapper.image.id}&category=$selectedFilter'),
          menuItems: <FocusedMenuItem>[
            FocusedMenuItem(
                title: const Text("Edit Photograph"),
                trailingIcon: const Icon(Icons.edit),
                onPressed: () {
                  ref.read(overlayVisibilityProvider(const Key('edit_image')).notifier).setOverlayVisibility(true);
                  ref.read(photographEditProvider.notifier).setEditImage(wrapper.image);
                }),
            FocusedMenuItem(
                title: const Text("Delete Photograph"),
                trailingIcon: const Icon(Icons.delete),
                onPressed: () {
                  ref.read(overlayVisibilityProvider(const Key('delete_image')).notifier).setOverlayVisibility(true);
                  ref.read(deleteImageProvider.notifier).setDeleteImage(wrapper.image);
                }
            ),
          ],
          child: ContrastPhotograph(
            widgetKey: Key('${wrapper.image.id}'),
            quality: FilterQuality.high,
            borderColor: Colors.black,
            fetch: (path) => serviceProvider.getCompressedPhotograph(context, path, false),
            image: wrapper.image,
          )
      );
    }

    return ContrastPhotographMeta(
        widgetKey: Key('${wrapper.image.id}'),
        fetch: (path) => serviceProvider.getCompressedPhotograph(context, path, false),
        wrapper: wrapper,
        constraints: constraints,
        onClick: () => Modular.to.pushNamed('photos/details?id=${wrapper.image.id}&category=$selectedFilter'),
        onRedirect: kIsWeb ? () async {
          final Uri url = Uri.parse('https://www.dstefomir.eu/#/photos/details?id=${wrapper.image.id}&category=$selectedFilter');
          if (await canLaunchUrl(url)) {
            await launchUrl(url);
          }
        } : null
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => RestfulAnimatedDataView<ImageWrapper>(
      serviceProvider: photographServiceFetchProvider,
      loadPage: ref.read(photographyBoardServiceProvider).getImageBoard,
      itemsPerRow: 3,
      dimHeight: MediaQuery.of(context).size.height / 2.5,
      itemBuilder: (BuildContext context, int index, int dataLength, ImageWrapper wrapper) =>
          LayoutBuilder(builder: (context, constraints) =>
              _renderPhoto(ref, context, wrapper, constraints)
          ),
      onRightKeyPressed: () => ref.watch(boardFooterTabProvider.notifier).switchTab('videos'),
      listEmptyChild: const Center(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: StyledText(
            text: 'Nothing here so far',
            color: Colors.black,
          ),
        ),
      )
  );
}
