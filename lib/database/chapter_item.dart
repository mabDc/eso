class ChapterItem{
  String cover;
  String name;
  String time;
  String url;
  int chapterNum;

  ChapterItem({
    this.cover,
    this.name,
    this.time,
    this.url,
    this.chapterNum,
  });

  Map<String, dynamic> toJson() => {
    "cover":cover,
    "name":name,
    "time":time,
    "url":url,
    "chapterNum":chapterNum,
  };

  ChapterItem.fromJson(Map<String, dynamic> json){
    cover=json["cover"];
    name=json["name"];
    time=json["time"];
    url=json["url"];
    chapterNum=json["chapterNum"];
  }
}