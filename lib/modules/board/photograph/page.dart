// import 'dart:html' as html;

import 'package:contrast/common/widgets/data/data_view.dart';
import 'package:contrast/common/widgets/data/provider.dart';
import 'package:contrast/common/widgets/photograph.dart';
import 'package:contrast/common/widgets/snack.dart';
import 'package:contrast/common/widgets/text.dart';
import 'package:contrast/model/image_data.dart';
import 'package:contrast/modules/board/overlay/delete.dart';
import 'package:contrast/modules/board/photograph/overlay/upload.dart';
import 'package:contrast/modules/board/photograph/service.dart';
import 'package:contrast/modules/board/provider.dart';
import 'package:contrast/security/session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Renders the photographs board page
class PhotographBoardPage extends HookConsumerWidget {
  /// Constraints of the page
  final BoxConstraints constraints;

  const PhotographBoardPage({required this.constraints, super.key});

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
                  showDialog(
                      context: context,
                      builder: (context) => UploadImageDialog(
                          constraints: constraints,
                          data: wrapper.image
                      )
                  ).then((photograph) {
                    if(photograph != null) {
                      final ImageWrapper updatedPhotograph = ImageWrapper(image: photograph, metadata: wrapper.metadata);
                      ref.read(photographServiceFetchProvider.notifier).updateItem(wrapper, updatedPhotograph);
                      showSuccessTextOnSnackBar(context, "Photograph was successfully edited.");
                    }
                  });
                }),
            FocusedMenuItem(
                title: const Text("Delete Photograph"),
                trailingIcon: const Icon(Icons.delete),
                onPressed: () =>
                  showDialog(
                      context: context,
                      builder: (context) => DeleteDialog<ImageData>(data: wrapper.image)
                  ).then((photograph) {
                    if(photograph != null) {
                      ref.read(photographServiceFetchProvider.notifier).removeItem(wrapper);
                      showSuccessTextOnSnackBar(context, "Photograph was successfully deleted.");
                    }
                  })
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
      // onRedirect: () => html.window.open(
      //     'https://www.dstefomir.eu/#/photos/details?id=${wrapper.image.id}&category=$selectedFilter',
      //     '${wrapper.image.id}'
      // )
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => RestfulAnimatedDataView<ImageWrapper>(
      serviceProvider: photographServiceFetchProvider,
      loadPage: ref.read(photographyBoardServiceProvider).getImageBoard,
      itemsPerRow: 3,
      constraints: constraints,
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
