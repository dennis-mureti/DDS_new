import 'package:distributor/core/models/invoice.dart';
import 'package:stacked/stacked.dart';

class PrintInvoiceViewModel extends BaseViewModel {
  final Invoice invoice;
  final invoiceId;

  init() async {}

  List get items => invoice.items ?? [];

  PrintInvoiceViewModel(this.invoice, this.invoiceId);

  getVatAmount(var item) {
    return (item['itemRate'] * 0.16).toString();
  }

  getVatTotal(var item) {
    return (item['itemRate'] * item['quantity'] * 0.16).toString();
  }

  //
  getItemTotal(var item) {
    return (item['itemRate'] * item['quantity']).toString();
  }

  String getUnitPriceExVAT(item) {
    return (item['itemRate'] ?? 0 * 0.84).toString();
  }
}
