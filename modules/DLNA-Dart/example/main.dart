import 'package:dlna/dlna.dart';

Future<void> main() async {
  var dlnaService = DLNAManager();
  dlnaService.setRefresher(DeviceRefresher(onDeviceAdd: (dlnaDevice) {
    print('\n${DateTime.now()}\nadd ' + dlnaDevice.toString());
  }, onDeviceRemove: (dlnaDevice) {
    print('\n${DateTime.now()}\nremove ' + dlnaDevice.toString());
  }, onDeviceUpdate: (dlnaDevice) {
    print('\n${DateTime.now()}\nupdate ' + dlnaDevice.toString());
  }, onSearchError: (error) {
    print(error);
  }, onPlayProgress: (positionInfo) {
    print('current play progress ' + positionInfo.relTime);
  }));
  dlnaService.startSearch();
}
