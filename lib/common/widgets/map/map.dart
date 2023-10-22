import 'package:contrast/common/extentions/zoom.dart';
import 'package:contrast/common/widgets/icon.dart';
import 'package:contrast/common/widgets/map/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

/// Default zoom of the map
const double mapDefaultZoom = 13.0;
/// Max allowed zoom of the map
const double mapMaxZoom = 17.0;
/// Renders a map
class ContrastMap extends HookConsumerWidget {
  /// Flag for handling the map interaction
  final int mapInteraction;

  const ContrastMap({super.key, this.mapInteraction = InteractiveFlag.all});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MapController controller = ref.read(mapControllerProvider);
    final double lat = ref.watch(mapLatProvider);
    final double lng = ref.watch(mapLngProvider);
    useValueChanged(lat, (_, __) async {
      controller.move(LatLng(lat, lng), 13);
    });
    useValueChanged(lng, (_, __) async {
      controller.move(LatLng(lat, lng), 13);
    });

    return FlutterMap(
      mapController: controller,
      options: MapOptions(
          initialCenter: LatLng(lat, lng),
          initialZoom: mapDefaultZoom,
          interactionOptions: InteractionOptions(enableScrollWheel: true, flags: mapInteraction),
          maxZoom: mapMaxZoom,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
          // urlTemplate: "https://stamen-tiles.a.ssl.fastly.net/toner-background/{z}/{x}/{y}.png",
          subdomains: const ['a', 'b', 'c'],
        ),
        MarkerLayer(
          markers: [
            Marker(
                width: 40,
                height: 40,
                point: LatLng(lat, lng),
                child: InkWell(
                    onTap: () async {
                      final Uri url = Uri.parse('https://www.google.com/maps/@$lat,$lng,20.45z?entry=ttu');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                    child: const RotatedBox(
                        quarterTurns: 2,
                        child: IconRenderer(
                          asset: 'marker.svg',
                          color: Colors.red,
                        )
                    ).translateOnVideoHover
                )
            )
          ],
        )
      ],
    );
  }
}
