import 'package:device_info_plus/device_info_plus.dart';
import 'package:distributor/app/locator.dart';
import 'package:distributor/core/models/app_models.dart';
import 'package:distributor/core/models/app_version.dart';
import 'package:distributor/core/models/invoice.dart';
import 'package:distributor/services/api_service.dart';
import 'package:distributor/services/init_service.dart';
import 'package:distributor/services/user_service.dart';
import 'package:distributor/services/version_service.dart';
import 'package:printing/printing.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';

enum SummaryAmount { Net, Tax, Gross }

enum TaxCategory { Net, Tax, Gross }

class PrintViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _apiService = locator<ApiService>();
  final _userService = locator<UserService>();
  final _dialogService = locator<DialogService>();

  Api get api => _apiService.api;
  User get user => _userService.user;

  String get token => user.token;

  ///
  /// Finalize the order
  ///
  finalizeOrder() async {
    var result = await api.finalizeSale(token: token, invoiceId: invoice.id);
    if (result is APIResponse) {
      await _dialogService.showDialog(
          title: result.error ?? "An error occurred",
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
          sellingPriceList: result['sellingPriceList'] ?? "",
          gross: result['gross'],
          fdn: result['fdn'] ?? "");
      // _customerTIN = result['customerTIN'];
      _finalizedInvoice = Invoice.fromAdhocDetail(_adhocDetail, currency);
      notifyListeners();
    }
  }

  Invoice _finalizedInvoice;
  Invoice get finalizedInvoice => _finalizedInvoice ?? invoice;

  final Invoice invoice;
  final InitService _initService = locator<InitService>();
  final _versionService = locator<VersionService>();

  AppEnv get appEnv => _initService.appEnv;
  FlavorValues get flavourValues => appEnv.flavorValues;

  double get taxRate => flavourValues.applicationParameter.taxRate;
  String get currency => flavourValues.applicationParameter.currency;

  DateTime _dateTime;
  String _date = "";
  String _time = "";

  DateTime get dateTime => DateTime.now();

  String _fdn = "";
  String get FDN => _fdn;

  String _verificationCode = "";
  String get verificationCode => _verificationCode;

  String _documentType = "Original";
  String get documentType => _documentType;

  String _customerTIN = "";
  String get customerTIN => _customerTIN;

  List<Printer> _printerList = [];
  List<Printer> get printerList => _printerList;

  ///
  /// Get the list of available printers
  ///
  Future<List<Printer>> findPrinters() async {
    setBusy(true);
    var result = await Printing.listPrinters();
    print(result);
    if (result is List<Printer>) {
      print(result);
      _printerList = result;
      notifyListeners();
    }
    setBusy(false);
    return result;
  }

  printInvoice() async {
    print("printing");
  }

  getCurrentDateTime() {
    _dateTime = DateTime.now();
    var day = _dateTime.day.toString();
    var month = _dateTime.month.toString();
    var year = _dateTime.year.toString();
    _date = "$day - $month- $year";
    notifyListeners();
  }

  String get getTime => _time;
  String get getDate => _date;

  calculateAmounts(SummaryAmount summaryAmount) {
    switch (summaryAmount) {
      case SummaryAmount.Net:
        break;
      case SummaryAmount.Tax:
        break;
      case SummaryAmount.Gross:
        break;
    }
  }

  calculateTax(TaxCategory taxCategory) {
    switch (taxCategory) {
      case TaxCategory.Net:
        break;
      case TaxCategory.Tax:
        break;
      case TaxCategory.Gross:
        break;
    }
  }

  DeviceInfoPlugin _deviceInfo;

  PrintViewModel(this.deliveryNote, this.invoice);
  DeviceInfoPlugin get deviceInfo => _deviceInfo;

  final deliveryNote;

  AndroidDeviceInfo get androidDeviceInfo => _initService.androidDeviceInfo;

  AppVersion _appVersion;
  String _versionCode = "";

  AppVersion get appVersion => _appVersion;

  String get deviceId => androidDeviceInfo.androidId ?? "";
  String get versionCode => _versionCode;

  _getVersion() async {
    setBusy(true);
    await _versionService.getVersion().then((value) async {
      _appVersion = value;
      _versionCode = _appVersion.versionCode.toString();
      // await checkForUpdates();
    });
    setBusy(false);
  }

  init() async {
    setBusy(true);
    await fetchDeviceInfo();
    await _getVersion();
    // calculateGrossAmount();
    getCurrentDateTime();
    setBusy(false);
  }

  num _grossAmount = 0.0;
  num get grossAmount => _grossAmount;

  calculateGrossAmount() {
    List deliveryItems = deliveryNote.deliveryItems;
    for (int i = 0; i < deliveryItems.length; i++) {
      var unitSum = deliveryItems[i]['itemRate'] * deliveryItems[i]['quantity'];
      _grossAmount = unitSum + grossAmount;
      notifyListeners();
    }
    _taxAmount = taxRate * grossAmount;
  }

  num _taxAmount = 0;
  num get taxAmount => _taxAmount;

  num get netAmount => grossAmount - _taxAmount;

  fetchDeviceInfo() async {
    setBusy(true);
    setBusy(false);
  }

  // Image _image;
  // Image get image => _image;

  fetchLogo() async {}

  onPrinted() async {
    print('printed');
    await _navigationService.back();
  }

  confirmSale() async {
    DialogResponse dialogResponse = await _dialogService.showConfirmationDialog(
        confirmationTitle: 'Yes, I am sure',
        description: 'Are you sure you want to finalize this sale ?',
        cancelTitle: 'No',
        title: 'Finalize Sale');
    if (dialogResponse.confirmed) {
      await finalizeOrder();
      return true;
    } else {
      return false;
    }
  }
}
