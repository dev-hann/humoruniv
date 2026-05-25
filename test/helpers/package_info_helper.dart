import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> setupPackageInfoMock() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('dev.fluttercommunity.plus/package_info');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
    if (methodCall.method == 'getAll') {
      return <String, dynamic>{
        'appName': 'HumorUniv',
        'packageName': 'com.humoruniv.app',
        'version': '1.1.0',
        'buildNumber': '2',
      };
    }
    return null;
  });
}
