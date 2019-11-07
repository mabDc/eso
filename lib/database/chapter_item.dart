class ChapterItem {
  String cover;
  String name;
  String time;
  String url;

  ChapterItem({
    this.cover,
    this.name,
    this.time,
    this.url,
  });

  Map<String, dynamic> toJson() => {
        "cover": cover,
        "name": name,
        "time": time,
        "url": url,
      };

  ChapterItem.fromJson(Map<String, dynamic> json) {
    cover = json["cover"];
    name = json["name"];
    time = json["time"];
    url = json["url"];
  }
}
