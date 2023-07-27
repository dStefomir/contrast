/// Video data model
class VideoData {
  final int? id;
  final String? path;
  final String? category;
  final String? comment;
  final int? hidden;

  VideoData({
    this.id,
    this.path,
    this.category,
    this.comment,
    this.hidden
    });

  factory VideoData.fromJson(Map<String, dynamic> json) => VideoData(
      id: json["id"],
      path: json["video_path"],
      category: json["category"],
      comment: json["comment"],
      hidden: json["hidden"]
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "video_path": path,
    "category": category,
    "comment": comment,
    "hidden": hidden
  };
}
