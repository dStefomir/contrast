import 'package:contrast/common/widgets/icon.dart';
import 'package:contrast/model/image_data.dart';
import 'package:contrast/model/video_data.dart';
import 'package:contrast/modules/board/overlay/delete/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Renders a delete item dialog
class DeleteDialog<T> extends HookConsumerWidget {
  // Image Entity is passed for deleting
  final T data;

  const DeleteDialog({Key? key, required this.data,}) : super(key: key);

  /// What happens when the user agrees to delete an item
  void _onDelete(WidgetRef ref) async {
    final deleteProvider = ref.read(deleteEntriesProvider.notifier);
    if(_isImage()) {
      Modular.to.pop(deleteProvider.deletePhotograph(data as ImageData));
    } else {
      Modular.to.pop(deleteProvider.deleteVideo(data as VideoData));
    }
  }

  // Checks if dta is actually ImageData or VideoData
  bool _isImage() => data is ImageData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
        title: Center(
            child: Row(
              children: [
                const IconRenderer(
                  asset: 'warning.svg',
                  color: Colors.black,
                ),
                const SizedBox(width: 10,),
                Text("Warning", style: Theme.of(context).textTheme.headlineMedium),
              ],
            )
        ),
        content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) =>
                Text(_isImage() ? 'Delete this photo?' : 'Delete this video?', style: Theme.of(context).textTheme.headlineSmall)
        ),
        actions: [
          OutlinedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.white),
                  elevation: MaterialStateProperty.all(2),
                  foregroundColor: MaterialStateProperty.all(Colors.black),
                  textStyle: MaterialStateProperty.all(const TextStyle(color: Colors.black))
              ),
              child: const Text("No"),
              onPressed: () => Navigator.of(context).pop()
          ),
          OutlinedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black),
                  elevation: MaterialStateProperty.all(2),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  textStyle: MaterialStateProperty.all(const TextStyle(color: Colors.white))
              ),
              child: const Text("Yes"),
              onPressed: () => _onDelete(ref))
        ]
    );
  }
}
