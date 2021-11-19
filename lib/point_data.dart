part of points_layer;

List<PointData> pointDataFromJson(String str) => List<PointData>.from(json.decode(str).map((x) => PointData.fromJson(x)));

String pointDataToJson(List<PointData> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PointData {
  PointData({
    this.name,
    this.id,
    this.points,
  });

  String? name;
  String? id;
  List<List<double>>? points;

  PointData copyWith({
    String? name,
    String? id,
    List<List<double>>? points,
  }) =>
      PointData(
        name: name ?? this.name,
        id: id ?? this.id,
        points: points ?? this.points,
      );

  factory PointData.fromJson(Map<String, dynamic> json) => PointData(
        name: json["name"] == null ? null : json["name"],
        id: json["id"] == null ? null : json["id"],
        points: json["points"] == null ? null : List<List<double>>.from(json["points"].map((x) => List<double>.from(x.map((x) => x.toDouble())))),
      );

  Map<String, dynamic> toJson() => {
        "name": name == null ? null : name,
        "id": id == null ? null : id,
        "points": points == null ? null : List<dynamic>.from(points!.map((x) => List<dynamic>.from(x.map((x) => x)))),
      };
}
