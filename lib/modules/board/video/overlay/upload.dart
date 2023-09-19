import 'package:contrast/common/widgets/button.dart';
import 'package:contrast/common/widgets/input.dart';
import 'package:contrast/common/widgets/load.dart';
import 'package:contrast/common/widgets/shadow.dart';
import 'package:contrast/common/widgets/text.dart';
import 'package:contrast/model/video_data.dart';
import 'package:contrast/modules/board/provider.dart';
import 'package:contrast/modules/board/video/overlay/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
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
        key: const Key('UploadVideoDialogSubmitButton'),
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.black),
            elevation: MaterialStateProperty.all(2),
            foregroundColor: MaterialStateProperty.all(Colors.white),
            textStyle: MaterialStateProperty.all(const TextStyle(color: Colors.white))
        ),
        child: Text(
            key: const Key('UploadVideoDialogSubmitButtonText'),
            FlutterI18n.translate(context, 'Submit')
        ),
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
        key: Key('UploadVideoDialogBodyCenter'),
      child: Padding(
          key: Key('UploadVideoDialogBodyCenterPadding'),
        padding: EdgeInsets.all(25),
        child: LoadingIndicator(key: Key('UploadVideoDialogBodyCenterLoadingIndicator'),)
      )
    ) :
    SimpleInput(
      widgetKey: const Key('video comment'),
      controllerText: data?.comment,
      labelText: FlutterI18n.translate(context, 'Video comment'),
      prefixIcon: Icons.comment,
      onChange: (text) => ref.read(commentProvider.notifier).setComment(text),
      maxLines: 4,
    );
  }

  /// Renders the dialog body
  Widget _renderDialogBody(BuildContext context, WidgetRef ref) => Column(
    key: const Key('UploadVideoDialogBodyColumn'),
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SimpleInput(
        widgetKey: const Key('video url'),
        controllerText: data?.path,
        labelText: FlutterI18n.translate(context, 'Youtube url'),
        onChange: (text) => ref.read(videoUrlProvider.notifier).setUrl(text),
        prefixIcon: Icons.video_collection,
        validator: (value) {
          if (value != null && value.isEmpty) {
            return FlutterI18n.translate(context, 'This field is mandatory');
          }
          if(value != null && value.isNotEmpty && value.length < 11) {
            return FlutterI18n.translate(context, 'Invalid youtube prefix');
          }
          return null;
          },
      ),
      const SizedBox(
          key: Key('UploadVideoDialogBodySizedBox'),
          height: 20
      ),
      _renderLoadingIndicator(context, ref)
    ],
  );

  /// Renders the dialog header
  Widget _renderDialogHeader(BuildContext context, WidgetRef ref) => Column(
    key: const Key('UploadVideoDialogHeaderColumn'),
    children: [
      Padding(
        key: const Key('UploadVideoDialogHeaderPadding'),
        padding: const EdgeInsets.all(10.0),
        child: Row(
            key: const Key('UploadVideoDialogHeaderRow'),
            children: [
              StyledText(
                  key: const Key('UploadVideoDialogHeaderTitleText'),
                  text: data != null ? FlutterI18n.translate(context, 'Edit Video') : FlutterI18n.translate(context, 'Upload Video'),
                  weight: FontWeight.bold
              ),
              const Spacer(key: Key('UploadVideoDialogHeaderSpacer')),
              DefaultButton(
                  key: const Key('UploadVideoDialogHeaderCloseButton'),
                  onClick: () {
                    if(data != null) {
                      ref.read(overlayVisibilityProvider(const Key("edit_video")).notifier).setOverlayVisibility(false);
                    } else {
                      ref.read(overlayVisibilityProvider(const Key("upload_video")).notifier).setOverlayVisibility(false);
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
        key: Key('UploadVideoDialogHeaderDivider'),
        color: Colors.black
      )
    ],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      Form(
        key: _formKey,
        child: ShadowWidget(
          key: const Key('UploadVideoDialogShadow'),
          offset: const Offset(0, 0),
          blurRadius: 4,
          child: Container(
            key: const Key('UploadVideoDialogFormContainer'),
            color: Colors.white,
            height: dialogHeight,
            child: Column(
              key: const Key('UploadVideoDialogFormColumn'),
              children: [
                _renderDialogHeader(context, ref),
                Padding(
                  key: const Key('UploadVideoDialogBodyPadding'),
                  padding: const EdgeInsets.all(10.0),
                  child: _renderDialogBody(context, ref),
                ),
                _renderDialogActions(context, ref)
              ],
            ),
          ),
        )
    );
}