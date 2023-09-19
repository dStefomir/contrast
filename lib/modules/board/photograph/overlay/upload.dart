import 'package:contrast/common/extentions/zoom.dart';
import 'package:contrast/common/widgets/button.dart';
import 'package:contrast/common/widgets/hover_provider.dart';
import 'package:contrast/common/widgets/input.dart';
import 'package:contrast/common/widgets/load.dart';
import 'package:contrast/common/widgets/shadow.dart';
import 'package:contrast/common/widgets/text.dart';
import 'package:contrast/common/widgets/tooltip.dart';
import 'package:contrast/model/image_data.dart';
import 'package:contrast/model/image_meta_data.dart';
import 'package:contrast/modules/board/photograph/overlay/provider.dart';
import 'package:contrast/modules/board/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'dart:io';

import '../../../../../common/widgets/icon.dart';

/// Dialog height
const double dialogHeight = 450;

/// Renders the upload image dialog
class UploadImageDialog extends HookConsumerWidget {
  /// Existing image data
  final ImageData? data;
  /// Function which updates the board
  final void Function(ImageBoardWrapper) onSubmit;
  /// Form key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  UploadImageDialog({Key? key, this.data, required this.onSubmit}) : super(key: key);

  /// Selects a photo for uploading from the storage of the device
  void _selectPhotograph(WidgetRef ref) async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'JPG']
    );
    if (result != null) {
      final PlatformFile pickedFile = result.files.single;

      File file;
      Size imageSize;
      Uint8List data;

      /// If its not web use the file system
      if (!kIsWeb) {
        file = File(pickedFile.path!);
        data = await file.readAsBytes();
        final input = FileInput(file);
        imageSize = ImageSizeGetter.getSize(input);
        /// If its web use memory file
      } else {
        imageSize = ImageSizeGetter.getSize(MemoryInput(pickedFile.bytes!));
        data = pickedFile.bytes!;
      }
      final String fileName = pickedFile.name;
      bool isLandscape = false;
      bool isRect = false;
      if (imageSize.width > imageSize.height) {
        isLandscape = true;
      }
      if (imageSize.width == imageSize.height) {
        isRect = true;
      }

      ref.read(fileProvider.notifier).setData(data, fileName, isLandscape, isRect);
    }
    ref.read(loadingProvider.notifier).setLoading(false);
  }

  /// Renders the dialog action buttons
  Widget _renderDialogActions(BuildContext context, WidgetRef ref) {
    final bool isLoading = ref.watch(loadingProvider);
    final String selectedCategory = ref.watch(categoryProvider(data?.category));

    return
      Visibility(
        key: const Key('UploadPhotoDialogActionsVisibility'),
        visible: (data != null || ref.watch(fileProvider).isFileSelected()) && !isLoading,
        child: OutlinedButton(
            key: const Key('UploadPhotoDialogActionsSubmitButton'),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.black),
                elevation: MaterialStateProperty.all(2),
                foregroundColor: MaterialStateProperty.all(Colors.white),
                textStyle: MaterialStateProperty.all(const TextStyle(color: Colors.white))
            ),
            child: Text(
                key: const Key('UploadPhotoDialogActionsSubmitButtonText'),
                FlutterI18n.translate(context, 'Submit')
            ),
            onPressed: () {
              final form = _formKey.currentState;
              if (!isLoading && (form != null && form.validate())) {
                final String selectedLat = ref.read(geoLatProvider(data?.lat));
                final String selectedLng = ref.read(geoLngProvider(data?.lng));
                ref.read(loadingProvider.notifier).setLoading(true);
                if (data != null) {
                  ref.read(uploadPhotographProvider.notifier).editFile(data!, selectedCategory, selectedLat, selectedLng).then((value) {
                    ref.read(loadingProvider.notifier).setLoading(false);
                    onSubmit(ImageBoardWrapper(image: value, metadata: ImageMetaData()));
                  });
                } else {
                  ref.read(uploadPhotographProvider.notifier).postFile(selectedCategory, selectedLat, selectedLng).then((image) {
                    ref.read(loadingProvider.notifier).setLoading(false);
                    onSubmit(image);
                  });
                }
              }
            }).translateOnPhotoHover,
      );
  }

  /// Renders the loading indicator or an error if there is one
  Widget _renderLoadingIndicator(BuildContext context, WidgetRef ref) {
    final bool isLoading = ref.watch(loadingProvider);

    return isLoading ? const Center(
        key: Key('UploadPhotoDialogLoadingIndicatorCenter'),
        child: Padding(
            key: Key('UploadPhotoDialogLoadingIndicatorPadding'),
          padding: EdgeInsets.all(25),
          child: LoadingIndicator(key: Key('UploadPhotoDialogLoadingIndicator'),)
        )
    ) :
    SimpleInput(
      widgetKey: const Key('photograph comment'),
      labelText: FlutterI18n.translate(context, 'Photograph comment'),
      controllerText: data?.comment,
      onChange: (text) => ref.read(commentProvider.notifier).setComment(text),
      prefixIcon: Icons.comment,
      maxLines: 4,
    );
  }

  ///Renders the geo form
  Widget _renderGeoForm(BuildContext context, WidgetRef ref) => Row(
    key: const Key('UploadPhotoDialogGeoRow'),
    children: [
      Expanded(
          key: const Key('UploadPhotoDialogGeoExpandedLatitude'),
          child: SimpleInput(
            widgetKey: const Key('photograph latitude'),
            labelText: FlutterI18n.translate(context, 'Latitude'),
            controllerText: data?.lat?.toString(),
            onChange: (text) => ref.read(geoLatProvider(data?.lat).notifier).setLat(text),
            prefixIcon: Icons.location_on,
            validator: (value) {
              if(value != null && value.isNotEmpty) {
                try {
                  double.parse(value);
                } catch (e) {
                  return FlutterI18n.translate(context, 'Invalid latitude');
                }
              }
              return null;
              },
          )
      ),
      const SizedBox(
          key: Key('UploadPhotoDialogGeoSeparator'),
          width: 15
      ),
      Expanded(
          key: const Key('UploadPhotoDialogGeoExpandedLongitude'),
          child: SimpleInput(
            widgetKey: const Key('photograph longitude'),
            labelText: FlutterI18n.translate(context, 'Longitude'),
            controllerText: data?.lng?.toString(),
            onChange: (text) => ref.read(geoLngProvider(data?.lng).notifier).setLng(text),
            prefixIcon: Icons.location_on,
            validator: (value) {
              if(value != null && value.isNotEmpty) {
                try {
                  double.parse(value);
                } catch (e) {
                  return FlutterI18n.translate(context, 'Invalid longitude');
                }
              }
              return null;
              },
          )
      ),
    ],
  );

  /// Renders the category selecting field
  Widget _renderCategorySelector(BuildContext context, WidgetRef ref) {
    final String selectedCategory = ref.watch(categoryProvider(data?.category));

    return Center(
      key: const Key('UploadPhotoDialogCategoryCenter'),
      child: Padding(
        key: const Key('UploadPhotoDialogCategoryPadding'),
        padding: const EdgeInsets.all(8.0),
        child: PopupMenuButton<String>(
          key: const Key('UploadPhotoDialogCategoryPopupButton'),
          onSelected: (value) => ref.read(categoryProvider(data?.category).notifier).setCategory(value),
          padding: EdgeInsets.zero,
          itemBuilder: (_) => <PopupMenuItem<String>>[
            PopupMenuItem<String>(
                key: const Key('UploadPhotoDialogCategoryPopupLandscape'),
                value: 'landscape',
                child: Text(FlutterI18n.translate(context, 'L A N D S C A P E'), style: const TextStyle(fontSize: 20))
            ),
            PopupMenuItem<String>(
                key: const Key('UploadPhotoDialogCategoryPopupPortraits'),
                value: 'portraits',
                child: Text(FlutterI18n.translate(context, 'P O R T R A I T S'), style: const TextStyle(fontSize: 20))
            ),
            PopupMenuItem<String>(
                key: const Key('UploadPhotoDialogCategoryPopupStreet'),
                value: 'street',
                child: Text(FlutterI18n.translate(context, 'S T R E E T'), style: const TextStyle(fontSize: 20))
            ),
            PopupMenuItem<String>(
                key: const Key('UploadPhotoDialogCategoryPopupOther'),
                value: 'other',
                child: Text(FlutterI18n.translate(context, 'O T H E R'), style: const TextStyle(fontSize: 20))
            ),
          ],
          child: Text(
              key: const Key('UploadPhotoDialogCategoryPopupTitle'),
              selectedCategory, style: const TextStyle(fontSize: 20)
          ),
        ),
      ),
    );
  }

  /// Renders the selected image name
  Widget _renderSelectedImageName(FileData fileData) =>
      fileData.isFileSelected() || data != null ?
        Center(
            key: const Key('UploadPhotoDialogSelectedImageCenter'),
            child: StyledText(
              key: const Key('UploadPhotoDialogSelectedImageText'),
                text: data != null ? data!.path! : fileData.fileName!,
                decoration: TextDecoration.underline,
            )
        ) : const SizedBox.shrink(key: Key('UploadPhotoDialogSelectedImageNothing'));

  /// Renders the image upload button or if its in edit mode - the existing image
  Widget _renderUploadButton(BuildContext context, WidgetRef ref, FileData fileData) {
    const Key widgetKey = Key('upload');
    final bool isHovering = ref.watch(hoverProvider(widgetKey));

    return Column(
      key: const Key('UploadPhotoDialogUploadButtonColumn'),
      children: [
        StyledTooltip(
          key: const Key('UploadPhotoDialogUploadButtonTooltip'),
          text: FlutterI18n.translate(context, 'Photograph'),
          pointingPosition: AxisDirection.right,
          child: Material(
            key: const Key('UploadPhotoDialogUploadButtonMaterial'),
            color: Colors.transparent,
            child: InkWell(
              key: const Key('UploadPhotoDialogUploadButtonInkWell'),
              onTap: () => _selectPhotograph(ref),
              onHover: (hover) => ref.read(hoverProvider(widgetKey).notifier).onHover(hover),
              child: AnimatedContainer(
                  key: const Key('UploadPhotoDialogUploadButtonAnimatedContainer'),
                  width: isHovering ? 165 : 160,
                  height: isHovering ? 165 : 160,
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.fastOutSlowIn,
                  child: IconRenderer(
                    key: const Key('UploadPhotoDialogUploadButtonSvg'),
                    asset: 'upload.svg',
                    color: Colors.black,
                    width: isHovering ? 250 : 240 - 20,
                    height: isHovering ? 250 : 240 - 20,
                  )
              ),
            ),
          ),
        ),
        StyledText(
            key: const Key('UploadPhotoDialogUploadButtonTitle'),
            text: FlutterI18n.translate(context, 'Select an image')
        )
      ],
    );
  }

  /// Renders the dialog body
  Widget _renderDialogBody(BuildContext context, WidgetRef ref, FileData fileData) => Column(
    key: const Key('UploadPhotoDialogBodyColumn'),
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Visibility(
          key: const Key('UploadPhotoDialogBodyUploadButtonVisibility'),
          visible: !fileData.isFileSelected() && data == null,
          child: _renderUploadButton(context, ref, fileData)
      ),
      Visibility(
        key: const Key('UploadPhotoDialogBodyContentVisibility'),
        visible: fileData.isFileSelected() || data != null,
        child: Column(
            key: const Key('UploadPhotoDialogBodyContentColumn'),
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _renderSelectedImageName(fileData),
            _renderCategorySelector(context, ref),
            const SizedBox(
                key: Key('UploadPhotoDialogBodyContentSelectorSeparator'),
                height: 10
            ),
            _renderGeoForm(context, ref),
            const SizedBox(
                key: Key('UploadPhotoDialogBodyContentGeoSeparator'),
                height: 10
            ),
            _renderLoadingIndicator(context, ref),
        ]),
      )
    ],
  );

  /// Renders the dialog header
  Widget _renderDialogHeader(BuildContext context, WidgetRef ref) => Column(
    key: const Key('UploadPhotoDialogHeaderColumn'),
    children: [
      Padding(
        key: const Key('UploadPhotoDialogHeaderRowPadding'),
        padding: const EdgeInsets.all(10.0),
        child: Row(
            key: const Key('UploadPhotoDialogHeaderRow'),
            children: [
              StyledText(
                  key: const Key('UploadPhotoDialogHeaderText'),
                  text: data != null ? FlutterI18n.translate(context, 'Edit Photograph') : FlutterI18n.translate(context, 'Upload Photograph'),
                  weight: FontWeight.bold
              ),
              const Spacer(key: Key('UploadPhotoDialogHeaderSpacer')),
              DefaultButton(
                  key: const Key('UploadPhotoDialogHeaderCloseButton'),
                  onClick: () {
                    if(data != null) {
                      ref.read(overlayVisibilityProvider(const Key('edit_image')).notifier).setOverlayVisibility(false);
                    } else {
                      ref.read(overlayVisibilityProvider(const Key('upload_image')).notifier).setOverlayVisibility(false);
                    }
                  },
                  tooltip: FlutterI18n.translate(context, 'Close'),
                  color: Colors.white,
                  borderColor: Colors.white,
                  icon: 'close.svg'
              ),
            ]
        ),
      ),
      const Divider(
        key: Key('UploadPhotoDialogHeaderDivider'),
        color: Colors.black
      )
    ],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FileData fileData = ref.watch(fileProvider);

    return Form(
      key: _formKey,
      child: ShadowWidget(
        key: const Key('UploadPhotoDialogShadow'),
        offset: const Offset(0, 0),
        blurRadius: 4,
        child: Container(
          key: const Key('UploadPhotoDialogColumnContainer'),
          color: Colors.white,
          height: dialogHeight,
          child: Column(
            key: const Key('UploadPhotoDialogColumn'),
            children: [
              _renderDialogHeader(context, ref),
              Padding(
                key: const Key('UploadPhotoDialogBodyPadding'),
                padding: const EdgeInsets.all(10.0),
                child: _renderDialogBody(context, ref, fileData),
              ),
              _renderDialogActions(context, ref),
            ],
          ),
        ),
      )
    );
  }
}
