import 'package:contrast/common/widgets/data/data_view.dart';
import 'package:contrast/common/widgets/data/provider.dart';
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
import 'package:flutter_modular/flutter_modular.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hyper_effects/hyper_effects.dart';
import 'package:flutter_translate/flutter_translate.dart' as translation;

/// Renders the photographs board page
class PhotographBoardPage extends HookConsumerWidget {
  /// Current orientation
  final Orientation orientation;
  /// What happens when the user performs an action
  final Function(WidgetRef ref, Function? action) onUserAction;
  /// Padding of the data view items
  final double padding;

  const PhotographBoardPage({super.key, required this.orientation, required this.onUserAction, required this.padding});

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
  Widget _renderPhoto(WidgetRef ref, BuildContext context, ImageBoardWrapper wrapper, BoxConstraints constraints, Orientation currentOrientation, bool isLeft, bool isRight) {
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
                title: Text(translation.translate('Edit Photograph')),
                trailingIcon: const Icon(Icons.edit),
                onPressed: () => onUserAction(ref, () {
                  ref.read(overlayVisibilityProvider(const Key('edit_image')).notifier).setOverlayVisibility(true);
                  ref.read(photographEditProvider.notifier).setEditImage(wrapper.image);
                })),
            FocusedMenuItem(
                title: Text(translation.translate('Delete Photograph')),
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
        borderColor: Colors.black,
        onClick: () => onUserAction(ref, () => Modular.to.pushNamed('photos/details?id=${wrapper.image.id}&category=$currentCategory')),
    ).scrollTransition(
          (context, widget, event) => widget
              .scaleOut(start: 0.9, end: 1)
              .animate(trigger: event.screenOffsetFraction > 1, startImmediately: true)
              .blur(
            switch (event.phase) {
              ScrollPhase.identity => 0,
              ScrollPhase.topLeading => 5,
              ScrollPhase.bottomTrailing => 5,
            },
      ).scale(
        switch (event.phase) {
          ScrollPhase.identity => 1,
          ScrollPhase.topLeading => 0.5,
          ScrollPhase.bottomTrailing => 0.5,
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => RestfulAnimatedDataView<ImageBoardWrapper>(
    key: const Key('PhotographDataView'),
    serviceProvider: photographServiceFetchProvider,
    loadPage: ref.read(photographyBoardServiceProvider).getImageBoard,
    itemsPerRow: _calculateRestfulViewItemsPerRows(context),
    axis: _getRestfulViewAxis(context, orientation),
    padding: _getRestfulViewAxis(context, orientation) == Axis.horizontal
        ? const EdgeInsets.only(left: 0)
        : EdgeInsets.only(left: padding),
    itemBuilder: (BuildContext context, int index, int dataLength, ImageBoardWrapper wrapper, bool isLeft, bool isRight) =>
        LayoutBuilder(
            key: const Key('PhotographDataViewBuilder'),
            builder: (context, constraints) => _renderPhoto(ref, context, wrapper, constraints, orientation, isLeft, isRight)
        ),
  );
}
