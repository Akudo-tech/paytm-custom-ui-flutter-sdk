import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'paytm_custom_ui_platform_interface.dart';

/// An implementation of [PaytmCustomUiPlatform] that uses method channels.
class MethodChannelPaytmCustomUi extends PaytmCustomUiPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('paytm_custom_ui');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<bool> isPaytmAppInstalled() async {
    return await methodChannel.invokeMethod('isPaytmAppInstalled');
  }

  @override
  Future<String> fetchAuthCode(String clientId, String mid) async {
    return await methodChannel.invokeMethod('fetchAuthCode', {
      'clientId': clientId,
      'mid': mid,
    });
  }

  @override
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
  ) async {
    return await methodChannel.invokeMethod('doCardPayment', {
      'mid': mid,
      'orderId': orderId,
      'txnToken': txnToken,
      'amount': amount,
      'paymentMode': paymentMode,
      'paymentFlow': paymentFlow,
      'cardNumber': cardNumber,
      'cardId': cardId,
      'cardCvv': cardCvv,
      'cardExpiry': cardExpiry,
      'bankCode': bankCode,
      'channelCode': channelCode,
      'authMode': authMode,
      'emiPlanId': emiPlanId,
      'shouldSaveCard': shouldSaveCard,
      'isEligibleForCoFT': isEligibleForCoFT,
      'isUserConsentGiven': isUserConsentGiven,
      'isCardPTCInfoRequired': isCardPTCInfoRequired,
      'callbackURL': callbackURL,
    });
  }

  @override
  Future doUpiIntentPayment(
    String mid,
    String orderId,
    String txnToken,
    num amount,
    String paymentFlow,
    String appId,
  ) async {
    return await methodChannel.invokeMethod('doUpiIntentPayment', {
      'mid': mid,
      'orderId': orderId,
      'txnToken': txnToken,
      'amount': amount,
      'paymentFlow': paymentFlow,
      'appId': appId,
    });
  }

  @override
  Future doUpiCollectPayment(
    String mid,
    String orderId,
    String txnToken,
    num amount,
    String paymentFlow,
    String vpa,
    bool saveVPA,
  ) async {
    return await methodChannel.invokeMethod('doUpiCollectPayment', {
      'mid': mid,
      'orderId': orderId,
      'txnToken': txnToken,
      'amount': amount,
      'paymentFlow': paymentFlow,
      'vpa': vpa,
      'saveVPA': saveVPA,
    });
  }

  @override
  Future doNBPayment(
    String mid,
    String orderId,
    String txnToken,
    num amount,
    String paymentFlow,
    String bankCode,
    String callbackURL,
  ) async {
    return await methodChannel.invokeMethod('doNBPayment', {
      'mid': mid,
      'orderId': orderId,
      'txnToken': txnToken,
      'amount': amount,
      'paymentFlow': paymentFlow,
      'bankCode': bankCode,
      'callbackURL': callbackURL,
    });
  }

  @override
  Future getUpiApps() async {
    return await methodChannel.invokeMethod('getUpiApps');
  }

  @override
  Future setStaging() async {
    return await methodChannel.invokeMethod('setStaging');
  }
}
