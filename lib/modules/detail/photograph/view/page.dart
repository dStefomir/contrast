import 'package:contrast/common/widgets/load.dart';
import 'package:contrast/common/widgets/map/provider.dart';
import 'package:contrast/common/widgets/text.dart';
import 'package:contrast/model/image_data.dart';
import 'package:contrast/modules/detail/photograph/provider.dart';
import 'package:contrast/modules/detail/photograph/view/details.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Renders the photograph details page
class PhotographDetailPage extends HookConsumerWidget {
  /// Constraints of the page
  final BoxConstraints constraints;
  /// Id of the photograph
  final int id;
  /// Selected photograph category
  final String category;

  const PhotographDetailPage(
      {required this.constraints,
      required this.id,
      required this.category,
      super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataProvider = ref.watch(fetchBoardProvider);

    return dataProvider.when(
        data: (data) {
          final int photoIndex = data.indexWhere((element) => element.id == id);
          /// The current photography index has to be updated when the widget tree gets rendered
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final ImageData photograph = data[photoIndex];
            if (photograph.lat != null) {
              ref.read(mapLatProvider.notifier).setCurrentLat(photograph.lat!);
            }
            if(photograph.lng != null) {
              ref.read(mapLngProvider.notifier).setCurrentLng(photograph.lng!);
            }
          });
          return PhotographDetailsView(constraints: constraints, images: data, photoIndex: photoIndex);
        },
        error: (error, stackTrace) => Center(
            child: StyledText(
              text: error.toString(),
              color: Colors.white,
              weight: FontWeight.bold,
              clip: false,
            )
        ),
        loading: () => const LoadingIndicator(color: Colors.white)
    );
  }
}
