import "package:test/test.dart";
import 'package:webdav/webdav.dart' as webdav;

void main() {
  webdav.Client _client =
      webdav.Client("https://dav.jianguoyun.com/dav", "username", "password");

  test('ls command', () async {
    List<webdav.FileInfo> list = await _client.ls();
    for (webdav.FileInfo item in list) {
      print(item.path);
      print(
          "     - ${item.contentType} | ${item.size},  | ${item.creationTime},  | ${item.modificationTime}");
    }
  });
  test('mkdir & mkdirs &cd & rmdir command', () async {
    await _client.mkdir("test0");
    _client.cd("test0");
    await _client.mkdirs("test1/test2");
    await _client.rmdir("/test0");
  });
}
