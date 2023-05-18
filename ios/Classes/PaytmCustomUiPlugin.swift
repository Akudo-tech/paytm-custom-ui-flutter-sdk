import Flutter
import UIKit
import PaytmNativeSDK

public class PaytmCustomUiPlugin: NSObject, FlutterPlugin {
    let appInvoke = AIHandler()

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "paytm_custom_ui", binaryMessenger: registrar.messenger())
    let instance = PaytmCustomUiPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      if (call.method == "doNBPayment"){
          if let args = call.arguments as? Dictionary<String, Any>{
              let mid = args["mid"] as? String
              let orderId = args["orderId"] as? String
              let txnToken = args["txnToken"] as? String
              let amount = args["amount"] as? NSNumber
              let paymentFlow = args["paymentFlow"] as? String
              let bankCode = args["bankCode"] as? String
              let callbackURL = args["callbackURL"] as? String
              
              let paymentModel = AINativeNBParameterModel(withTransactionToken: txnToken!, orderId: orderId!, shouldOpenNativePlusFlow: true, mid: mid!, flowType: AINativePaymentFlow.none, paymentModes: AINativePaymentModes.netBanking, channelCode: bankCode!, redirectionUrl: callbackURL!)
              let vc = UIApplication.shared.keyWindow?.rootViewController;
              let del = PaytmDelegate(uiController: vc!, result: result)
              DispatchQueue.main.async {
                  
                  self.appInvoke.callProcessTransactionAPI(selectedPayModel: paymentModel, delegate: del)
              }
           } else {
             result(FlutterError.init(code: "bad args", message: nil, details: nil))
           }
      }else  if (call.method == "doUpiIntentPayment"){
          if let args = call.arguments as? Dictionary<String, Any>{
              let mid = args["mid"] as? String
              let orderId = args["orderId"] as? String
              let txnToken = args["txnToken"] as? String
              let amount = args["amount"] as? NSNumber
              let paymentFlow = args["paymentFlow"] as? String
              let appId = args["appId"] as? String
              
              
              let vc = UIApplication.shared.delegate?.window?!.rootViewController;
              let del = PaytmDelegate(uiController: vc!, result: result)
              
              let app:PspApp
              
              switch (appId!){
              case "paytm://upi":
                  app = PspApp.paytm
              case "phonepe://upi":
                  app = PspApp.phonePe
              case "tez://upi":
                  app = PspApp.gPay
              default:
                  result(FlutterError(code: "UNSUPPORTED UPI APP", message: "UPI APP Not Supported", details: nil))
                  return
              }
              
              DispatchQueue.main.async {
                  
                  self.appInvoke.callProcessTransactionAPIForUPIIntent(orderId: orderId!, mid: mid!, txnToken: txnToken!, pspApp: app) { response, error in
                      if error != nil {
                          result(FlutterError(code: "PAYTM-ERROR-GENERIC", message: "PAYTM-CONTROLLER-EXITED \(error)", details: "PAYTM CONTROLLER EXITED \(error)"))
                                                  return
                                              }
                      
                      if let body = response?["body"] as? [String: Any], let deepLinkInfo = body["deepLinkInfo"] as? [String: Any], let deepLink = deepLinkInfo["deepLink"] as? String {
                          print(deepLink)
                          let urlString = deepLink + "&source_callback=paytmmp"
                          print(urlString)

                          if let url = URL(string: urlString) {
                              var isPaytmAppExist :Bool = false
                              if UIApplication.shared.canOpenURL(url) {
                                  isPaytmAppExist = true
                              }
                              if isPaytmAppExist {
                                  UIApplication.shared.open(url, options: [:], completionHandler: {
                                      opened in
                                      if opened {
                                          result(true)
                                      }else{
                                          result(FlutterError(code: "APP-LINK-OPEN-FAILED", message: "Cant open app link", details: "app link cannot be opened \(url)"))
                                      }
                                  })
                              } else {
                                  result(FlutterError(code: "DeepLink not supported", message: "deeplink not supported", details: "deeplink received: \(url)"))
                              }
                          }
                      } else {
                          result(FlutterError(code: "PAYTM-ERROR-GENERIC", message: "PAYTM-CONTROLLER-EXITED \(response)", details: "PAYTM CONTROLLER EXITED \(response)"))
                      }
                      
                      
                  }
              }
           } else {
             result(FlutterError.init(code: "bad args", message: nil, details: nil))
           }
      }
      
      
      else if(call.method == "doCardPayment"){
          if let args = call.arguments as? Dictionary<String, Any>{
              let mid = args["mid"] as? String
              let orderId = args["orderId"] as? String
              let txnToken = args["txnToken"] as? String
              let amount = args["amount"] as? NSNumber
              let paymentMode = args["paymentMode"] as? String
              let paymentFlow = args["paymentFlow"] as? String
              
              let shouldSaveCard = args["shouldSaveCard"] as? Bool
              let isEligibleForCoFT = args["isEligibleForCoFT"] as? Bool
              let isUserConsentGiven = args["isUserConsentGiven"] as? Bool
              let isCardPTCInfoRequired = args["isCardPTCInfoRequired"] as? Bool
              
              let cardNumber = args["cardNumber"] as? String
              let cardId = args["cardId"] as? String
              let cardCvv = args["cardCvv"] as? String
              let cardExpiry = args["cardExpiry"] as? String
              let bankCode = args["bankCode"] as? String
              let channelCode = args["channelCode"] as? String
              let authMode = args["authMode"] as? String
              let emiPlanId = args["emiPlanId"] as? String

              let callbackURL = args["callbackURL"] as? String
              
              let newCard = !(shouldSaveCard==true)
              
              let saveInstrument: String
              if shouldSaveCard==true{
                  saveInstrument = "1"
              }else{
                  saveInstrument = "0"
              }
              let expiryMonth = cardExpiry?.split(separator: "/")[0]
              let expiryYear = cardExpiry?.split(separator: "/")[1]
              let expiry = "\(expiryMonth!)20\(expiryYear!)"
              let paymentModel = AINativeSavedCardParameterModel(withTransactionToken: txnToken!, orderId: orderId!, shouldOpenNativePlusFlow: false, mid: mid!, flowType: AINativePaymentFlow.none, paymentModes: .debitCard, authMode: PaytmNativeSDK.AuthMode.otp, cardId: cardId, cardNumber: cardNumber, cvv: cardCvv, expiryDate: expiry, newCard:  true, saveInstrument: "0", redirectionUrl: callbackURL!
              )
              let vc = UIApplication.shared.keyWindow?.rootViewController;
              let del = PaytmDelegate(uiController: vc!, result: result)
              DispatchQueue.main.async {
                  
                  self.appInvoke.callProcessTransactionAPI(selectedPayModel: paymentModel, delegate: del)
              }
           } else {
             result(FlutterError.init(code: "bad args", message: nil, details: nil))
           }
      }
  }
    
    
}


class PaytmDelegate: AIDelegate {
    var uiController: UIViewController
    var result: FlutterResult
    var responsed = false
    
    init(uiController: UIViewController, result:@escaping FlutterResult) {
        self.uiController = uiController
        self.result = result
    }
    
    public func didFinish(with success: Bool, response: [String : Any], error: String?, withUserCancellation hasUserCancelledTransaction: Bool) {
        let shouldRespond = !responsed
        if !responsed{
            responsed = true
        }
        
        DispatchQueue.main.async {
            self.uiController.presentedViewController?.dismiss(animated: true, completion: nil)
            do {
                let data = try JSONSerialization.data(withJSONObject: response)
                if(shouldRespond){
                    if(hasUserCancelledTransaction){
                        self.result(FlutterError(code: "PAYTM-BACK-CANCELLED", message: "Paytm Reported BACK Cancel Transaction", details: "Paytm Reported BACK Cancel Transaction"))
                    }else{
                        self.result(data)
                    }
                }
            }catch {
                if(shouldRespond){
                    self.result(FlutterError(code: "PAYTM-ERROR-GENERIC", message: "PAYTM-CONTROLLER-EXITED", details: "PAYTM CONTROLLER EXITED"))
                }
            }
        }
    }
    
    public func openPaymentController(_ controller: UIViewController) {
        let vc = PaytmViewController()
        vc.mainView = controller
        vc.callback = {
            if !self.responsed{
                self.result(FlutterError(code: "PAYTM-ERROR-GENERIC", message: "PAYTM-CONTROLLER-EXITED", details: "PAYTM CONTROLLER EXITED"))
            }
        }
        uiController.present(vc, animated: true)
    }
}


final class PaytmViewController: UIViewController {
    
    public var mainView: UIViewController?;
    
    public var callback: (()->Void)?;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(mainView!)



        view.addSubview(mainView!.view)
        mainView!.didMove(toParent: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if isBeingDismissed {
            callback!()
        }
    }
}
