import 'package:contrast/common/widgets/data/data_view.dart';
import 'package:contrast/common/widgets/data/provider.dart';
import 'package:contrast/common/widgets/load.dart';
import 'package:contrast/common/widgets/photograph.dart';
import 'package:contrast/model/image_data.dart';
import 'package:contrast/modules/board/overlay/delete/provider.dart';
import 'package:contrast/modules/board/photograph/overlay/provider.dart';
import 'package:contrast/modules/board/photograph/service.dart';
import 'package:contrast/modules/board/provider.dart';
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

/// Renders the photographs board page
class PhotographBoardPage extends HookConsumerWidget {
  /// What happens when the user performs an action
  final Function(WidgetRef ref, Function? action) onUserAction;

  const PhotographBoardPage({super.key, required this.onUserAction});

  /// Calculates the number of items per row for the grid view
  int _calculateRestfulViewItemsPerRows(BuildContext context) {
    final isMobile = useMobileLayout(context);
    final isMobilePortrait = useMobileLayoutOriented(context);

    if (kIsWeb) {

      return 3;
    }
    if (isMobilePortrait) {

      return 3;
    } else if (isMobile){

      return 1;
    } else {

      return 3;
    }
  }

  /// Gets an axis for the restful view
  Axis _getRestfulViewAxis(BuildContext context, Orientation currentOrientation) {
    if (currentOrientation == Orientation.landscape) {

      return Axis.horizontal;
    }

    return Axis.vertical;
  }

  /// Renders a photograph
  Widget _renderPhoto(WidgetRef ref, BuildContext context, ImageBoardWrapper wrapper, BoxConstraints constraints, Orientation currentOrientation) {
    final serviceProvider = ref.read(photographyBoardServiceProvider);
    final currentCategory = ref.read(boardHeaderTabProvider);

    if (Session().isLoggedIn()) {
      return FocusedMenuHolder(
          menuWidth: 300,
          blurSize: 5.0,
          menuItemExtent: 45,
          duration: const Duration(milliseconds: 100),
          animateMenuItems: true,
          blurBackgroundColor: Colors.black,
          openWithTap: false,
          onPressed: () => onUserAction(ref, () => Modular.to.pushNamed('photos/details?id=${wrapper.image.id}&category=$currentCategory')),
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
    final isMobile = currentOrientation == Orientation.portrait;

    return ContrastPhotographMeta(
        widgetKey: Key('${wrapper.image.id}'),
        fetch: (path) => serviceProvider.getCompressedPhotograph(context, path, false),
        parallax: !kIsWeb ? (child) => ParallaxWidget(
            key: Key('${wrapper.image.id}_photo_parallax_widget'),
            overflowWidthFactor: 1.27,
            overflowHeightFactor: 1.27,
            fixedVertical: !isMobile,
            fixedHorizontal: isMobile,
            alignment: isMobile ? Alignment.center : Alignment.centerLeft,
            background: child,
            child: const SizedBox(width: double.infinity, height: double.infinity,)
        ) : null,
        wrapper: wrapper,
        constraints: constraints,
        borderColor: Colors.transparent,
        onClick: () => onUserAction(ref, () => Modular.to.pushNamed('photos/details?id=${wrapper.image.id}&category=$currentCategory')),
        onRedirect: kIsWeb ? () => onUserAction(ref, () async {
          final Uri url = Uri.parse('https://www.dstefomir.eu/#/photos/details?id=${wrapper.image.id}&category=$currentCategory');
          if (await canLaunchUrl(url)) {
            await launchUrl(url);
          }
        }) : null
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orientation = MediaQuery.of(context).orientation;

    return RestfulAnimatedDataView<ImageBoardWrapper>(
        key: const Key('PhotographDataView'),
        serviceProvider: photographServiceFetchProvider,
        loadPage: ref.read(photographyBoardServiceProvider).getImageBoard,
        itemsPerRow: _calculateRestfulViewItemsPerRows(context),
        axis: _getRestfulViewAxis(context, orientation),
        dimHeight: MediaQuery.of(context).size.height / 2.5,
        itemBuilder: (BuildContext context, int index, int dataLength, ImageBoardWrapper wrapper) =>
            LayoutBuilder(
                key: const Key('PhotographDataViewBuilder'),
                builder: (context, constraints) => _renderPhoto(ref, context, wrapper, constraints, orientation)
            ),
        onRightKeyPressed: () => ref.watch(boardFooterTabProvider.notifier).switchTab('videos'),
        whenShouldAnimateGlass: (controller) {
          final String currentTab = ref.watch(boardFooterTabProvider);
          useValueChanged(currentTab, (_, __) async {
            controller.reset();
            controller.forward();
          });
        },
        listEmptyChild: const Center(
          child: LoadingIndicator(color: Colors.black),
        )
    );
  }
}
