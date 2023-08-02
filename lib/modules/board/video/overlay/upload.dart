import 'package:contrast/common/widgets/button.dart';
import 'package:contrast/common/widgets/input.dart';
import 'package:contrast/common/widgets/load.dart';
import 'package:contrast/model/video_data.dart';
import 'package:contrast/modules/board/video/overlay/provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
/// Dialog width
const double dialogWidth = 400;
/// Dialog height
const double dialogHeight = 270;
/// Renders the upload image dialog
class UploadVideoDialog extends HookConsumerWidget {
  /// Existing video data
  final VideoData? data;
  /// Form key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  UploadVideoDialog({Key? key, this.data}) : super(key: key);

  /// Renders the dialog action buttons
  List<Widget> _renderDialogActions(BuildContext context, WidgetRef ref) {
    final bool isLoading = ref.watch(loadingProvider);

    return
      [
        OutlinedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.black),
                elevation: MaterialStateProperty.all(2),
                foregroundColor: MaterialStateProperty.all(Colors.white),
                textStyle: MaterialStateProperty.all(const TextStyle(color: Colors.white))
            ),
            child: const Text("Submit"),
            onPressed: () async {
              final form = _formKey.currentState;
              if (!isLoading && (form != null && form.validate())) {
                ref.read(loadingProvider.notifier).setLoading(true);
                if (data != null) {
                  ref.read(uploadVideoProvider.notifier).editVideo(data!).then((video) {
                    ref.read(loadingProvider.notifier).setLoading(false);
                    Navigator.of(context).pop(video);
                  });
                } else {
                  ref.read(uploadVideoProvider.notifier).postVideo().then((video) {
                    ref.read(loadingProvider.notifier).setLoading(false);
                    Navigator.of(context).pop(video);
                  });
                }
              }
            })
      ];
  }

  /// Renders the loading indicator or an error if there is one
  Widget _renderLoadingIndicator(WidgetRef ref) {
    final isLoading = ref.watch(loadingProvider);

    return isLoading ?
    const Center(
      child: Padding(
        padding: EdgeInsets.all(25),
        child: LoadingIndicator()
      )
    ) :
    Expanded(
      child: SimpleInput(
        widgetKey: const Key('video comment'),
        controllerText: data?.comment,
        labelText: 'Video comment',
        prefixIcon: Icons.comment,
        onChange: (text) => ref.read(commentProvider.notifier).setComment(text),
        maxLines: 4,
      ),
    );
  }

  /// Renders the dialog body
  Widget _renderDialogBody(WidgetRef ref) => SizedBox(
    width: dialogWidth,
    height: dialogHeight,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
            width: 400,
            child: SimpleInput(
              widgetKey: const Key('video url'),
              controllerText: data?.path,
              labelText: 'Youtube url',
              onChange: (text) => ref.read(videoUrlProvider.notifier).setUrl(text),
              prefixIcon: Icons.video_collection,
              validator: (value) {
                if (value != null && value.isEmpty) {
                  return 'This field is mandatory.';
                }
                if(value != null && value.isNotEmpty && value.length < 11) {
                  return 'Invalid youtube prefix';
                }
                return null;
                },
            )
        ),
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
            Text(
                data != null ? "Edit Video" : "Upload Video",
                style: Theme.of(context).textTheme.headlineSmall
            ),
            const Spacer(),
            RoundedButton(
                onClick: () => Navigator.of(context).pop(),
                color: Colors.black,
                borderColor: Colors.white,
                icon: 'close.svg'
            ),
          ]
      ),
      const Divider(color: Colors.black,)
    ],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      Form(
        key: _formKey,
        child: AlertDialog(
            backgroundColor: Colors.white,
            scrollable: true,
            title: _renderDialogHeader(context),
            content: _renderDialogBody(ref),
            actions: _renderDialogActions(context, ref)
        ),
    );
}