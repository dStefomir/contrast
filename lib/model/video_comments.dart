/// Image comments data model
class VideoCommentsData {
  final int? id;
  final int? videoId;
  final String? comment;
  final DateTime? date;
  final String? deviceName;
  final String? deviceId;
  final double? rating;

  VideoCommentsData({
    this.id,
    this.videoId,
    this.comment,
    this.date,
    this.deviceName,
    this.deviceId,
    this.rating
  });

  factory VideoCommentsData.fromJson(Map<String, dynamic> json) => VideoCommentsData(
      id: json["id"],
      videoId: json["video_id"],
      comment: json["comment"],
      date: json["date"] != null ? DateTime.parse(json["date"]) : null,
      deviceName: json["device_name"],
      deviceId: json["device_id"],
      rating: json["rating"]
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "video_id": videoId,
    "comment": comment,
    "date": date,
    "device_name": deviceName,
    "device_id": deviceId,
    "rating": rating
  };
}