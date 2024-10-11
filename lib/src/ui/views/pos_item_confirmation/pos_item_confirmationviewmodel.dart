import 'package:distributor/app/locator.dart';
import 'package:distributor/services/adhoc_cart_service.dart';
import 'package:distributor/src/ui/views/pos/payment_view/payment_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class POSItemConfirmationViewModel extends ReactiveViewModel {
  final navigationService = locator<NavigationService>();
  final _adhocCartService = locator<AdhocCartService>();

  List get items =>
      _adhocCartService.itemsInCart.where((item) => item.quantity > 0).toList();

  navigateToAddPayment() async {
    await navigationService.navigateToView(
      PaymentView(
        items: _adhocCartService.itemsInCart
            .where((item) => item.quantity > 0)
            .toList(),
        total: _adhocCartService.total,
      ),
    );
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_adhocCartService];

  void deleteItem(item) {
    _adhocCartService.deleteItem(item);
    notifyListeners();
  }
}
