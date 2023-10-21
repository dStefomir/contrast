import 'package:contrast/common/widgets/animation.dart';
import 'package:contrast/common/widgets/data/data_view.dart';
import 'package:contrast/common/widgets/data/provider.dart';
import 'package:contrast/common/widgets/icon.dart';
import 'package:contrast/common/widgets/load.dart';
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
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Renders the photographs board page
class PhotographBoardPage extends HookConsumerWidget {
  /// What happens when the user performs an action
  final Function(WidgetRef ref, Function? action) onUserAction;

  const PhotographBoardPage({super.key, required this.onUserAction});

  /// Gets an asset based on the selected photograph category
  String? getRestfulViewHeader(WidgetRef ref) {
    final String selectedFilter = ref.read(boardHeaderTabProvider);

    switch(selectedFilter) {
      case 'all':
        return 'all_banner.jpg';
      case 'landscape':
        return 'landscape_banner.jpg';
      case 'portraits':
        return 'portrait_banner.jpg';
      case 'street':
        return 'street_banner.jpg';
      case 'other':
        return 'other_banner.jpg';
    }

    return null;
  }

  /// Gets the text for the restful view header
  String? getRestfulViewHeaderText(BuildContext context, WidgetRef ref) {
    final String selectedFilter = ref.read(boardHeaderTabProvider);

    switch(selectedFilter) {
      case 'all':
        return FlutterI18n.translate(context, 'Don’t shoot what it looks like. Shoot what it feels like');
      case 'landscape':
        return FlutterI18n.translate(context, 'The real voyage of discovery consists not in seeking new landscapes, but in having new eyes');
      case 'portraits':
        return FlutterI18n.translate(context, 'The countenance is the portrait of the soul, and the eyes mark its intentions');
      case 'street':
        return FlutterI18n.translate(context, 'Street Photography is like fishing. Catching the fish is more exciting than eating it');
      case 'other':
        return FlutterI18n.translate(context, 'Until one has loved an animal, a part of one’s soul remains unawakened');
    }

    return null;
  }

  /// Renders a photograph
  Widget _renderPhoto(WidgetRef ref, BuildContext context, ImageBoardWrapper wrapper, BoxConstraints constraints) {
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
          onPressed: () => onUserAction(ref, () => Modular.to.pushNamed('photos/details?id=${wrapper.image.id}&category=$selectedFilter')),
          menuItems: <FocusedMenuItem>[
            FocusedMenuItem(
                title: Text(FlutterI18n.translate(context, 'Edit Photograph')),
                trailingIcon: const Icon(Icons.edit),
                onPressed: () => onUserAction(ref, () {
                  ref.read(overlayVisibilityProvider(const Key('edit_image')).notifier).setOverlayVisibility(true);
                  ref.read(photographEditProvider.notifier).setEditImage(wrapper.image);
                })),
            FocusedMenuItem(
                title: Text(FlutterI18n.translate(context, 'Delete Photograph')),
                trailingIcon: const Icon(Icons.delete),
                onPressed: () => onUserAction(ref, () {
                  ref.read(overlayVisibilityProvider(const Key('delete_image')).notifier).setOverlayVisibility(true);
                  ref.read(deleteImageProvider.notifier).setDeleteImage(wrapper.image);
                })
            ),
          ],
          child: ContrastPhotograph(
            widgetKey: Key('${wrapper.image.id}'),
            quality: FilterQuality.high,
            borderColor: Colors.black,
            fetch: (path) => serviceProvider.getCompressedPhotograph(context, path, false),
            constraints: constraints,
            image: wrapper.image,
          )
      );
    }

    return ContrastPhotographMeta(
        widgetKey: Key('${wrapper.image.id}'),
        fetch: (path) => serviceProvider.getCompressedPhotograph(context, path, false),
        wrapper: wrapper,
        constraints: constraints,
        onClick: () => onUserAction(ref, () => Modular.to.pushNamed('photos/details?id=${wrapper.image.id}&category=$selectedFilter')),
        onRedirect: kIsWeb ? () => onUserAction(ref, () async {
          final Uri url = Uri.parse('https://www.dstefomir.eu/#/photos/details?id=${wrapper.image.id}&category=$selectedFilter');
          if (await canLaunchUrl(url)) {
            await launchUrl(url);
          }
        }) : null
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => RestfulAnimatedDataView<ImageBoardWrapper>(
      key: const Key('PhotographDataView'),
      serviceProvider: photographServiceFetchProvider,
      loadPage: ref.read(photographyBoardServiceProvider).getImageBoard,
      itemsPerRow: 3,
      dimHeight: MediaQuery.of(context).size.height / 2.5,
      itemBuilder: (BuildContext context, int index, int dataLength, ImageBoardWrapper wrapper) =>
          LayoutBuilder(key: const Key('PhotographDataViewBuilder'), builder: (context, constraints) =>
              _renderPhoto(ref, context, wrapper, constraints)
          ),
      onRightKeyPressed: () => ref.watch(boardFooterTabProvider.notifier).switchTab('videos'),
      whenShouldAnimateGlass: (controller) {
        final String currentTab = ref.watch(boardFooterTabProvider);
        useValueChanged(currentTab, (_, __) async {
          controller.reset();
          controller.forward();
        });
      },
      headerWidget: (longestSize, isMobile) => Stack(
        fit: StackFit.expand,
        children: [
          IconRenderer(asset: getRestfulViewHeader(ref)!, fit: BoxFit.cover),
          Align(
              alignment: Alignment.bottomLeft,
              child: SizedBox(
                width: longestSize / 2,
                child: FadeAnimation(
                  start: 0,
                  end: 1,
                  duration: const Duration(milliseconds: 2000),
                  child: StyledText(
                    text: '"${getRestfulViewHeaderText(context, ref)!}"',
                    color: Colors.white,
                    useShadow: true,
                    align: TextAlign.start,
                    letterSpacing: 5,
                    fontSize: longestSize / 50,
                    italic: true,
                    clip: false,
                  ),
                ),
              )
          ),
        ],
      ),
      listEmptyChild: const Center(
        child: LoadingIndicator(color: Colors.black),
      )
  );
}
