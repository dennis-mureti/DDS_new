import 'package:distributor/app/locator.dart';
import 'package:distributor/services/stock_controller_service.dart';
import 'package:distributor/src/ui/views/pos/checkout/checkout_view.dart';
import 'package:distributor/src/ui/views/pos/confirm_cart/confirm_cart_view.dart';
import 'package:distributor/src/ui/views/pos/item_view/pos_item_view.dart';
import 'package:distributor/src/ui/views/pos/payment_view/payment_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class BasePOSViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  StockControllerService stockControllerService =
      locator<StockControllerService>();

  navigateToItem(var item) async {
    await _navigationService.navigateToView(POSItemView(
      item: item,
    ));
  }

  fetchStockBalance() async {
    return stockControllerService.getStockBalance();
  }

  void navigateToCart(List orderedItems) async {
    await _navigationService.navigateToView(ConfirmCartView(
      orderedItems: orderedItems,
    ));
  }

  void navigateToCheckOut(List orderedItems) async {
    num total = 0;
    orderedItems.forEach((element) {
      total += element['itemPrice'] * element['quantity'];
    });
    await _navigationService.navigateToView(PaymentView(
      items: orderedItems,
      total: total,
    ));
  }
}
