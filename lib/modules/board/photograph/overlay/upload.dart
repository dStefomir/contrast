import 'package:contrast/common/widgets/button.dart';
import 'package:contrast/common/widgets/hover_provider.dart';
import 'package:contrast/common/widgets/input/input.dart';
import 'package:contrast/common/widgets/load.dart';
import 'package:contrast/common/widgets/photograph.dart';
import 'package:contrast/model/image_data.dart';
import 'package:contrast/modules/board/photograph/overlay/provider.dart';
import 'package:contrast/modules/board/photograph/service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'dart:io';

import '../../../../../common/widgets/icon.dart';

/// Dialog width
const double dialogWidth = 400;
/// Dialog height
const double dialogHeight = 550;

/// Renders the upload image dialog
class UploadImageDialog extends HookConsumerWidget {
  /// Existing image data
  final ImageData? data;
  /// Constraints of the holder page
  final BoxConstraints constraints;
  /// Form key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  UploadImageDialog({Key? key, required this.constraints, this.data,}) : super(key: key);

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
  List<Widget> _renderDialogActions(BuildContext context, WidgetRef ref) {
    final bool isLoading = ref.watch(loadingProvider);
    final String selectedCategory = ref.watch(categoryProvider(data?.category));

    return [
      Visibility(
        visible: (data != null || ref.watch(fileProvider).isFileSelected()) && !isLoading,
        child: OutlinedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.black),
                elevation: MaterialStateProperty.all(2),
                foregroundColor: MaterialStateProperty.all(Colors.white),
                textStyle: MaterialStateProperty.all(const TextStyle(color: Colors.white))
            ),
            child: const Text("Submit"),
            onPressed: () {
              final form = _formKey.currentState;
              if (!isLoading && (form != null && form.validate())) {
                final String selectedLat = ref.read(geoLatProvider(data?.lat));
                final String selectedLng = ref.read(geoLngProvider(data?.lng));
                ref.read(loadingProvider.notifier).setLoading(true);
                if (data != null) {
                  ref.read(uploadPhotographProvider.notifier).editFile(data!, selectedCategory, selectedLat, selectedLng).then((value) {
                    ref.read(loadingProvider.notifier).setLoading(false);
                    Navigator.of(context).pop(value);
                  });
                } else {
                  ref.read(uploadPhotographProvider.notifier).postFile(selectedCategory, selectedLat, selectedLng).then((image) {
                    ref.read(loadingProvider.notifier).setLoading(false);
                    Navigator.of(context).pop(image);
                  });
                }
              }
            }),
      )
    ];
  }

  /// Renders the loading indicator or an error if there is one
  Widget _renderLoadingIndicator(WidgetRef ref) {
    final bool isLoading = ref.watch(loadingProvider);

    return isLoading ? const Center(
        child: Padding(
          padding: EdgeInsets.all(25),
          child: LoadingIndicator()
        )
    ) :
    Expanded(
      child: SimpleInput(
        labelText: 'Photograph comment',
        controllerText: data?.comment ?? '',
        isRequired: false,
        onChange: (text) => ref.read(commentProvider.notifier).setComment(text),
        prefixIconAsset: 'assets/username.svg',
        maxLines: 10,
      ),
    );
  }

  ///Renders the geo form
  Widget _renderGeoForm(WidgetRef ref) => Row(
    children: [
      Expanded(
          child: SimpleInput(
            labelText: 'Latitude',
            controllerText: data?.lat?.toString() ?? '',
            onChange: (text) => ref.read(geoLatProvider(data?.lat).notifier).setLat(text),
            validator: (value) {
              if(value != null && value.isNotEmpty) {
                try {
                  double.parse(value);
                } catch (e) {
                  return 'Invalid latitude';
                }
              }
              return null;
              },
          )
      ),
      const SizedBox(width: 15),
      Expanded(
          child: SimpleInput(
            labelText: 'Longitude',
            controllerText: data?.lng?.toString() ?? '',
            onChange: (text) => ref.read(geoLngProvider(data?.lng).notifier).setLng(text),
            validator: (value) {
              if(value != null && value.isNotEmpty) {
                try {
                  double.parse(value);
                } catch (e) {
                  return 'Invalid longitude';
                }
              }
              return null;
              },
          )
      ),
    ],
  );

  /// Renders the category selecting field
  Widget _renderCategorySelector(WidgetRef ref) {
    final String selectedCategory = ref.watch(categoryProvider(data?.category));

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: PopupMenuButton<String>(
          onSelected: (value) => ref.read(categoryProvider(data?.category).notifier).setCategory(value),
          padding: EdgeInsets.zero,
          itemBuilder: (_) => <PopupMenuItem<String>>[
            const PopupMenuItem<String>(
                value: 'landscape',
                child: Text('L A N D S C A P E', style: TextStyle(fontSize: 20))
            ),
            const PopupMenuItem<String>(
                value: 'portraits',
                child: Text('P O R T R A I T S', style: TextStyle(fontSize: 20))
            ),
            const PopupMenuItem<String>(
                value: 'street',
                child: Text('S T R E E T', style: TextStyle(fontSize: 20))
            ),
            const PopupMenuItem<String>(
                value: 'other',
                child: Text('O T H E R', style: TextStyle(fontSize: 20))
            ),
          ],
          child: Text(selectedCategory, style: const TextStyle(fontSize: 20)),
        ),
      ),
    );
  }

  /// Renders the selected image
  Widget _renderSelectedImage(BuildContext context, WidgetRef ref, FileData fileData) {
    bool isLandscape = data != null ? data!.isLandscape! : fileData.isLandscape!;
    bool isRect = data != null ? data!.isRect! : fileData.isRect!;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: ContrastPhotograph(
        widgetKey: const Key('selectedPhotograph'),
        compressed: true,
        quality: FilterQuality.low,
        image: data,
        fetch: (path) => ref.read(photographyBoardServiceProvider).getCompressedPhotograph(context, path, false),
        borderColor: Colors.transparent,
        data: fileData.bytes,
        width: (isLandscape && isRect)
            ? 165
            : isLandscape
            ? 250
            : 165,
        height: (isLandscape && isRect)
            ? 165
            : isLandscape
            ? 180
            : 245,
      ),
    );
  }

  /// Renders the image upload button or if its in edit mode - the existing image
  Widget _renderUploadButton(BuildContext context, WidgetRef ref, FileData fileData) {
    const Key widgetKey = Key('upload');
    final bool isHovering = ref.watch(hoverProvider(widgetKey));

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: data != null || fileData.isFileSelected()
            ? _renderSelectedImage(context, ref, fileData)
            : Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _selectPhotograph(ref),
            onHover: (hover) => ref.read(hoverProvider(widgetKey).notifier).onHover(hover),
            child: AnimatedContainer(
                width: isHovering ? 250 : 240,
                height: isHovering ? 250 : 240,
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
    );
  }

  /// Renders the dialog body
  Widget _renderDialogBody(BuildContext context, WidgetRef ref, FileData fileData) => SizedBox(
    width: dialogWidth,
    height: dialogHeight,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _renderUploadButton(context, ref, fileData),
        const SizedBox(height: 20),
        _renderCategorySelector(ref),
        const SizedBox(height: 20),
        _renderGeoForm(ref),
        const SizedBox(height: 20),
        _renderLoadingIndicator(ref)
      ],
    ),
  );

  /// Renders the dialog header
  Widget _renderDialogHeader(BuildContext context) => Column(
    children: [
      Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Text(
                  data != null ? "Edit Photograph" : "Upload Photograph",
                  style: Theme.of(context).textTheme.headlineSmall
              ),
            ),
            const Spacer(),
            RoundedButton(
                onClick: () => Navigator.of(context).pop(),
                color: Colors.black,
                borderColor: Colors.white,
                icon: 'close.svg'
            )
          ]
      ),
      const Divider(color: Colors.black,)
    ],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FileData fileData = ref.watch(fileProvider);
    // Dispose of the providers or perform any other cleanup tasks here
    useEffect(() {
      return () {
        ref.read(loadingProvider.notifier).dispose();
        ref.read(categoryProvider(data?.category).notifier).dispose();
        ref.read(geoLatProvider(data?.lat).notifier).dispose();
        ref.read(geoLngProvider(data?.lng).notifier).dispose();
        ref.read(commentProvider.notifier).dispose();
        ref.read(uploadPhotographProvider.notifier).dispose();
      };
    }, []);

    return Form(
      key: _formKey,
      child: AlertDialog(
          backgroundColor: Colors.white,
          scrollable: true,
          title: _renderDialogHeader(context),
          content: _renderDialogBody(context, ref, fileData),
          actions: _renderDialogActions(context, ref)),
    );
  }
}
