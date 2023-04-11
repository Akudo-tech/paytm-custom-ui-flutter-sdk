import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:paytm_custom_ui/paytm_custom_ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _paytmCustomUiPlugin = PaytmCustomUi();
  bool? isPaytmAppInstalled;
  List<UpiApp>? upiApps;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _paytmCustomUiPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    isPaytmAppInstalled = await _paytmCustomUiPlugin.isPaytmAppInstalled();

    upiApps = await _paytmCustomUiPlugin.getUpiApps();

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 50,
              // color: Colors.red,
              child: PaytmCheckBox(
                merchantName: 'Akudo',
              ),
            ),
            Container(
              // color: Colors.red,
              child: Text("is Paytm App installed $isPaytmAppInstalled"),
            ),
            if (upiApps != null)
              Container(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...upiApps!.map(
                        (e) => InkWell(
                          onTap: () async {
                            try {
                              var res = await PaytmCustomUi().doNBPayment(
                                  "eciTGc21474090466643",
                                  "clg4syogg1009185014mq54fcia7",
                                  "b5c583fee2fa42ceb8a0e593d64045f01680766475528",
                                  10,
                                  "NONE",
                                  "HDFC",
                                  "test");
                              // var res =   await PaytmCustomUi().doUpiIntentPayment("eciTGc21474090466643", "clg2d0nez1447207010f42k5v18x", "36dbcdd4e3254b018234ba230b6f12501680618761226", 10, "NONE", e.id);
                              print(res);
                            } catch (e) {
                              print(e);
                            }
                          },
                          child: Column(
                            children: [
                              Image.memory(base64Decode(e.imagebase64)),
                              Text(e.name),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ElevatedButton(
              onPressed: () async {
                try {
                  var res = await PaytmCustomUi().fetchAuthCode(
                      'merchant-akudo-uat', 'OMrtUM57689555494492');

                  print(res);
                } catch (e) {
                  print(e);
                }
              },
              child: Text("do payment"),
            )
          ],
        ),
      ),
    );
  }
}
