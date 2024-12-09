//Handles initializaton and startup
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripletriocore/tripletriocore.dart';

class InitService {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // //Battery method channel
  // static const methodChannel = MethodChannel("tech.ddsolutions.app/method");
  //
  // static const batteryChannel = EventChannel("tech.ddsolutions.app/battery");
  //
  // static const networkConnectivityChannel =
  //     EventChannel("tech.ddsolutions.app/network");

  InitService() {
    fetchDeviceInfo();
  }

  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  SharedPreferences prefs;

  AndroidDeviceInfo _androidDeviceInfo;
  AndroidDeviceInfo get androidDeviceInfo => _androidDeviceInfo;

  //Fetch the device info for android
  fetchDeviceInfo() async {
    var result = await deviceInfoPlugin.androidInfo;
    if (result is AndroidDeviceInfo) {
      _androidDeviceInfo = result;
    }
    return result;
  }

  updateAppEnv(AppEnv appEnv) {
    _appEnv = appEnv;
    // print(_appEnv.flavorValues.baseUrl);
  }

  bool _rememberMe;
  bool get rememberMe => _rememberMe;

  String _userId;
  String get userId => _userId;

  String _password;
  String get password => _password;

  AppEnv _appEnv;
  AppEnv get appEnv {
    if (_appEnv == null) {
      _appEnv = _availableEnvList.first;
    }

    return _appEnv;
  }

  setAvailableEnvList(List<AppEnv> appEnv) {
    _availableEnvList = appEnv;
  }
  // List<AppEnv> _availableEnvList = Configs.appEnvList;

  List<AppEnv> _availableEnvList;
  List<AppEnv> get availableEnvList => _availableEnvList;

  Future<bool> init() async {
    prefs = await _prefs;
    if (prefs.containsKey('rememberMe')) {
      _rememberMe = await prefs.getBool('rememberMe');
      await fetchUserCredentials();
      return true;
    } else {
      _rememberMe = false;
      return false;
    }
  }

  Future<bool> toggleSavePassword(bool value) async {
    if (value) {
      return await prefs.setBool('rememberMe', value);
    } else {
      return await prefs.setBool('rememberMe', value);
    }
  }

  saveUserCredentials({String userId, String password}) async {
    await prefs.setString('userId', userId);
    await prefs.setString('password', password);
  }

  fetchUserCredentials() async {
    if (prefs.containsKey('userId')) {
      _userId = await prefs.getString('userId');
    }
    if (prefs.containsKey('password')) {
      _password = await prefs.getString('password');
    }
    return true;
  }

  // Check if user has saved credentials
  setSavePassword(bool value) async {}
}
