import 'package:contrast/common/widgets/button.dart';
import 'package:contrast/common/widgets/shadow.dart';
import 'package:contrast/common/widgets/text.dart';
import 'package:contrast/model/image_data.dart';
import 'package:contrast/model/video_data.dart';
import 'package:contrast/modules/board/overlay/delete/provider.dart';
import 'package:contrast/modules/board/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
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
        key: const Key('DeleteDialogShadow'),
        offset: const Offset(0, 0),
        blurRadius: 4,
        child: Container(
          key: const Key('DeleteDialogTopContainer'),
          color: Colors.white,
          height: dialogHeight,
          child: Column(
            key: const Key('DeleteDialogTopColumn'),
            children: [
              Column(
                key: const Key('DeleteDialogInnerColumn'),
                children: [
                  Padding(
                    key: const Key('DeleteDialogColumnPadding'),
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                        key: const Key('DeleteDialogColumnRow'),
                        children: [
                          StyledText(
                              key: const Key('DeleteDialogColumnRowText'),
                              text: FlutterI18n.translate(context, 'Warning'),
                              weight: FontWeight.bold
                          ),
                          const Spacer(key: Key('DeleteDialogColumnRowSpacer'),),
                          DefaultButton(
                              key: const Key('DeleteDialogColumnRowButton'),
                              onClick: () {
                                if(_isImage()) {
                                  ref.read(overlayVisibilityProvider(const Key('delete_image')).notifier).setOverlayVisibility(false);
                                } else {
                                  ref.read(overlayVisibilityProvider(const Key('delete_video')).notifier).setOverlayVisibility(false);
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
                  const Divider(color: Colors.black,)
                ],
              ),
              Padding(
                key: const Key('DeleteDialogBodyPadding'),
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  key: const Key('DeleteDialogBodyColumn'),
                  children: [
                    StyledText(
                      key: const Key('DeleteDialogBodyColumnText'),
                      text: _isImage() ? FlutterI18n.translate(context, 'Delete this photo') : FlutterI18n.translate(context, 'Delete this video'),
                      clip: false,
                    ),
                    StyledText(
                        key: const Key('DeleteDialogBodyTextPath'),
                        text: _isImage() ? (data as ImageData).path! : (data as VideoData).path!,
                        clip: false
                    ),
                  ],
                ),
              ),
              Row(
                key: const Key('DeleteDialogBodyRow'),
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  OutlinedButton(
                      key: const Key('DeleteDialogBodySubmitButton'),
                      style: ButtonStyle(
                          fixedSize: MaterialStateProperty.all(const Size(100, 30)),
                          backgroundColor: MaterialStateProperty.all(Colors.black),
                          elevation: MaterialStateProperty.all(2),
                          foregroundColor: MaterialStateProperty.all(Colors.white),
                          textStyle: MaterialStateProperty.all(const TextStyle(color: Colors.white))
                      ),
                      child: Text(
                          key: const Key('DeleteDialogBodySubmitButtonText'),
                          FlutterI18n.translate(context, 'Yes')
                      ),
                      onPressed: () => _onDelete(ref)
                  ),
                  const SizedBox(
                      key: const Key('DeleteDialogBodyButtonSizedBox'),
                      width: 30
                  ),
                  OutlinedButton(
                      key: const Key('DeleteDialogBodyCancelButton'),
                      style: ButtonStyle(
                          fixedSize: MaterialStateProperty.all(const Size(100, 30)),
                          backgroundColor: MaterialStateProperty.all(Colors.white),
                          elevation: MaterialStateProperty.all(2),
                          foregroundColor: MaterialStateProperty.all(Colors.black),
                          textStyle: MaterialStateProperty.all(const TextStyle(color: Colors.black))
                      ),
                      child: Text(
                          key: const Key('DeleteDialogBodyCancelButtonText'),
                          FlutterI18n.translate(context, 'No')
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
        )
    );
  }
}