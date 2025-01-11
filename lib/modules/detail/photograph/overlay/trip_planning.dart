import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:contrast/common/widgets/button.dart';
import 'package:contrast/common/widgets/date.dart';
import 'package:contrast/common/widgets/shadow.dart';
import 'package:contrast/common/widgets/text.dart';
import 'package:contrast/model/image_data.dart';
import 'package:contrast/modules/board/provider.dart';
import 'package:contrast/modules/detail/photograph/overlay/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
/// Dialog height
const double dialogHeight = 500;
/// Renders the trip planning overlay
class TripPlanningOverlay extends HookConsumerWidget {

  /// Selected photograph
  final ImageData image;

  const TripPlanningOverlay({super.key, required this.image});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime? startPeriod = ref.watch(startPeriodProvider);
    final DateTime? endPeriod = ref.watch(endPeriodProvider);

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
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                          children: [
                            StyledText(
                                text: translate('Trip planning'),
                                weight: FontWeight.bold
                            ),
                            const Spacer(),
                            DefaultButton(
                                onClick: () => ref.read(overlayVisibilityProvider(const Key('trip_planning_photograph')).notifier).setOverlayVisibility(false),
                                tooltip: translate('Close'),
                                color: Colors.white,
                                borderColor: Colors.black,
                                icon: 'close.svg'
                            ),
                          ]
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: StyledText(
                          text: translate('Plan a trip to this photographic location'),
                          align: TextAlign.start,
                          fontSize: 10,
                          clip: false,
                          color: Colors.grey,
                          padding: 0
                      ),
                    ),
                    const Divider(
                        color: Colors.black
                    ),
                  ],
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          DateRangePickerWidget(
                            onSelect: (start, end) {
                              ref.read(startPeriodProvider.notifier).setPeriod(start);
                              ref.read(endPeriodProvider.notifier).setPeriod(end);
                            },
                          ),
                          const SizedBox(height: 15,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                    style: ButtonStyle(
                                        backgroundColor: WidgetStateProperty.all(startPeriod == null || endPeriod == null ? Colors.white : Colors.black),
                                        elevation: WidgetStateProperty.all(2),
                                        foregroundColor: WidgetStateProperty.all(startPeriod == null || endPeriod == null ? Colors.grey : Colors.white)
                                    ),
                                    onPressed: startPeriod == null || endPeriod == null ? null : () async {
                                      ref.read(overlayVisibilityProvider(const Key('trip_planning_photograph')).notifier).setOverlayVisibility(null);
                                      ref.read(startPeriodProvider.notifier).setPeriod(null);
                                      ref.read(endPeriodProvider.notifier).setPeriod(null);
                                      final Event event = Event(
                                        title: translate('Photographic location'),
                                        description: "${translate('You have planned a trip to a photographic location')}.\n\n${translate('Photograph')} - https://www.dstefomir.eu/#/photos/details?id=${image.id}&category=all\n\n${translate('Location')} - https://www.google.com/maps/@${image.lat},${image.lng},20.45z?entry=ttu",
                                        location: '${image.lat}, ${image.lng}',
                                        startDate: startPeriod,
                                        endDate: endPeriod,
                                        allDay: true,
                                        iosParams: const IOSParams(
                                          reminder: Duration(days: 1),
                                          url: "https://www.dstefomir.eu",
                                        ),
                                      );
                                      await Add2Calendar.addEvent2Cal(event);
                                    },
                                    child: Text(
                                        translate('Plan')
                                    )
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
      ),
    );
  }
}