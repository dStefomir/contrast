import 'package:contrast/common/widgets/button.dart';
import 'package:contrast/common/widgets/icon.dart';
import 'package:contrast/common/widgets/shadow.dart';
import 'package:contrast/common/widgets/text.dart';
import 'package:contrast/model/image_data.dart';
import 'package:contrast/model/video_data.dart';
import 'package:contrast/modules/board/overlay/delete/provider.dart';
import 'package:contrast/modules/board/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
/// Dialog height
const double dialogHeight = 350;
/// Renders a delete item dialog
class DeleteDialog<T> extends HookConsumerWidget {
  // Image Entity is passed for deleting
  final T? data;
  /// Function which updates the board
  final void Function(T? entry) onSubmit;

  const DeleteDialog({Key? key, required this.data, required this.onSubmit}) : super(key: key);

  /// What happens when the user agrees to delete an item
  void _onDelete(WidgetRef ref) async {
    if(data != null) {
      final deleteProvider = ref.read(deleteEntriesProvider.notifier);
      if(_isImage()) {
        final ImageData photograph = await deleteProvider.deletePhotograph(data as ImageData);
        onSubmit(photograph as T);
      } else {
        final VideoData video = await deleteProvider.deleteVideo(data as VideoData);
        onSubmit(video as T);
      }
    }
  }

  // Checks if dta is actually ImageData or VideoData
  bool _isImage() => data != null && data is ImageData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShadowWidget(
        offset: const Offset(0, 0),
        blurRadius: 4,
        child: Container(
          color: Colors.white,
          height: dialogHeight,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                          children: [
                            StyledText(
                                text: translate('Warning'),
                                weight: FontWeight.bold
                            ),
                            const Spacer(),
                            DefaultButton(
                                onClick: () {
                                  if(_isImage()) {
                                    ref.read(overlayVisibilityProvider(const Key('delete_image')).notifier).setOverlayVisibility(false);
                                  } else {
                                    ref.read(overlayVisibilityProvider(const Key('delete_video')).notifier).setOverlayVisibility(false);
                                  }
                                },
                                tooltip: translate('Close'),
                                color: Colors.white,
                                borderColor: Colors.black,
                                icon: 'close.svg'
                            ),
                          ]
                      ),
                    ),
                    const Divider(color: Colors.black,)
                  ],
                ),
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    IconRenderer(asset: 'background_landscape.svg', height: dialogHeight / 1.4, color: Colors.black.withOpacity(0.03), fit: BoxFit.cover),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              StyledText(
                                text: _isImage() ? translate('Delete this photo') : translate('Delete this video'),
                                clip: false,
                              ),
                              StyledText(
                                  text: _isImage() ? (data as ImageData).path! : (data as VideoData).path!,
                                  clip: false
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            OutlinedButton(
                                style: ButtonStyle(
                                    fixedSize: MaterialStateProperty.all(const Size(100, 30)),
                                    backgroundColor: MaterialStateProperty.all(Colors.black),
                                    elevation: MaterialStateProperty.all(2),
                                    foregroundColor: MaterialStateProperty.all(Colors.white),
                                    textStyle: MaterialStateProperty.all(const TextStyle(color: Colors.white))
                                ),
                                child: Text(
                                    translate('Yes')
                                ),
                                onPressed: () => _onDelete(ref)
                            ),
                            const SizedBox(
                                width: 30
                            ),
                            OutlinedButton(
                                style: ButtonStyle(
                                    fixedSize: MaterialStateProperty.all(const Size(100, 30)),
                                    backgroundColor: MaterialStateProperty.all(Colors.white),
                                    elevation: MaterialStateProperty.all(2),
                                    foregroundColor: MaterialStateProperty.all(Colors.black),
                                    textStyle: MaterialStateProperty.all(const TextStyle(color: Colors.black))
                                ),
                                child: Text(
                                    translate('No')
                                ),
                                onPressed: () {
                                  if(_isImage()) {
                                    ref.read(overlayVisibilityProvider(const Key('delete_image')).notifier).setOverlayVisibility(false);
                                  } else {
                                    ref.read(overlayVisibilityProvider(const Key('delete_video')).notifier).setOverlayVisibility(false);
                                  }
                                }
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        )
    );
  }
}