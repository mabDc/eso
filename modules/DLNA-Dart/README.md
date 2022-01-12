## DLNA-Dart

A simple DLNA DMC library implemented by Dart.  
It is tiny and only the basic network video casting function is supported. 

### Structure

![structure](screen/structure.jpg)

### Flutter Demo

[Flutter-DLNA](https://github.com/succlz123/Flutter-DLNA)

### Usage

Android Manifest.xml

``` xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.CHANGE_WIFI_MULTICAST_STATE" />
```

#### Pub

[https://pub.dev/packages/dlna](https://pub.dev/packages/dlna)

#### Import

``` dart
import 'package:dlna/dlna.dart';
```

#### Start search

``` dart
var dlnaManager = DLNAManager();
dlnaManager.setRefresher(DeviceRefresher(onDeviceAdd: (dlnaDevice) {
    print('add ' + dlnaDevice.toString());
}, onDeviceRemove: (dlnaDevice) {
    print('remove ' + dlnaDevice.toString());
}, onDeviceUpdate: (dlnaDevice) {
    print('update ' + dlnaDevice.toString());
}, onSearchError: (error) {
    print(error);
}));
dlnaManager.startSearch();
```

#### Stop search

``` dart
dlnaManager.stopSearch();
```

#### Send the video url to the device

``` dart
var videoObject = VideoObject(title, url, VideoObject.VIDEO_MP4);
await dlnaManager.actSetVideoUrl(videoObject);
```

#### Release server

``` dart
dlnaManager.release();
```

#### Search Cache

For the quick search, when the device is found, it is saved locally.

``` dart
dlnaManager.enableCache();
```

``` dart
var localDevices = dlnaManager.getLocalDevices();
```
