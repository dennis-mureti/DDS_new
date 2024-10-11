import 'package:distributor/app/locator.dart';
import 'package:distributor/app/router.gr.dart';
import 'package:distributor/core/models/product_service.dart';
import 'package:distributor/services/customer_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';

class ConfirmQuotationViewModel extends BaseViewModel {
  final _productService = locator<ProductService>();
  final _customerService = locator<CustomerService>();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();

  final List orderedItems;
  final Customer customer;
  final String customerCode;

  ConfirmQuotationViewModel(this.orderedItems, this.customer)
      : customerCode = customer.customerCode;

  double get total => calculateTotal();

  calculateTotal() {
    var total = 0.0;
    orderedItems.forEach((element) {
      total += element.quantity * element.itemPrice;
    });
    return total;
  }

  generateQuotation() async {
    setBusy(true);
    Map<String, dynamic> data = {
      "bill": "$total",
      "customer": customerCode ?? "",
      "dueDate": DateTime.now().toUtc().toIso8601String(),
      "items": orderedItems
          .map((e) => {
                "amount": "${e.itemPrice * e.quantity}",
                "item": {
                  "id": "${e.id}",
                  "itemCode": "${e.itemCode}",
                  "itemName": "${e.itemName}",
                  "itemPrice": "${e.itemPrice}",
                  "itemType": "product",
                  "priceList": "4SumPriceList"
                },
                "quantity": e.quantity,
                "rate": e.itemPrice,
                "tax": "16%",
              })
          .toList(),
      "orderType": "Sales Quotation",
      "warehouse": "Baba dogo"
    };
    var result = await _productService.createNewQuotation(data);
    setBusy(false);
    await _dialogService.showDialog(
        title: 'Quote generated successfully',
        description: 'The quotation was generated successfully');
    _navigationService.clearStackAndShow(
      Routes.homeView,
      arguments: HomeViewArguments(index: 3),
    );
  }
}
