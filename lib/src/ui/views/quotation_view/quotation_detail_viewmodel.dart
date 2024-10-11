import 'package:distributor/app/locator.dart';
import 'package:distributor/core/models/product_service.dart';
import 'package:distributor/services/user_service.dart';
import 'package:distributor/src/ui/views/print_view/quotation_printview.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class QuotationDetailViewModel extends BaseViewModel {
  final _productService = locator<ProductService>();
  final _userService = locator<UserService>();
  final _dialogService = locator<DialogService>();
  final _navigationService = locator<NavigationService>();
  final String quotationId;

  void navigateToPrint() {
    // CustomerDetail customerDetail = CustomerDetail.fromCustomer(
    //   Customer(
    //     id: customerId,
    //     name: adhocDetail.customerName,
    //     taxId: "",
    //   ),
    // );
    // Invoice _invoice = Invoice.fromAdhocDetail(adhocDetail, currency,
    //     customerDetail: customerDetail);
    _navigationService.navigateToView(
      QuotationPrintView(
        quotation: quotation,
        quotationId: quotationId,
        quotationItems: items,
      ),
    );
  }

  var _quotation;
  get quotation => _quotation;

  List _items;
  var _customer;
  var _warehouse;

  List get items => _items;
  get customer => _customer;
  get warehouse => _warehouse;

  fetchQuotationDetail() async {
    setBusy(true);
    _quotation = await _productService.getQuotationDetail(quotationId);
    _items = _quotation['items'];
    _customer = _quotation['customer'];
    _warehouse = _quotation['warehouse'];
    setBusy(false);
  }

  shareQuotation() async {}

  QuotationDetailViewModel(this.quotationId);

  init() async {
    await fetchQuotationDetail();
  }

  generateInvoice() async {
    setBusy(true);
    Map<String, dynamic> data = {
      "customer": customer['customerCode'],
      "sellingPriceList": "4SumPriceList",
      "company": "4SUM",
      "items": items
          .map((e) => {
                "item": {
                  "id": "${e['id']}",
                  "itemCode": "${e['itemCode']}",
                  "itemName": "${e['itemName']}",
                  "itemPrice": e['itemPrice'],
                  "quantity": e['quantity'],
                },
                "quantity": e['quantity'],
              })
          .toList(),
      "quotationId": quotationId,
      // "dueDate": DateTime.parse(quotation['dueDate']).toUtc().toIso8601String(),
      "dueDate":"",
      "warehouse": "",
      "remarks": "Order Created from Quotation",
    };
    var result = await _productService.generateInvoiceFromQuotation(data);
    setBusy(false);
    await _dialogService.showDialog(
        title: 'Order generation status',
        description: 'The order was generated successfully');
    _navigationService.back(result: true);
  }
}
