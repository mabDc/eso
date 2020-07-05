import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eso_plugin/eso_plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel('eso_plugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await EsoPlugin.platformVersion, '42');
  });
}
