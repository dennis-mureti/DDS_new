import 'package:distributor/app/locator.dart';
import 'package:distributor/app/router.gr.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class RegisterViewModel extends BaseViewModel {
  final NavigationService _navigationService = locator<NavigationService>();

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;
  toggleObscurePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void navigateToSignUp() async {
    await _navigationService.navigateTo(Routes.registerView);
  }

  void navigateToLogin() async {
    await _navigationService.navigateTo(Routes.loginView);
  }
}
