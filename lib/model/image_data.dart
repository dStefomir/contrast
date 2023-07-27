import 'package:contrast/model/image_meta_data.dart';
import 'package:equatable/equatable.dart';
/// Image wrapper. Contains the photograph and its meta details
class ImageWrapper extends Equatable {
  final ImageData image;
  final ImageMetaData metadata;

  ImageWrapper({
    required this.image,
    required this.metadata
});

  factory ImageWrapper.fromJson(List<dynamic> json) => ImageWrapper(
    image: ImageData.fromJson(json[0]),
    metadata: ImageMetaData.fromJson(json[1])
  );

  @override
  // TODO: implement props
  List<Object?> get props => [image.id];
}

/// Image data model
class ImageData {
  final int? id;
  final String? path;
  final bool? isLandscape;
  final bool? isRect;
  final double? dx;
  final double? dy;
  final String? category;
  final String? comment;
  final double? initialScreenWidth;
  final double? initialScreenHeight;
  double? width;
  double? height;
  final double? lat;
  final double? lng;

  ImageData({
    this.id,
    this.path,
    this.isLandscape,
    this.isRect,
    this.dx,
    this.dy,
    this.category,
    this.comment,
    this.initialScreenWidth,
    this.initialScreenHeight,
    this.width,
    this.height,
    this.lat,
    this.lng});

  factory ImageData.fromJson(Map<String, dynamic> json) => ImageData(
      id: json["id"],
      path: json["image_path"],
      isLandscape: json["landscape"],
      isRect: json["rect"],
      dx: json["dx"],
      dy: json["dy"],
      category: json["category"],
      comment: json["comment"],
      initialScreenWidth: json["initial_screen_width"],
      initialScreenHeight: json["initial_screen_height"],
      width: (!json["landscape"]) && (json["rect"]) ? 120 : (json["landscape"]) ? 150 : 100,
      height: (!json["landscape"]) && (json["rect"]) ? 120 : (json["landscape"]) ? 100 : 150,
      lat: json["lat"],
      lng: json["lng"]
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "image_path": path,
    "landscape": isLandscape,
    "rect": isRect,
    "dx": dx,
    "dy": dy,
    "category": category,
    "initial_screen_width": initialScreenWidth,
    "initial_screen_height": initialScreenHeight,
    "comment": comment,
    "lat": lat,
    "lng": lng
  };

  @override
  String toString() {
    return 'ImageData{id: $id, path: $path, isLandscape: $isLandscape, isRect: $isRect, dx: $dx, dy: $dy, category: $category, comment: $comment, initialScreenWidth: $initialScreenWidth, initialScreenHeight: $initialScreenHeight, width: $width, height: $height}';
  }
}
