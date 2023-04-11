import 'package:flutter_test/flutter_test.dart';
import 'package:paytm_custom_ui/paytm_custom_ui.dart';
import 'package:paytm_custom_ui/paytm_custom_ui_platform_interface.dart';
import 'package:paytm_custom_ui/paytm_custom_ui_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPaytmCustomUiPlatform
    with MockPlatformInterfaceMixin
    implements PaytmCustomUiPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final PaytmCustomUiPlatform initialPlatform = PaytmCustomUiPlatform.instance;

  test('$MethodChannelPaytmCustomUi is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPaytmCustomUi>());
  });

  test('getPlatformVersion', () async {
    PaytmCustomUi paytmCustomUiPlugin = PaytmCustomUi();
    MockPaytmCustomUiPlatform fakePlatform = MockPaytmCustomUiPlatform();
    PaytmCustomUiPlatform.instance = fakePlatform;

    expect(await paytmCustomUiPlugin.getPlatformVersion(), '42');
  });
}
