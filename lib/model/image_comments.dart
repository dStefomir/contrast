/// Image comments data model
class ImageCommentsData {
  final int? id;
  final int? imageId;
  final String? comment;
  final DateTime? date;
  final String? deviceName;
  final double? rating;

  ImageCommentsData({
    this.id,
    this.imageId,
    this.comment,
    this.date,
    this.deviceName,
    this.rating
    });

  factory ImageCommentsData.fromJson(Map<String, dynamic> json) => ImageCommentsData(
      id: json["id"],
      imageId: json["image_id"],
      comment: json["comment"],
      date: json["date"] != null ? DateTime.parse(json["date"]) : null,
      deviceName: json["device_name"],
      rating: json["rating"]
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "image_id": imageId,
    "comment": comment,
    "date": date,
    "deviceName": deviceName,
    "rating": rating
  };
}