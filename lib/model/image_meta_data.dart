import 'package:intl/intl.dart';

/// Image metadata model
class ImageMetaData {
  final String? camera;
  final String? exposureTime;
  final String? fStop;
  final String? lens;
  final DateTime? dataOfCapture;

  ImageMetaData(
      {this.camera,
      this.exposureTime,
      this.fStop,
      this.lens,
      this.dataOfCapture,
      });

  factory ImageMetaData.fromJson(Map<String, dynamic> json) => ImageMetaData(
        camera: json["camera"],
        exposureTime: json["shutter_speed"],
        fStop: json["aperture"],
        lens: json["lens"],
        dataOfCapture: json["shot_on"] != null
            ? DateFormat('yyyy:MM:dd').parse(json["shot_on"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "camera": camera,
        "shutter_speed": exposureTime,
        "aperture": fStop,
        "lens": lens,
        "shot_on": dataOfCapture,
      };
}
