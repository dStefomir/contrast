import 'package:contrast/common/widgets/button.dart';
import 'package:contrast/common/widgets/input.dart';
import 'package:contrast/common/widgets/load.dart';
import 'package:contrast/common/widgets/shadow.dart';
import 'package:contrast/common/widgets/text.dart';
import 'package:contrast/model/video_data.dart';
import 'package:contrast/modules/board/provider.dart';
import 'package:contrast/modules/board/video/overlay/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
/// Dialog height
const double dialogHeight = 450;
/// Renders the upload image dialog
class UploadVideoDialog extends HookConsumerWidget {
  /// Existing video data
  final VideoData? data;
  /// Function which updates the board
  final void Function(VideoData entry) onSubmit;
  /// Form key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  UploadVideoDialog({Key? key, this.data, required this.onSubmit}) : super(key: key);

  /// Renders the dialog action buttons
  Widget _renderDialogActions(BuildContext context, WidgetRef ref) {
    final bool isLoading = ref.watch(loadingProvider);

    return OutlinedButton(
        style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.black),
            elevation: WidgetStateProperty.all(2),
            foregroundColor: WidgetStateProperty.all(Colors.white),
            textStyle: WidgetStateProperty.all(const TextStyle(color: Colors.white))
        ),
        child: Text('Submit'.tr()),
        onPressed: () async {
          final form = _formKey.currentState;
          if (!isLoading && (form != null && form.validate())) {
            ref.read(loadingProvider.notifier).setLoading(true);
            if (data != null) {
              ref.read(uploadVideoProvider.notifier).editVideo(data!).then((video) {
                ref.read(loadingProvider.notifier).setLoading(false);
                onSubmit(video);
              });
            } else {
              ref.read(uploadVideoProvider.notifier).postVideo().then((video) {
                ref.read(loadingProvider.notifier).setLoading(false);
                onSubmit(video);
              });
            }
          }
        });
  }

  /// Renders the loading indicator or an error if there is one
  Widget _renderLoadingIndicator(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(loadingProvider);

    return isLoading ?
    const Center(
        child: Padding(
            padding: EdgeInsets.all(25),
            child: LoadingIndicator()
        )
    ) :
    SimpleInput(
      widgetKey: const Key('video comment'),
      controllerText: data?.comment,
      labelText: 'Video comment'.tr(),
      prefixIcon: Icons.comment,
      onChange: (text) => ref.read(commentProvider.notifier).setComment(text),
      maxLines: 4,
    );
  }

  /// Renders the dialog body
  Widget _renderDialogBody(BuildContext context, WidgetRef ref) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SimpleInput(
        widgetKey: const Key('video url'),
        controllerText: data?.path,
        labelText: 'Youtube url'.tr(),
        onChange: (text) => ref.read(videoUrlProvider.notifier).setUrl(text),
        prefixIcon: Icons.video_collection,
        validator: (value) {
          if (value != null && value.isEmpty) {
            return 'This field is mandatory'.tr();
          }
          if(value != null && value.isNotEmpty && value.length < 11) {
            return 'Invalid youtube prefix'.tr();
          }
          return null;
          },
      ),
      const SizedBox(height: 20),
      _renderLoadingIndicator(context, ref)
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
                  text: data != null ? 'Edit Video'.tr() : 'Upload Video'.tr(),
                  weight: FontWeight.bold
              ),
              const Spacer(),
              DefaultButton(
                  onClick: () {
                    if(data != null) {
                      ref.read(overlayVisibilityProvider(const Key("edit_video")).notifier).setOverlayVisibility(false);
                    } else {
                      ref.read(overlayVisibilityProvider(const Key("upload_video")).notifier).setOverlayVisibility(false);
                    }
                  },
                  tooltip: 'Close'.tr(),
                  color: Colors.white,
                  borderColor: Colors.black,
                  icon: 'close.svg'
              ),
            ]
        ),
      ),
      const Divider(color: Colors.black)
    ],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      Form(
        key: _formKey,
        child: ShadowWidget(
          offset: const Offset(0, 0),
          blurRadius: 4,
          child: Container(
            color: Colors.white,
            height: dialogHeight,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _renderDialogHeader(context, ref),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: _renderDialogBody(context, ref),
                  ),
                  _renderDialogActions(context, ref)
                ],
              ),
            ),
          ),
        )
    );
}