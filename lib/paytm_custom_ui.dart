import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';

import 'paytm_custom_ui_platform_interface.dart';

class PaytmCustomUi {
  Future<String?> getPlatformVersion() {
    return PaytmCustomUiPlatform.instance.getPlatformVersion();
  }

  Future<bool> isPaytmAppInstalled() {
    return PaytmCustomUiPlatform.instance.isPaytmAppInstalled();
  }

  Future<String> fetchAuthCode(String clientId, String mid) {
    return PaytmCustomUiPlatform.instance.fetchAuthCode(clientId, mid);
  }

  Future doUpiIntentPayment(
    String mid,
    String orderId,
    String txnToken,
    num amount,
    String paymentFlow,
    String appId,
  ) {
    return PaytmCustomUiPlatform.instance
        .doUpiIntentPayment(mid, orderId, txnToken, amount, paymentFlow, appId);
  }

  Future doNBPayment(String mid, String orderId, String txnToken, num amount,
      String paymentFlow, String bankCode, String callbackURL) {
    return PaytmCustomUiPlatform.instance.doNBPayment(
        mid, orderId, txnToken, amount, paymentFlow, bankCode, callbackURL);
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
    return PaytmCustomUiPlatform.instance.doCardPayment(
        mid,
        orderId,
        txnToken,
        amount,
        paymentMode,
        paymentFlow,
        cardNumber,
        cardId,
        cardCvv,
        cardExpiry,
        bankCode,
        channelCode,
        authMode,
        emiPlanId,
        shouldSaveCard,
        isEligibleForCoFT,
        isUserConsentGiven,
        isCardPTCInfoRequired,
        callbackURL);
  }

  Future<List<UpiApp>> getUpiApps() async {
    var apps = await PaytmCustomUiPlatform.instance.getUpiApps();
    var jsonData = json.decode(apps);
    var upiApps = (jsonData as List).map((e) {
      var image = base64.decode(e['image']);
      return UpiApp(e['id'], e['name'], image);
    }).toList();
    return upiApps;
  }
}

class UpiApp {
  final String id;
  final String name;
  final Uint8List image;

  UpiApp(this.id, this.name, this.image);
}

class PaytmCheckBox extends StatelessWidget {
  final String merchantName;

  const PaytmCheckBox({Key? key, required this.merchantName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This is used in the platform side to register the view.
    const String viewType = 'paytm_custom_ui-checkbox';
    // Pass parameters to the platform side.
    Map<String, dynamic> creationParams = <String, dynamic>{
      'merchant_name': merchantName,
    };

    return AndroidView(
      viewType: viewType,
      layoutDirection: TextDirection.ltr,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}
