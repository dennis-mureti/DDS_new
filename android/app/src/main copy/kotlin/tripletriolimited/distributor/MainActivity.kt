package tripletriolimited.distributor

import android.content.*
import android.hardware.Sensor
import android.hardware.SensorManager
import android.os.BatteryManager
import android.view.WindowManager.LayoutParams
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.os.Messenger
import android.print.PrintAttributes
import android.print.PrintManager
import androidx.annotation.NonNull
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    private val METHOD_CHANNEL_NAME = "tripletriolimited.distributor/method"
    private var methodChannel : MethodChannel? = null

    private lateinit var printManager : PrintManager
    private lateinit var sensorManager : SensorManager

    private val BATTERY_CHANNEL_NAME = "tech.ddsolutions.app/battery"

    private val NETWORK_CONNECTIVITY_CHANNEL_NAME = "tech.ddsolutions.app/network"

    private val PRINT_CHANNEL_NAME = "tech.ddsolutions.app/printing"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        print("in configure flutter engine")
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        super.configureFlutterEngine(flutterEngine)
        //Setup channels
        setupChannels(this,flutterEngine.dartExecutor.binaryMessenger)

//        window.addFlags(LayoutParams.FLAG_SECURE)


    }

    private fun getBatteryLevel(): Int {
        val batteryLevel: Int
        if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
            val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            val intent = ContextWrapper(applicationContext).registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            batteryLevel = intent!!.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100 / intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
        }
        return batteryLevel
    }

    private fun tearDownChannels(){
        methodChannel!!.setMethodCallHandler(null)
    }





        private fun setupChannels(context:Context, messenger: BinaryMessenger) {
            methodChannel = MethodChannel(messenger,"tripletriolimited.distributor/method")
//        printManager = context.getSystemService(Context.PRINT_SERVICE) as PrintManager
        sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager

        methodChannel!!.setMethodCallHandler {
            call,result->
            if(call.method=="isSensorAvailable") {
                result.success(sensorManager!!.getSensorList(Sensor.TYPE_PRESSURE).isNotEmpty())
            }
            else{
                result.notImplemented()
            }
        }
    }

    override fun onDestroy(){
        tearDownChannels()
        super.onDestroy();
    }




}