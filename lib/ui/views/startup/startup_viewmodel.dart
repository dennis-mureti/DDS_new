import 'package:distributor/app/locator.dart';
import 'package:distributor/app/router.gr.dart';
import 'package:distributor/services/api_service.dart';
import 'package:distributor/services/init_service.dart';
import 'package:distributor/services/user_service.dart';
import 'package:distributor/services/version_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';

class StartupViewModel extends BaseViewModel {
  final NavigationService _navigationService = locator<NavigationService>();
  final InitService _initService = locator<InitService>();
  UserService _userService = locator<UserService>();
  AuthenticationService get authenticationService => AuthenticationService(api);
  final ApiService _apiService = locator<ApiService>();
  final _versionService = locator<VersionService>();

  Api get api => _apiService.api;

  AppEnv get appEnv => _initService.appEnv;

  login(String userId, String password) async {
    var result = await authenticationService.loginWithUserIdAndPassword(
        userId: userId, password: password);
    ;
    if (result is User) {
      _userService.updateUser(result);
      _navigationService.pushNamedAndRemoveUntil(Routes.homeView);
    } else {
      _navigationService.navigateTo(Routes.loginView,
          arguments: LoginViewArguments(userId: userId, password: password));
    }
  }

  Future handleStartUpLogic() async {
    bool result = await _initService.init();

    await _versionService.getVersion();
    String userId;
    String password;
    if (!result) {
      userId = "";
      password = "";
      _navigationService.navigateTo(Routes.loginView,
          arguments: LoginViewArguments(userId: userId, password: password));
    } else {
      if (result) {
        userId = _initService.userId ?? "";
        password = _initService.password ?? "";
        // login(email, password);a
        _navigationService.navigateTo(Routes.loginView,
            arguments: LoginViewArguments(userId: userId, password: password));
      }
    }
  }

  // List of environments
  List<AppEnv> get availableEnvList => _initService.availableEnvList;

  updateEnv(AppEnv appEnv) {
    _initService.updateAppEnv(appEnv);
    notifyListeners();
  }
}
