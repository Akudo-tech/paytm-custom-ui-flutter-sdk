import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'paytm_custom_ui_method_channel.dart';

abstract class PaytmCustomUiPlatform extends PlatformInterface {
  /// Constructs a PaytmCustomUiPlatform.
  PaytmCustomUiPlatform() : super(token: _token);

  static final Object _token = Object();

  static PaytmCustomUiPlatform _instance = MethodChannelPaytmCustomUi();

  /// The default instance of [PaytmCustomUiPlatform] to use.
  ///
  /// Defaults to [MethodChannelPaytmCustomUi].
  static PaytmCustomUiPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PaytmCustomUiPlatform] when
  /// they register themselves.
  static set instance(PaytmCustomUiPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool> isPaytmAppInstalled() {
    throw UnimplementedError('isPaytmAppInstalled() has not been implemented');
  }

  Future<String> fetchAuthCode(String clientId, String mid) {
    throw UnimplementedError("fetchAuthCode() has not been implemented");
  }

  Future doCardPayment(
    String mid,
    String orderId,
    String txnToken,
    num amount,
    String paymentMode,
    String paymentFlow,
    String? cardNumber,
    String? cardId,
    String? cardCvv,
    String? cardExpiry,
    String? bankCode,
    String? channelCode,
    String authMode,
    String? emiPlanId,
    bool shouldSaveCard,
    bool isEligibleForCoFT,
    bool isUserConsentGiven,
    bool isCardPTCInfoRequired,
    String callbackURL,
  ) {
    throw UnimplementedError("doCardPayment() has not been implemented");
  }

  Future doUpiIntentPayment(
    String mid,
    String orderId,
    String txnToken,
    num amount,
    String paymentFlow,
    String appId,
  ) {
    throw UnimplementedError("doCardPayment() has not been implemented");
  }

  Future doUpiCollectPayment(
    String mid,
    String orderId,
    String txnToken,
    num amount,
    String paymentFlow,
    String vpa,
    bool saveVPA,
  ) {
    throw UnimplementedError("doCardPayment() has not been implemented");
  }

  Future setStaging() {
    throw UnimplementedError("setStaging() has not been implemented");
  }

  Future doNBPayment(
    String mid,
    String orderId,
    String txnToken,
    num amount,
    String paymentFlow,
    String bankCode,
    String callbackURL,
  ) {
    throw UnimplementedError("doNBPayment() has not been implemented");
  }

  Future getUpiApps() {
    throw UnimplementedError("getUpiApps has not been implemented");
  }
}
