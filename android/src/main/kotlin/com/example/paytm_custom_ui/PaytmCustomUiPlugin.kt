package com.example.paytm_custom_ui

import android.app.ActionBar.LayoutParams
import android.app.Activity
import android.app.Application
import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.annotation.NonNull
import com.google.gson.Gson
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import net.one97.paytm.nativesdk.PaytmSDK
import net.one97.paytm.nativesdk.Utils.Server
import net.one97.paytm.nativesdk.app.PaytmSDKCallbackListener
import net.one97.paytm.nativesdk.common.widget.PaytmConsentCheckBox
import net.one97.paytm.nativesdk.dataSource.PaytmPaymentsUtilRepository
import net.one97.paytm.nativesdk.dataSource.UpiAppListListener
import net.one97.paytm.nativesdk.dataSource.models.CardRequestModel
import net.one97.paytm.nativesdk.dataSource.models.NetBankingRequestModel
import net.one97.paytm.nativesdk.dataSource.models.UpiCollectRequestModel
import net.one97.paytm.nativesdk.dataSource.models.UpiIntentRequestModel
import net.one97.paytm.nativesdk.instruments.upicollect.models.UpiOptionsModel
import net.one97.paytm.nativesdk.transcation.model.TransactionInfo
import java.io.ByteArrayOutputStream


/** PaytmCustomUiPlugin */
class PaytmCustomUiPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private val paymentsUtilRepository: PaytmPaymentsUtilRepository =
        PaytmSDK.getPaymentsUtilRepository()

    private lateinit var activity: Activity;

    private var isStaging =false
    private var isConnected = false

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {

        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "paytm_custom_ui")
        channel.setMethodCallHandler(this)
        flutterPluginBinding.applicationContext.let {
            val app = flutterPluginBinding.applicationContext as Application?
//            if (app != null) {
//                context = app
//            }
            PaytmSDK.init(app)
        }
        flutterPluginBinding
            .platformViewRegistry
            .registerViewFactory("paytm_custom_ui-checkbox", NativeViewFactory())

    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "setStaging") {
            setStaging()
            isStaging=true
            result.success(true)
        } else if (call.method == "getPlatformVersion") {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        } else if (call.method == "isPaytmAppInstalled") {
            result.success(paymentsUtilRepository.isPaytmAppInstalled(activity));
        } else if (call.method == "fetchAuthCode") {
            val clientId = call.argument<String>("clientId");
            val mid = call.argument<String>("mid");
            if (clientId != null && mid != null) {
                val res = paymentsUtilRepository.fetchAuthCode(activity, clientId, mid);
                result.success(res)
            } else {
                result.error(
                    "EC-PAYTM-REQ-VAL-NULL",
                    "client id or mid null",
                    "client id or mid null"
                )
            }
        } else if (call.method == "doCardPayment") {

            val mid = call.argument<String>("mid") ?: run {
                result.error("NULL-VALUE", "mid cant be null", "mid is null")
                return
            }
            val orderId = call.argument<String>("orderId") ?: run {
                result.error("NULL-VALUE", "orderId cant be null", "orderId is null")
                return
            }
            val txnToken = call.argument<String>("txnToken") ?: run {
                result.error("NULL-VALUE", "orderId cant be null", "orderId is null")
                return
            }
            val amount = call.argument<Number>("amount") ?: run {
                result.error("NULL-VALUE", "amount cant be null", "amount is null")
                return
            }
            val paymentMode = call.argument<String>("paymentMode") ?: run {
                result.error("NULL-VALUE", "paymentMode cant be null", "paymentMode is null")
                return
            }
            val paymentFlow = call.argument<String>("paymentFlow") ?: run {
                result.error("NULL-VALUE", "paymentFlow cant be null", "paymentFlow is null")
                return
            }
            val shouldSaveCard = call.argument<Boolean>("shouldSaveCard") ?: run {
                result.error("NULL-VALUE", "shouldSaveCard cant be null", "shouldSaveCard is null")
                return
            }
            val isEligibleForCoFT = call.argument<Boolean>("isEligibleForCoFT") ?: run {
                result.error(
                    "NULL-VALUE",
                    "isEligibleForCoFT cant be null",
                    "isEligibleForCoFT is null"
                )
                return
            }
            val isUserConsentGiven = call.argument<Boolean>("isUserConsentGiven") ?: run {
                result.error(
                    "NULL-VALUE",
                    "isUserConsentGiven cant be null",
                    "isUserConsentGiven is null"
                )
                return
            }
            val isCardPTCInfoRequired = call.argument<Boolean>("isCardPTCInfoRequired") ?: run {
                result.error(
                    "NULL-VALUE",
                    "isCardPTCInfoRequired cant be null",
                    "isCardPTCInfoRequired is null"
                )
                return
            }

            val callbackURL = call.argument<String>("callbackURL") ?: run {
                result.error("NULL-VALUE", "callbackURL cant be null", "callbackURL is null")
                return
            }
            doCardTransaction(
                mid,
                orderId,
                txnToken,
                amount.toDouble(),
                paymentMode,
                paymentFlow,
                call.argument("cardNumber"),

                call.argument("cardId"),

                call.argument("cardCvv"),

                call.argument("cardExpiry"),

                call.argument("bankCode"),

                call.argument("channelCode"),

                call.argument("authMode") ?: run {
                    result.error("NULL-VALUE", "authMode cant be null", "authMode is null")
                    return
                },

                call.argument("emiPlanId"),
                callbackURL,
                shouldSaveCard,
                isEligibleForCoFT,
                isUserConsentGiven,
                isCardPTCInfoRequired,

                result

            )
        } else if (call.method == "getUpiApps") {
            val apps = getUpiApps(result)
        } else if (call.method == "doUpiIntentPayment") {
            val mid = call.argument<String>("mid") ?: run {
                result.error("NULL-VALUE", "mid cant be null", "mid is null")
                return
            }
            val orderId = call.argument<String>("orderId") ?: run {
                result.error("NULL-VALUE", "orderId cant be null", "orderId is null")
                return
            }
            val txnToken = call.argument<String>("txnToken") ?: run {
                result.error("NULL-VALUE", "orderId cant be null", "orderId is null")
                return
            }
            val amount = call.argument<Number>("amount") ?: run {
                result.error("NULL-VALUE", "amount cant be null", "amount is null")
                return
            }
            val paymentFlow = call.argument<String>("paymentFlow") ?: run {
                result.error("NULL-VALUE", "paymentFlow cant be null", "paymentFlow is null")
                return
            }
            val appId = call.argument<String>("appId") ?: run {
                result.error("NULL-VALUE", "appId cant be null", "appId is null")
                return
            }
            val callbackURL = call.argument<String>("callbackURL") ?: run {
                result.error("NULL-VALUE", "callbackURL cant be null", "callbackURL is null")
                return
            }
            doUpiIntentPayment(
                mid,
                orderId,
                txnToken,
                amount.toDouble(),
                appId,
                paymentFlow,

                callbackURL,
                result,
            )
        } else if (call.method == "doUpiCollectPayment") {
            val mid = call.argument<String>("mid") ?: run {
                result.error("NULL-VALUE", "mid cant be null", "mid is null")
                return
            }
            val orderId = call.argument<String>("orderId") ?: run {
                result.error("NULL-VALUE", "orderId cant be null", "orderId is null")
                return
            }
            val txnToken = call.argument<String>("txnToken") ?: run {
                result.error("NULL-VALUE", "orderId cant be null", "orderId is null")
                return
            }
            val amount = call.argument<Number>("amount") ?: run {
                result.error("NULL-VALUE", "amount cant be null", "amount is null")
                return
            }
            val paymentFlow = call.argument<String>("paymentFlow") ?: run {
                result.error("NULL-VALUE", "paymentFlow cant be null", "paymentFlow is null")
                return
            }
            val vpa = call.argument<String>("vpa") ?: run {
                result.error("NULL-VALUE", "vpa cant be null", "vpa is null")
                return
            }
            val saveVPA = call.argument<Boolean>("saveVPA") ?: run {
                result.error("NULL-VALUE", "saveVPA cant be null", "saveVPA is null")
                return
            }
            val callbackURL = call.argument<String>("callbackURL") ?: run {
                result.error("NULL-VALUE", "callbackURL cant be null", "callbackURL is null")
                return
            }

            doUpiCollectPayment(
                mid,
                orderId,
                txnToken,
                amount.toDouble(),
                paymentFlow,
                vpa,
                saveVPA,
                callbackURL,
                result
            );
        } else if (call.method == "doNBPayment") {
            val mid = call.argument<String>("mid") ?: run {
                result.error("NULL-VALUE", "mid cant be null", "mid is null")
                return
            }
            val orderId = call.argument<String>("orderId") ?: run {
                result.error("NULL-VALUE", "orderId cant be null", "orderId is null")
                return
            }
            val txnToken = call.argument<String>("txnToken") ?: run {
                result.error("NULL-VALUE", "orderId cant be null", "orderId is null")
                return
            }
            val amount = call.argument<Number>("amount") ?: run {
                result.error("NULL-VALUE", "amount cant be null", "amount is null")
                return
            }
            val paymentFlow = call.argument<String>("paymentFlow") ?: run {
                result.error("NULL-VALUE", "paymentFlow cant be null", "paymentFlow is null")
                return
            }
            val bankCode = call.argument<String>("bankCode") ?: run {
                result.error("NULL-VALUE", "bankCode cant be null", "bankCode is null")
                return
            }
            val callbackURL = call.argument<String>("callbackURL") ?: run {
                result.error("NULL-VALUE", "callbackURL cant be null", "callbackURL is null")
                return
            }
            doNBPayment(
                mid,
                orderId,
                txnToken,
                amount.toDouble(),
                bankCode,
                paymentFlow,
                callbackURL,
                result
            )
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        isConnected=false
    }


    private fun doCardTransaction(
        mid: String, orderId: String, txnToken: String, amount: Double,
        paymentMode: String,
        paymentFlow: String,
        cardNumber: String?,
        cardId: String?,
        cardCvv: String?,
        cardExpiry: String?,
        bankCode: String?,
        channelCode: String?,
        authMode: String,
        emiPlanId: String?,
        callbackURL: String,
        shouldSaveCard: Boolean,
        isEligibleForCoFT: Boolean,
        isUserConsentGiven: Boolean,
        isCardPTCInfoRequired: Boolean,
        result: Result,
    ) {
        var listener = PayTMResultsListener(activity,result,mid,orderId,txnToken,amount,
            if (isStaging) Server.STAGING
        else Server.PRODUCTION,
            callbackURL
            )
        val sdkBuilder =
            PaytmSDK.Builder(activity, mid, orderId, txnToken, amount, listener)

        sdkBuilder.setMerchantCallbackUrl(callbackURL)
        sdkBuilder.setAssistEnabled(true)
        val sdk = sdkBuilder.build()
        listener.sdk=sdk
        sdk.startTransaction(
            activity,
            CardRequestModel(
                paymentMode, paymentFlow,
                cardNumber, cardId, cardCvv, cardExpiry, bankCode, channelCode, authMode, emiPlanId,
                shouldSaveCard, isEligibleForCoFT, isUserConsentGiven, isCardPTCInfoRequired
            )

        )

    }


    private fun getUpiApps(result: Result) {
         PaytmSDK.getPaymentsHelper().getUpiAppsInstalled(activity,
            object : UpiAppListListener {
                override fun onUpiAppsListFetched(upiAppsInstalled: ArrayList<UpiOptionsModel>) {
                    var appIs = upiAppsInstalled.map {
                        val imageBitmap = drawableToBitmap(it.drawable)
                        var imageString: String? = null

                        if (imageBitmap != null) {

                            val byteArrayOutputStream = ByteArrayOutputStream()

                            imageBitmap.compress(
                                Bitmap.CompressFormat.PNG,
                                100,
                                byteArrayOutputStream
                            )
                            val byteArray: ByteArray = byteArrayOutputStream.toByteArray()

                            imageString = android.util.Base64.encodeToString(
                                byteArray,
                                android.util.Base64.NO_WRAP
                            )

                        }

                        var app =
                            UpiApp(it.appName, it.resolveInfo.activityInfo.packageName, imageString)
                        app.toMap()
                    }
                    val jsonConverted = Gson().toJson(appIs)

                    result.success(jsonConverted)
                }

            }
        )

    }

    private fun doUpiIntentPayment(
        mid: String,
        orderId: String,
        txnToken: String,
        amount: Double,
        appId: String,
        paymentFlow: String,
        callbackURL: String,
        result: Result
    ) {
        PaytmSDK.getPaymentsHelper().getUpiAppsInstalled(activity,
            object : UpiAppListListener {
                override fun onUpiAppsListFetched(upiAppsInstalled: ArrayList<UpiOptionsModel>) {
                    val app =
                        upiAppsInstalled.first { it.resolveInfo.activityInfo.packageName == appId }

                    activity.runOnUiThread {
                        var listener =
                            PayTMResultsListener(activity, result,mid,orderId,txnToken,amount, if (isStaging) Server.STAGING
                            else Server.PRODUCTION,callbackURL)
                        val sdk = PaytmSDK.Builder(
                            activity,
                            mid,
                            orderId,
                            txnToken,
                            amount,
                            listener
                        ).build()
                        listener.sdk = sdk
                        sdk.startTransaction(
                            activity,
                            UpiIntentRequestModel(
                                paymentFlow,
                                app.appName,
                                app.resolveInfo.activityInfo
                            )
                        )
                    }
                }

            }

        )
    }

    private fun doUpiCollectPayment(
        mid: String,
        orderId: String,
        txnToken: String,
        amount: Double,
        paymentFlow: String,
        vpa: String,
        saveVPA: Boolean,
        callbackURL: String,
        result: Result
    ) {
        var listener = PayTMResultsListener(activity, result,mid,orderId,txnToken,amount, if (isStaging) Server.STAGING
        else Server.PRODUCTION,callbackURL)
        val sdkbuilder =
            PaytmSDK.Builder(activity, mid, orderId, txnToken, amount, listener )

        sdkbuilder.setMerchantCallbackUrl(callbackURL)
        val sdk = sdkbuilder.build()
        listener.sdk = sdk
        sdk.startTransaction(activity, UpiCollectRequestModel(paymentFlow, vpa, saveVPA))
    }

    private fun doNBPayment(
        mid: String,
        orderId: String,
        txnToken: String,
        amount: Double,
        bankCode: String,
        paymentFlow: String,
        callbackURL: String,
        result: Result
    ) {
        var listener = PayTMResultsListener(activity, result,mid,orderId,txnToken,amount, if (isStaging) Server.STAGING
        else Server.PRODUCTION,callbackURL)
        val sdkbuilder =
            PaytmSDK.Builder(activity, mid, orderId, txnToken, amount,listener )

        sdkbuilder.setMerchantCallbackUrl(callbackURL)
        sdkbuilder.setAssistEnabled(true)

        val sdk = sdkbuilder.build()
        listener.sdk = sdk

        sdk.startTransaction(activity, NetBankingRequestModel(paymentFlow, bankCode))
    }

    private fun setStaging() {
        PaytmSDK.setServer(Server.STAGING)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        isConnected=true
    }

    override fun onDetachedFromActivityForConfigChanges() {

    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivity() {
        isConnected=false
    }




    inner
    class PayTMResultsListener(private val context: Activity, private val result: Result,
                               private val mid: String,
                               private val orderId: String,
                               private val txnToken: String,
                               private val amount: Double,
                               private val server: Server,
                               private val merchantCallBack: String
    ) : PaytmSDKCallbackListener {

        public var sdk:PaytmSDK? = null

        override fun networkError() {

            result.error(
                "PAYTM-NETWORK-ERROR",
                "Paytm Reported Network Error",
                "Paytm Reported Network Error"
            )
            PaytmSDK.clearPaytmSDKData()
        }

        override fun onBackPressedCancelTransaction() {
            result.error(
                "PAYTM-BACK-CANCELLED",
                "Paytm Reported BACK Cancel Transaction",
                "Paytm Reported BACK Cancel Transaction"
            )
            PaytmSDK.clearPaytmSDKData()
        }

        override fun onGenericError(p0: Int, p1: String?) {
            // 1001 - mid, orderid, txnToken null -> reinitializeParamenters
            // 1002 - static instance is null -> PaytmSDK.init
            // 1003 - close SDK
            // 1004 - onGenericError exception

            if(p0==1001 && sdk!=null){
                sdk!!.reInitialiseSdkParams(context,mid,orderId,txnToken,amount,server,merchantCallBack)
            }else if(p0==1002){
                PaytmSDK.init(context.application)
            }else{
               if(isConnected){
                   result.error("PAYTM-ERROR-GENERIC", "PAYTM Reported error code $p0 message $p1", "$p1")

               }
                PaytmSDK.clearPaytmSDKData()
            }

        }

        override fun onTransactionResponse(p0: TransactionInfo?) {
            val json = Gson().toJson(p0)
            if(isConnected) {
                result.success(json)
            }
            PaytmSDK.clearPaytmSDKData()
        }

    }

}

fun drawableToBitmap(drawable: Drawable): Bitmap {
    if (drawable is BitmapDrawable) {
        val bitmapDrawable: BitmapDrawable = drawable as BitmapDrawable
        if (bitmapDrawable.bitmap != null) {

            return bitmapDrawable.bitmap
        }
    }

    var bitmap: Bitmap = if (drawable.intrinsicWidth <= 0 || drawable.intrinsicHeight <= 0) {

        Bitmap.createBitmap(
            1,
            1,
            Bitmap.Config.ARGB_8888
        ) // Single color bitmap will be created of 1x1 pixel
    } else {

        Bitmap.createBitmap(
            drawable.intrinsicWidth,
            drawable.intrinsicHeight,
            Bitmap.Config.ARGB_8888
        )
    }

    val canvas = Canvas(bitmap)

    drawable.setBounds(0, 0, canvas.width, canvas.height)

    drawable.draw(canvas)
    return bitmap
}

class UpiApp(val name: String, val id: String, val image: String?) {
    public fun toMap(): Map<String, String?> {
        return mapOf("id" to id, "name" to name, "image" to image)
    }
}

class NativeViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as Map<String?, Any?>?
        return NativeView(context, viewId, creationParams)
    }

    internal class NativeView(context: Context, id: Int, creationParams: Map<String?, Any?>?) :
        PlatformView {
        private val view: View

        override fun getView(): View {
            return view
        }

        override fun dispose() {}

        init {
            val merchantName = creationParams?.get("merchant_name")?.toString() ?: "Merchant"
            val layoutInlator = LayoutInflater.from(context)
            view = layoutInlator.inflate(R.layout.paytmcheckout, null, false)
            view.layoutParams =
                ViewGroup.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT)
            (view as PaytmConsentCheckBox).text = "Allow $merchantName to fetch Paytm instruments"
        }
    }
}