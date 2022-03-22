import 'package:xml/xml.dart' as xml;

class FileInfo {
  String path;
  String size;
  String modificationTime;
  DateTime creationTime;
  String contentType;

  FileInfo(this.path, this.size, this.modificationTime, this.creationTime,
      this.contentType);

  // Returns the decoded name of the file / folder without the whole path
  String get name {
    if (this.isDirectory) {
      return Uri.decodeFull(
          this.path.substring(0, this.path.lastIndexOf("/")).split("/").last);
    }

    return Uri.decodeFull(this.path.split("/").last);
  }

  bool get isDirectory => this.path.endsWith("/");

  @override
  String toString() {
    return 'FileInfo{name: $name, isDirectory: $isDirectory ,path: $path, size: $size, modificationTime: $modificationTime, creationTime: $creationTime, contentType: $contentType}';
  }
}

/// get filed [name] from the property node
String? prop(dynamic prop, String name, [String? defaultVal]) {
  if (prop is Map) {
    final val = prop['D:' + name];
    if (val == null) {
      return defaultVal;
    }
    return val;
  }
  return defaultVal;
}

List<FileInfo> treeFromWebDavXml(String xmlStr) {
  // Initialize a list to store the FileInfo Objects
  List<FileInfo> tree = new List.empty(growable: true);

  // parse the xml using the xml.parse method
  var xmlDocument = xml.XmlDocument.parse(xmlStr);

  // Iterate over the response to find all folders / files and parse the information
  findAllElementsFromDocument(xmlDocument, "response").forEach((response) {
    var davItemName = findElementsFromElement(response, "href").single.text;
    findElementsFromElement(
            findElementsFromElement(response, "propstat").first, "prop")
        .forEach((element) {
      final contentLengthElements =
          findElementsFromElement(element, "getcontentlength");
      final contentLength = contentLengthElements.isNotEmpty
          ? contentLengthElements.single.text
          : "";

      final lastModifiedElements =
          findElementsFromElement(element, "getlastmodified");
      final lastModified = lastModifiedElements.isNotEmpty
          ? lastModifiedElements.single.text
          : "";

      final creationTimeElements =
          findElementsFromElement(element, "creationdate");
      final creationTime = creationTimeElements.isNotEmpty
          ? creationTimeElements.single.text
          : DateTime.fromMillisecondsSinceEpoch(0).toIso8601String();

      // Add the just found file to the tree
      tree.add(new FileInfo(Uri.decodeComponent(davItemName), contentLength,
          lastModified, DateTime.parse(creationTime), ""));
    });
  });
  // Remove root directory
  tree.removeAt(0);
  // Return the tree
  return tree;
}

List<xml.XmlElement> findAllElementsFromDocument(
        xml.XmlDocument document, String tag) =>
    document.findAllElements(tag, namespace: '*').toList();

List<xml.XmlElement> findElementsFromElement(
        xml.XmlElement element, String tag) =>
    element.findElements(tag, namespace: '*').toList();
