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
  final void Function(ImageWrapper) onSubmit;
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
        visible: (data != null || ref.watch(fileProvider).isFileSelected()) && !isLoading,
        child: OutlinedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.black),
                elevation: MaterialStateProperty.all(2),
                foregroundColor: MaterialStateProperty.all(Colors.white),
                textStyle: MaterialStateProperty.all(const TextStyle(color: Colors.white))
            ),
            child: Text(FlutterI18n.translate(context, 'Submit')),
            onPressed: () {
              final form = _formKey.currentState;
              if (!isLoading && (form != null && form.validate())) {
                final String selectedLat = ref.read(geoLatProvider(data?.lat));
                final String selectedLng = ref.read(geoLngProvider(data?.lng));
                ref.read(loadingProvider.notifier).setLoading(true);
                if (data != null) {
                  ref.read(uploadPhotographProvider.notifier).editFile(data!, selectedCategory, selectedLat, selectedLng).then((value) {
                    ref.read(loadingProvider.notifier).setLoading(false);
                    onSubmit(ImageWrapper(image: value, metadata: ImageMetaData()));
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
        child: Padding(
          padding: EdgeInsets.all(25),
          child: LoadingIndicator()
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
    children: [
      Expanded(
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
      const SizedBox(width: 15),
      Expanded(
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
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: PopupMenuButton<String>(
          onSelected: (value) => ref.read(categoryProvider(data?.category).notifier).setCategory(value),
          padding: EdgeInsets.zero,
          itemBuilder: (_) => <PopupMenuItem<String>>[
            PopupMenuItem<String>(
                value: 'landscape',
                child: Text(FlutterI18n.translate(context, 'L A N D S C A P E'), style: const TextStyle(fontSize: 20))
            ),
            PopupMenuItem<String>(
                value: 'portraits',
                child: Text(FlutterI18n.translate(context, 'P O R T R A I T S'), style: const TextStyle(fontSize: 20))
            ),
            PopupMenuItem<String>(
                value: 'street',
                child: Text(FlutterI18n.translate(context, 'S T R E E T'), style: const TextStyle(fontSize: 20))
            ),
            PopupMenuItem<String>(
                value: 'other',
                child: Text(FlutterI18n.translate(context, 'O T H E R'), style: const TextStyle(fontSize: 20))
            ),
          ],
          child: Text(selectedCategory, style: const TextStyle(fontSize: 20)),
        ),
      ),
    );
  }

  /// Renders the selected image name
  Widget _renderSelectedImageName(FileData fileData) =>
      fileData.isFileSelected() || data != null ?
        Center(
            child: StyledText(
                text: data != null ? data!.path! : fileData.fileName!,
                decoration: TextDecoration.underline,
            )
        ) : const SizedBox.shrink();

  /// Renders the image upload button or if its in edit mode - the existing image
  Widget _renderUploadButton(BuildContext context, WidgetRef ref, FileData fileData) {
    const Key widgetKey = Key('upload');
    final bool isHovering = ref.watch(hoverProvider(widgetKey));

    return Column(
      children: [
        StyledTooltip(
          text: FlutterI18n.translate(context, 'Photograph'),
          pointingPosition: AxisDirection.right,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _selectPhotograph(ref),
              onHover: (hover) => ref.read(hoverProvider(widgetKey).notifier).onHover(hover),
              child: AnimatedContainer(
                  width: isHovering ? 165 : 160,
                  height: isHovering ? 165 : 160,
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.fastOutSlowIn,
                  child: IconRenderer(
                    asset: 'upload.svg',
                    color: Colors.black,
                    width: isHovering ? 250 : 240 - 20,
                    height: isHovering ? 250 : 240 - 20,
                  )
              ),
            ),
          ),
        ),
        StyledText(text: FlutterI18n.translate(context, 'Select an image'))
      ],
    );
  }

  /// Renders the dialog body
  Widget _renderDialogBody(BuildContext context, WidgetRef ref, FileData fileData) => Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Visibility(
          visible: !fileData.isFileSelected() && data == null,
          child: _renderUploadButton(context, ref, fileData)
      ),
      Visibility(
        visible: fileData.isFileSelected() || data != null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _renderSelectedImageName(fileData),
            _renderCategorySelector(context, ref),
            const SizedBox(height: 10),
            _renderGeoForm(context, ref),
            const SizedBox(height: 10),
            _renderLoadingIndicator(context, ref),
        ]),
      )
    ],
  );

  /// Renders the dialog header
  Widget _renderDialogHeader(BuildContext context, WidgetRef ref) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
            children: [
              StyledText(
                  text: data != null ? FlutterI18n.translate(context, 'Edit Photograph') : FlutterI18n.translate(context, 'Upload Photograph'),
                  weight: FontWeight.bold
              ),
              const Spacer(),
              DefaultButton(
                  onClick: () {
                    if(data != null) {
                      ref.read(overlayVisibilityProvider(const Key('edit_image')).notifier).setOverlayVisibility(false);
                    } else {
                      ref.read(overlayVisibilityProvider(const Key('upload_image')).notifier).setOverlayVisibility(false);
                    }
                  },
                  tooltip: FlutterI18n.translate(context, 'Close'),
                  color: Colors.black,
                  borderColor: Colors.white,
                  icon: 'close.svg'
              ),
            ]
        ),
      ),
      const Divider(color: Colors.black,)
    ],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FileData fileData = ref.watch(fileProvider);

    return Form(
      key: _formKey,
      child: ShadowWidget(
        offset: const Offset(0, 0),
        blurRadius: 4,
        child: Container(
          color: Colors.white,
          height: dialogHeight,
          child: Column(
            children: [
              _renderDialogHeader(context, ref),
              Padding(
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
