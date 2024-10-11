import 'package:distributor/app/locator.dart';
import 'package:distributor/app/router.gr.dart';
import 'package:distributor/core/models/app_models.dart';
import 'package:distributor/core/models/invoice.dart';
import 'package:distributor/services/adhoc_cart_service.dart';
import 'package:distributor/services/api_service.dart';
import 'package:distributor/services/stock_controller_service.dart';
import 'package:distributor/services/user_service.dart';
import 'package:distributor/src/ui/views/pos/sales_returns/sales_returns_view.dart';
import 'package:distributor/src/ui/views/print_view/print_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';

enum InvoiceType { pending, failed, finalized }

class InvoicingViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _stockControllerService = locator<StockControllerService>();
  final _userService = locator<UserService>();
  final _adhocService = locator<AdhocCartService>();
  final _apiService = locator<ApiService>();
  final _dialogService = locator<DialogService>();

  Api get api => _apiService.api;
  User get user => _userService.user;
  Invoice _finalizedInvoice;
  Invoice get finalizedInvoice => _finalizedInvoice;

  String get token => user.token;

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;

  pushToSAP(invoice) async {
    print("pushed to SAP");
  }

  getAdhocDetail(String referenceNo, String baseType) async {
    setBusy(true);
    return await _adhocService.fetchAdhocDetail(
        referenceNo, _userService.user.token, baseType);
    setBusy(false);
  }

  navigateToPrint(invoice, String referenceNo, String baseType) async {
    AdhocDetail adhocDetail = await getAdhocDetail(referenceNo, baseType);
    _navigationService.navigateToView(PrintView(
      invoice: Invoice.fromMap(invoice),
      deliveryNote: adhocDetail,
      title: "E-Invoice",
      customerTIN: "",
      items: invoice['items'],
      orderId: referenceNo,
      user: _userService.user,
    ));
  }

  init() async {
    await fetchPendingInvoices();
    await fetchFailedInvoices();
    await fetchFinalizedInvoices();
  }

  List _pendingInvoices = [];
  List _finalizedInvoices = [];
  List _failedInvoices = [];

  List get pendingInvoices => _pendingInvoices;
  List get finalizedInvoices => _finalizedInvoices;
  List get failedInvoices => _failedInvoices;

  fetchPendingInvoices() async {
    setBusy(true);
    _pendingInvoices = await _stockControllerService.getInvoices("pending");
    setBusy(false);
    notifyListeners();
  }

  fetchFinalizedInvoices() async {
    setBusy(true);
    _finalizedInvoices = await _stockControllerService.getInvoices("finalized");
    setBusy(false);
    notifyListeners();
  }

  fetchFailedInvoices() async {
    setBusy(true);
    // _failedInvoices = await _stockControllerService.getInvoices("failed");
    var result = await _stockControllerService.getInvoices("failed");
    if (result is List) {
      _failedInvoices = result;
    }
    setBusy(false);
    notifyListeners();
  }

  void submitReturns(invoice) async {
    await _navigationService.navigateToView(SalesReturnsView(
      invoice: invoice,
    ));
    await fetchFinalizedInvoices();
  }

  navigateToView(invoice) async {
    var result = await _navigationService.navigateTo(
      Routes.adhocDetailView,
      arguments: AdhocDetailViewArguments(
          referenceNo: invoice['deliveryNoteId'],
          customerId: invoice['customerCode'],
          baseType: "contract"),
    );
  }

  finalizeOrder(var invoice) async {
    var result = await api.finalizeSale(token: token, invoiceId: invoice['id']);
    if (result is APIResponse) {
      await _dialogService.showDialog(
          title: "An error occurred",
          description: result.errorMessage ?? "Unknown error");
    } else {
      AdhocDetail _adhocDetail = AdhocDetail(
          saleItems: result['items'] ?? [],
          transactionStatus: result['deliveryStatus'] ?? '',
          total: result['total'],
          verificationCode: result['verificationCode'] ?? "",
          qrCode: result['qrCode'] ?? "",
          deviceNo: result['deviceNo'] ?? "",
          mode: "Online",
          remarks: "",
          warehouseId: result['deliveryWarehouse'] ?? "",
          customerName: result['customerName'] ?? "",
          deliveryType: result['deliveryType'] ?? "",
          customerId: result['customerCode'] ?? "",
          net: result['net'],
          tax: result['tax'],
          discount: result['discount'] ?? 0.00,
          withholdingTax: result['withholding'] ?? 0.00,
          sellingPriceList: result['sellingPriceList'] ?? "",
          gross: result['gross'],
          fdn: result['fdn'] ?? "");
      // _customerTIN = result['customerTIN'];
      _finalizedInvoice = Invoice.fromAdhocDetail(_adhocDetail, "Kshs");
      notifyListeners();
    }
  }

  void updateFinalizedOrderRange(DateTime result) async {
    _startDate = result;
    setBusy(true);
    _finalizedInvoices = await _stockControllerService.getInvoices("finalized",
        deliveryDate: result, endDate: endDate);
    setBusy(false);
    notifyListeners();
  }

  void updatePendingOrderRange(DateTime result) async {
    _startDate = result;
    setBusy(true);
    _pendingInvoices = await _stockControllerService.getInvoices("pending",
        deliveryDate: result, endDate: endDate);
    setBusy(false);
    notifyListeners();
  }

  void updateFailedOrderRange(DateTime result) async {
    _startDate = result;
    setBusy(true);
    _failedInvoices = await _stockControllerService.getInvoices("failed",
        deliveryDate: result, endDate: endDate);
    setBusy(false);
    notifyListeners();
  }

  void refresh() async {
    _startDate = DateTime.now();
    _endDate = DateTime.now();
    setBusy(true);
    _finalizedInvoices = await _stockControllerService.getInvoices("finalized",
        deliveryDate: startDate, endDate: endDate);
    _failedInvoices = await _stockControllerService.getInvoices("failed",
        deliveryDate: startDate, endDate: endDate);
    _pendingInvoices = await _stockControllerService.getInvoices("pending",
        deliveryDate: startDate, endDate: endDate);
    // _pendingInvoices = await _stockControllerService.getInvoices("pending",deliveryDate: startDate, endDate: endDate);
    setBusy(false);
    notifyListeners();
  }
}
