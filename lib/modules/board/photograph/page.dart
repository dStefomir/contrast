import 'package:contrast/common/widgets/banner.dart';
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

  /// Gets an asset based on the selected photograph category
  List<String> getRestfulViewHeader(WidgetRef ref) {
    final String selectedFilter = ref.read(boardHeaderTabProvider);

    switch(selectedFilter) {
      case 'all':
        return ['landscape_banner.jpg', 'portrait_banner.jpg', 'street_banner.jpg', 'other_banner.jpg'];
      case 'landscape':
        return ['landscape_banner.jpg'];
      case 'portraits':
        return ['portrait_banner.jpg'];
      case 'street':
        return ['street_banner.jpg'];
      case 'other':
        return ['other_banner.jpg'];
    }

    return [];
  }

  /// Gets the text for the restful view header
  List<String> getRestfulViewHeaderText(BuildContext context, WidgetRef ref) {
    final String selectedFilter = ref.read(boardHeaderTabProvider);

    switch(selectedFilter) {
      case 'all':
        return [
          FlutterI18n.translate(context, 'Landscape'),
          FlutterI18n.translate(context, 'Portraits'),
          FlutterI18n.translate(context, 'Street'),
          FlutterI18n.translate(context, 'Other')
        ];
      case 'landscape':
        return [
          FlutterI18n.translate(context, 'Landscape')
        ];
      case 'portraits':
        return [
          FlutterI18n.translate(context, 'Portraits')
        ];
      case 'street':
        return [
          FlutterI18n.translate(context, 'Street')
        ];
      case 'other':
        return [
          FlutterI18n.translate(context, 'Other')
        ];
    }

    return [];
  }

  /// Renders a photograph
  Widget _renderPhoto(WidgetRef ref, BuildContext context, ImageBoardWrapper wrapper, BoxConstraints constraints, bool isMobile) {
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

    return ContrastPhotographMeta(
        widgetKey: Key('${wrapper.image.id}'),
        fetch: (path) => serviceProvider.getCompressedPhotograph(context, path, false),
        parallax: (child) => ParallaxWidget(
            key: Key('${wrapper.image.id}_photo_parallax_widget'),
            overflowWidthFactor: 1.2,
            overflowHeightFactor: 1.2,
            fixedVertical: !isMobile,
            fixedHorizontal: isMobile,
            alignment: isMobile ? Alignment.topCenter : Alignment.centerLeft,
            background: child,
            child: const SizedBox(width: double.infinity, height: double.infinity,)
        ),
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
    final isMobile = useMobileLayoutOriented(context);

    return RestfulAnimatedDataView<ImageBoardWrapper>(
        key: const Key('PhotographDataView'),
        serviceProvider: photographServiceFetchProvider,
        loadPage: ref.read(photographyBoardServiceProvider).getImageBoard,
        itemsPerRow: isMobile ? 3 : kIsWeb ? 3 : 1,
        axis: isMobile ? Axis.vertical : Axis.horizontal,
        dimHeight: MediaQuery.of(context).size.height / 2.5,
        itemBuilder: (BuildContext context, int index, int dataLength, ImageBoardWrapper wrapper) =>
            LayoutBuilder(
                key: const Key('PhotographDataViewBuilder'),
                builder: (context, constraints) => _renderPhoto(ref, context, wrapper, constraints, isMobile)
            ),
        onRightKeyPressed: () => ref.watch(boardFooterTabProvider.notifier).switchTab('videos'),
        whenShouldAnimateGlass: (controller) {
          final String currentTab = ref.watch(boardFooterTabProvider);
          useValueChanged(currentTab, (_, __) async {
            controller.reset();
            controller.forward();
          });
        },
        headerWidget: !kIsWeb ? () => BannerWidget(
            banners: getRestfulViewHeader(ref),
            quotes: getRestfulViewHeaderText(context, ref),
        ) : null,
        listEmptyChild: const Center(
          child: LoadingIndicator(color: Colors.black),
        )
    );
  }
}
