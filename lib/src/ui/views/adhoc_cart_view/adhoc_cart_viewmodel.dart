import 'package:auto_route/auto_route.dart';
import 'package:distributor/app/locator.dart';
import 'package:distributor/app/router.gr.dart';
import 'package:distributor/core/models/app_models.dart';
import 'package:distributor/core/models/product_service.dart';
import 'package:distributor/services/adhoc_cart_service.dart';
import 'package:distributor/services/customer_service.dart';
import 'package:distributor/services/stock_controller_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';

class AdhocCartViewModel extends ReactiveViewModel {
  AdhocCartService _adhocCartService = locator<AdhocCartService>();
  StockControllerService _stockControllerService =
      locator<StockControllerService>();
  DialogService _dialogService = locator<DialogService>();
  ProductService _productService = locator<ProductService>();
  NavigationService _navigationService = locator<NavigationService>();
  final _customerService = locator<CustomerService>();

  getQuantity(Product product) {
    var result = _stockBalanceList.firstWhere(
        (element) =>
            element.itemName.toLowerCase() == product.itemName.toLowerCase(),
        orElse: () => null);
    return result?.quantity ?? 0;
  }

  bool get enforceCreditLimit => _adhocCartService.enforceCreditLimit;
  bool get enforceCustomerSecurity => _adhocCartService.enforceCustomerSecurity;

  num get total => _adhocCartService.total;

  navigateToAdhocPaymentView() async {
    await _navigationService.navigateTo(Routes.adhocPaymentView);
  }

  List _lists;
  List get lists => _lists;

  List<Product> _productList;
  List<Product> get productList {
    return _productList;
  }

  List<Product> _customerProductList = [];
  List<Product> get customerProductList => _customerProductList;

  List<Product> _stockBalanceList;
  List<Product> get stockBalanceList => _stockBalanceList;

  double get creditLimit => _adhocCartService.creditBalance;
  double get securityBalance => _adhocCartService.securityBalance;
  double get securityAmount => _adhocCartService.securityAmount;

  checkIfStockExists(Product product) {
    Product p = _stockBalanceList.firstWhere(
        (element) => element.itemCode == product.itemCode,
        orElse: () => null);
    return p != null;
  }

  bool get submitStatus => _adhocCartService.enableContinueToPayment;

  final bool _isWalkin;
  final Customer _customer;

  bool get isWalkin => _isWalkin;
  Customer get customer => _customer;

  AdhocCartViewModel({@required bool isWalkin, @required Customer customer})
      : _isWalkin = isWalkin,
        _customer = customer;

  CustomerSecurity _customerSecurity;
  CustomerSecurity get customerSecurity => _customerSecurity;

  init() async {
    if (customer != null) {
      await _adhocCartService.initializeCustomerData(
          customer, customerProductList);
    }
    await fetchStockBalance();
    await fetchProductsByPrice();

    if (enforceCreditLimit) {
      // var _creditLimit;
      // _creditLimit.value = await _customerService.getCustomerLimit(customer.name);
    }
    //Check if customer security has been enforced
    if (enforceCustomerSecurity) {
      var result = await _customerService.getCustomerSecurity(customer);
      _customerSecurity = CustomerSecurity.fromMap(result);
    }
    isWalkin ? await fetchProductsByPrice() : await fetchProducts();
    _customerProductList.removeWhere((item) => stockBalanceList.contains(item));
    // _customerProductList = stockBalanceList;
    // _security = await calculateSecurity(customerSecurity);
    notifyListeners();
  }

  // double calculateSecurity(CustomerSecurity customerSecurity) {
  //   // Is customer calculated for the security? If no, return 0.0
  //   if (customerSecurity.calcSecurity.toLowerCase() != "yes") {
  //     return security;
  //   }
  //   // If it is a fixed security, return the security amount
  //   if (customerSecurity.securityAmount != "Variable") {
  //     return double.parse(customerSecurity.securityAmount);
  //   }
  //
  //   // Now calculate the variable security
  //   customerProductList.forEach((item) {
  //     // var ite = ddsItemRepository.getItemByCode(item.itemCode!);
  //     var quantity = item.quantity ?? 0;
  //     var securityAmount = int.tryParse(customerSecurity.securityAmount) ?? 0;
  //
  //     var result = (quantity * securityAmount * item.itemFactor).toDouble();
  //     // var result = (quantity * securityAmount).toDouble();
  //     _security += result;
  //     print("This is the security to ADD:::: ${security}");
  //   });
  //
  //   return security;
  // }

  Future fetchProductsByPrice() async {
    setBusy(true);
    var result = await _productService.fetchProductsByDefaultPriceList(
        defaultStock: _adhocCartService.sellingPriceList);
    setBusy(false);
    if (result is List<Product>) {
      _customerProductList = result;
      notifyListeners();
    } else {
      _customerProductList = <Product>[];
    }
  }

  Future fetchProducts() async {
    setBusy(true);
    var result = await _productService.fetchProductsByPriceList(customer);
    setBusy(false);
    if (result is List<Product>) {
      _customerProductList = result;
      notifyListeners();
    } else {
      _customerProductList = <Product>[];
      await _dialogService.showDialog(
          title: 'Error', description: 'An error occurred.');
    }
  }

  bool get shopHasStock => _stockBalanceList?.isNotEmpty ?? false;
  bool get customerHasProducts => _customerProductList.isNotEmpty;

  Future fetchStockBalance() async {
    var result = await _stockControllerService.getStockBalance();
    if (result is List<Product>) {
      _stockBalanceList = result;
      notifyListeners();
    } else if (result is CustomException) {
      _stockBalanceList = <Product>[];
      notifyListeners();
      await _dialogService.showDialog(
          title: result.title, description: result.description);
    }
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_adhocCartService];

  displayCreditLimitExceedDialog() async {
    await _dialogService.showDialog(
        title: 'Credit Limit Exceeded',
        description:
            'The order exceeds the customer credit limit. Please remove some items');
  }
}
