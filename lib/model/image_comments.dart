/// Image comments data model
class ImageCommentsData {
  final int? id;
  final int? imageId;
  final String? comment;
  final DateTime? date;
  final String? deviceName;
  final String? deviceId;
  final double? rating;
  final bool? approved;

  ImageCommentsData({
    this.id,
    this.imageId,
    this.comment,
    this.date,
    this.deviceName,
    this.deviceId,
    this.rating,
    this.approved
    });

  factory ImageCommentsData.fromJson(Map<String, dynamic> json) => ImageCommentsData(
      id: json["id"],
      imageId: json["image_id"],
      comment: json["comment"],
      date: json["date"] != null ? DateTime.parse(json["date"]) : null,
      deviceName: json["device_name"],
      deviceId: json["device_id"],
      rating: json["rating"],
      approved: json["approved"] ?? false
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "image_id": imageId,
    "comment": comment,
    "date": date,
    "device_name": deviceName,
    "device_id": deviceId,
    "rating": rating,
    "approved": approved
  };
}