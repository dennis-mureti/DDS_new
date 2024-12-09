import 'package:distributor/app/locator.dart';
import 'package:distributor/app/router.gr.dart';
import 'package:distributor/core/enums.dart';
import 'package:distributor/core/models/app_version.dart';
import 'package:distributor/services/activity_service.dart';
import 'package:distributor/services/api_service.dart';
import 'package:distributor/services/init_service.dart';
import 'package:distributor/services/location_repository.dart';
import 'package:distributor/services/timeout_service.dart';
import 'package:distributor/services/user_service.dart';
import 'package:distributor/services/version_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';

class LoginViewModel extends BaseViewModel {
  final NavigationService _navigationService = locator<NavigationService>();
  final snackBarService = locator<SnackbarService>();

  ActivityService _activityService = locator<ActivityService>();

  InitService _initService = locator<InitService>();
  TimeoutService _timerService = locator<TimeoutService>();

  final _versionService = locator<VersionService>();
  final locationService = locator<LocationRepository>();
  final dialogService = locator<DialogService>();

  bool get enableOffline =>
      _initService
          .appEnv.flavorValues.applicationParameter?.enableOfflineService ??
      false;

  // final geofenceService = locator<GeoFenceService>();

  AppVersion _appVersion;

  AppVersion get appVersion => _appVersion;

  List<AppEnv> get environments => _initService.availableEnvList;

  List<String> get languages => <String>[
        'English',
        'Swahili',
      ];

  String _language;
  String get language => _language ?? languages.first;
  setLanguage(String val) {
    _language = val;
    notifyListeners();
  }

  LoginViewModel(String userId, String password)
      : _userId = userId,
        _password = password {
    _versionService.downloadProgress.listen(_onDownloadUpdated);
    _versionService.downloadStatus.listen(_onDownloadComplete);
  }

  bool _hasUpdate = false;
  bool get hasUpdate => _hasUpdate;
  setHasUpdate(bool val) {
    _hasUpdate = val;
    notifyListeners();
  }

  double _downloaded = 0;
  double get downloaded => _downloaded;

  bool _updateAPK;
  bool get updateAPK => _updateAPK;
  setUpdateAPK(bool val) {
    _updateAPK = val;
    notifyListeners();
  }

  bool _isComplete = false;
  bool get isComplete => _isComplete;

  _onDownloadComplete(var data) {
    _isComplete = data;
    if (data) {
      displayInstallDialog();
      notifyListeners();
    }
  }

  _onDownloadUpdated(var data) async {
    _downloaded = data;
    notifyListeners();
    if (downloaded == 100) {
      var dialogResponse = await _dialogService.showConfirmationDialog(
          title: 'Download Complete', confirmationTitle: 'Install');
      if (dialogResponse.confirmed) {
        await _versionService.openFile();
      }
    }
  }

  displayInstallDialog() async {
    var dialogResponse = await _dialogService.showConfirmationDialog(
        title: 'Download Complete', confirmationTitle: 'Install');
    if (dialogResponse.confirmed) {
      return await _versionService.openFile();
    }
  }

  init() async {
    _rememberMe = _initService.rememberMe;
    await initialiseAppEnvironment();
  }

  onDispose() {
    super.dispose();
  }

  initialiseAppEnvironment() async {
    setInitScript("Preparing environment");
    setBusy(true);
    await _versionService.getVersion().then((value) async {
      _appVersion = value;
      _versionCode = _appVersion.versionCode.toString();
      // await checkForUpdates();
    });
    setBusy(false);
    notifyListeners();
  }

  ///
  /// Fetch the application configurations for this application id
  ///
  fetchRemoteApplicationConfigurations() async {}

  checkForUpdates() async {
    setBusy(true);
    AppVersion remoteVersion;
    bool result = await _versionService
        .checkForUpdates(appVersion.tenantId)
        .then((value) {
      remoteVersion = value;
      return _versionService.compareVersions(
          appVersion1: appVersion, appVersion2: value);
    });
    //Compare the versions
    setBusy(false);
    if (result) {
      setHasUpdate(true);
      var dialogResponse = await _dialogService.showConfirmationDialog(
          title: 'Update DDS',
          description: 'DDS recommends that you update to the latest version.\n'
              'You are currently using ${appVersion.versionCode}. The latest version is ${remoteVersion.versionCode}',
          confirmationTitle: 'Update');
      if (dialogResponse.confirmed) {
        snackBarService.showSnackbar(message: 'Download started');
        await _versionService.downloadAndUpdate(
            remoteVersion.remoteUrl, remoteVersion.versionCode);
        snackBarService.showSnackbar(
            message: 'Download Completed',
            onTap: (_) => _versionService.openFile());
      }
    }
  }

  double _downloadProgress;
  double get downloadProgress => _downloadProgress ?? 0;

  bool _rememberMe;
  bool get rememberMe => _rememberMe;

  toggleSavePassword(bool val) async {
    _rememberMe = !rememberMe;
    await _initService.toggleSavePassword(val);
    notifyListeners();
  }

  updateEnv(AppEnv val) {
    _initService.updateAppEnv(val);
    notifyListeners();
  }

  AppEnv get _appEnv => _initService.appEnv;
  AppEnv get appEnv => _appEnv;

  final ApiService _apiService = locator<ApiService>();
  final DialogService _dialogService = locator<DialogService>();
  final UserService _userService = locator<UserService>();

  AuthenticationService get authenticationService => AuthenticationService(api);
  Api get api => _apiService.api;

  String _versionCode;
  String get versionCode => _versionCode;

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;
  toggleObscurePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  String _emailValidationMessage;
  String get emailValidationMessage => _emailValidationMessage;

  String _passwordValidationMessage;
  String get passwordValidationMessage => _passwordValidationMessage;

  String _password;
  String get password => _password;

  login() async {
    setBusy(true);
    var result;
    if (rememberMe) {
      await _initService.saveUserCredentials(
          userId: userId, password: password);
    }

    result = await authenticationService.loginWithUserIdAndPassword(
        userId: userId, password: password);

    if (result is User) {
      // Clear the cache
      await api.clearAPICache();
      // Update the user

      _userService.updateUser(result);
      //Initialize the timer
      _timerService.init();

      // Update the activity Service
      _activityService.addActivity(Activity(
          activityTitle: 'Login in', activityDesc: 'Logged In successfully'));
      // Start listening to location stream updates
      if (result.status != 1) {
        _navigationService.pushNamedAndRemoveUntil(Routes.changePasswordView,
            arguments: ChangePasswordViewArguments(
                passwordChangeType: PasswordChangeType.initial));
      } else {
        if (enableOffline) {
          snackBarService.showSnackbar(
              message: 'Data Synchronization started', title: "");
          await initializeAppCache(result);
          snackBarService.showSnackbar(
              message: 'Data Synchronization completed', title: "");
        }
        _navigationService.pushNamedAndRemoveUntil(Routes.homeView);
      }
    } else if (result is CustomException) {
      await _dialogService.showDialog(
          title: 'Login Failure', description: result.description);
    } else {
      await _dialogService.showDialog(
          title: 'Login Failure', description: 'Unknown Error.');
    }
    setBusy(false);
  }

  bool _displayInitDialog = false;
  bool get displayInitDialog => _displayInitDialog;
  setDisplayInitDialog(bool value) {
    _displayInitDialog = value;
    notifyListeners();
  }

  initializeAppCache(User user) async {
    await api.initializeAppCache(user);
  }

  void updatePassword(String value) {
    if (value.isNotEmpty) {
      _password = value.trim();
      notifyListeners();
    }
  }

  void navigateToForgotPassword() async {
    await _navigationService.navigateTo(Routes.resetPasswordView);
  }

  String _initScript = "";
  String get initScript => _initScript;
  setInitScript(String val) {
    _initScript = val;
    notifyListeners();
  }

  String _userId;
  String get userId => _userId;
  setUserId(String val) {
    if (val.isNotEmpty) {
      _userId = val.trim();
    }
  }

  // @override
  // Stream<GeofenceStatus> get stream => geofenceService.getGeofenceStream();
  //
  // get enableSignIn {
  //   switch (data) {
  //     case GeofenceStatus.init:
  //       return false;
  //     case GeofenceStatus.exit:
  //       return false;
  //     case GeofenceStatus.enter:
  //       return true;
  //   }
  // }
}
