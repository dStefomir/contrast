/// Image comments data model
class VideoCommentsData {
  final int? id;
  final int? videoId;
  final String? comment;
  final DateTime? date;
  final String? deviceName;
  final double? rating;

  VideoCommentsData({
    this.id,
    this.videoId,
    this.comment,
    this.date,
    this.deviceName,
    this.rating
  });

  factory VideoCommentsData.fromJson(Map<String, dynamic> json) => VideoCommentsData(
      id: json["id"],
      videoId: json["video_id"],
      comment: json["comment"],
      date: json["date"] != null ? DateTime.parse(json["date"]) : null,
      deviceName: json["device_name"],
      rating: json["rating"]
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "video_id": videoId,
    "comment": comment,
    "date": date,
    "deviceName": deviceName,
    "rating": rating
  };
}