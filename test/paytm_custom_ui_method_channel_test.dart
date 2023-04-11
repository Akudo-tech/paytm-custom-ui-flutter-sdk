import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paytm_custom_ui/paytm_custom_ui_method_channel.dart';

void main() {
  MethodChannelPaytmCustomUi platform = MethodChannelPaytmCustomUi();
  const MethodChannel channel = MethodChannel('paytm_custom_ui');

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
    expect(await platform.getPlatformVersion(), '42');
  });
}
