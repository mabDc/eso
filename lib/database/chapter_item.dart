class ChapterItem {
  String contentUrl;
  String cover;
  String name;
  String time;
  String url;

  ChapterItem({
    this.contentUrl,
    this.cover,
    this.name,
    this.time,
    this.url,
  });

  Map<String, dynamic> toJson() => {
        "contentUrl": contentUrl,
        "cover": cover,
        "name": name,
        "time": time,
        "url": url,
      };

  ChapterItem.fromJson(Map<String, dynamic> json) {
    contentUrl = json["contentUrl"];
    cover = json["cover"];
    name = json["name"];
    time = json["time"];
    url = json["url"];
  }

}
