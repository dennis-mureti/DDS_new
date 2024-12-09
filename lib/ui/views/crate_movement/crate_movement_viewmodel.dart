import 'package:distributor/app/locator.dart';
import 'package:distributor/core/enums.dart';
import 'package:distributor/services/api_service.dart';
import 'package:distributor/services/crate_,management_service.dart';
import 'package:distributor/services/customer_service.dart';
import 'package:distributor/services/journey_service.dart';
import 'package:distributor/services/user_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';

enum JourneyType { Route, Multibranch, Reliever }

class CrateMovementViewModel extends BaseViewModel {
  final _crateManagementService = locator<CrateManagementService>();
  final _dialogService = locator<DialogService>();
  final _navigationService = locator<NavigationService>();
  final _customerService = locator<CustomerService>();
  final _userService = locator<UserService>();
  final _apiService = locator<ApiService>();
  final _journeyService = locator<JourneyService>();

  get token => _userService.user.token;

  bool get isReliever => _journeyService.currentJourney?.isReliever ?? false;
  bool get isMultiBranch =>
      _journeyService.currentJourney?.isMultibranch ?? false;

  List _branches;
  List get branches => _branches;

  List<Warehouse> _warehouseList;
  List<Warehouse> get warehouseList => _warehouseList;

  /// The route
  /// Applicable to [JourneyType] != JourneyType.route
  String _warehouse;
  String get warehouse => _warehouse;

  // Set the route
  // Applicable to journeys where [JourneyType != JourneyType.Route]
  setWarehouse(String s) {
    _warehouse = s;
    notifyListeners();
  }

  getBranches() async {
    setBusy(true);
    var response = await _apiService.api
        .getDeliveryJourneyBranches(token, _journeyService.journeyId);
    print(response);
    if (response is String) {
      await _dialogService.showDialog(title: 'Error', description: response);
      _navigationService.back(result: false);
      _branches = [];
    } else {
      _branches = response;
    }
    setBusy(false);
  }

  get branchId => !_journeyService.hasJourney
      ? _userService.user.salesChannel
      : _journeyService.currentJourney.route;

  ///
  /// Get the routes for a selected branch
  /// @TODO : Implement get routes
  getWarehouses() async {
    setBusy(true);
    _warehouseList = await _apiService.api.getWarehouseListByJourney(
        token: token, journeyId: _journeyService.currentJourney?.journeyId);
    print(warehouseList);
    setBusy(false);
  }

  String _branch;
  String get branch => _branch ?? _userService.user.branch;
  setBranch(var s) {
    _branch = s;
    print(s);
    notifyListeners();
  }

  User get user => _userService.user;

  final DeliveryStop _deliveryStop;
  final CrateTxnType _crateTxnType;
  bool _disableTextFormField;
  bool get disableTextFormField => _disableTextFormField;

  String _customerCode;

  CrateMovementViewModel(this._deliveryStop, this._crateTxnType)
      : _disableTextFormField = _crateTxnType != CrateTxnType.Return,
        _customerId = _deliveryStop?.customerId,
        _journeyId = _deliveryStop?.journeyId,
        _dnId = _deliveryStop?.deliveryNoteId,
        _isValid = _crateTxnType == CrateTxnType.Return,
        _customerCode = _deliveryStop?.customerCode;

  toggleDisableTextFormField() async {
    _disableTextFormField = !disableTextFormField;
    if (disableTextFormField) {
      await _getCrates();
    } else {
      await listCrates();
    }
    notifyListeners();
  }

  List<String> editReasons = ["Stolen", "Missing", "Other"];

  String _reason;
  String get reason => _reason ?? editReasons.last;
  setReason(String reason) {
    _reason = reason;
    notifyListeners();
  }

  List<Product> _crateList = <Product>[];
  List<Product> get crateList => _crateList;
  String _customerId;
  String _journeyId;
  String _dnId;
  bool _isValid;

  String get journeyId =>
      _journeyId ?? _journeyService.currentJourney?.journeyId;
  String get dnId => _dnId;
  DeliveryStop get deliveryStop => _deliveryStop;
  CrateTxnType get crateTxnType => _crateTxnType;
  bool get isReturn => disableTextFormField;
  String get customerId => _customerId;
  String get customerCode => _customerCode ?? deliveryStop.customerCode;

  bool get isValid => _isValid;

  listCrates() async {
    setBusy(true);
    List<Item> result = await _crateManagementService.listCrates();
    _crateList = result
        .map((e) => Product(
            itemPrice: e.itemPrice,
            id: e.id,
            itemCode: e.itemCode,
            itemName: e.itemName,
            quantity: 0))
        .toList();
    setBusy(false);
    notifyListeners();
  }

  init() async {
    if (isReliever) {
      await getWarehouses();
    }
    switch (crateTxnType) {
      case CrateTxnType.Return:
        await _getCrates();
        if (!user.hasSalesChannel) {
          await getBranches();
        }
        break;
      case CrateTxnType.Pickup:
        await listCrates();
        break;
      case CrateTxnType.Drop:
        // await _getCrates();
        await listCrates();
        break;
    }
    if (_deliveryStop == null && crateTxnType != CrateTxnType.Return) {
      await _fetchCustomers();
    }
  }

  _getCrates() async {
    setBusy(true);
    List<Product> result = await _crateManagementService.fetchCrates();
    _crateList = result.where((element) => element.quantity > 0).toList();
    setBusy(false);
    notifyListeners();
  }

  _validateInput(String val, Product crate) {
    if (val.isNotEmpty) {
      Item item = Item(
          itemName: crate.itemName,
          itemCode: crate.itemCode,
          itemPrice: crate.itemPrice,
          id: crate.itemCode);
      // Check if the list is empty
      if (itemSet.isNotEmpty) {
        itemSet
            .removeWhere((item, quantity) => item.itemCode == crate.itemCode);

        // If its not check if it contains this item
        _itemSet.addAll({item: int.parse(val)});
        // If it does update the item

        // If the value is 0 remove the item
      } else {
        // Add the item to the list
        _itemSet.addAll({item: int.parse(val)});
      }
    }
  }

  updateItemSet(String val, Product crate) {
    switch (crateTxnType) {
      // case CrateTxnType.Drop:
      //   // _dialogService.showDialog(title: 'Invalid Value', description: 'The value $val exceeds the current stock at hand');
      //   // _validateInput(val, crate);
      //   break;
      default:
        _validateInput(val, crate);
        break;
    }
  }

  Map<Item, int> _itemSet = Map<Item, int>();
  Map<Item, int> get itemSet => _itemSet;

  int _received = 0;
  int _dropped = 0;

  int get received => _received;
  int get dropped => _dropped;

  bool _enableCommit = false;
  bool get enableCommit => _enableCommit;

  commitReturnCrates() async {
    var dialogResponse = await _dialogService.showConfirmationDialog(
        title: 'Return Crates Confirmation',
        cancelTitle: 'NO',
        confirmationTitle: 'YES, I AM SURE',
        description:
            'Are you sure you want to return the crates to the warehouse? ');
    if (dialogResponse.confirmed) {
      List<SalesOrderItem> actualReturned = <SalesOrderItem>[];

      //Check if the user has edited
      if (itemSet.isNotEmpty) {
        itemSet.forEach((key, value) {
          SalesOrderItem s = SalesOrderItem(
              item: Product(
                quantity: value,
                itemName: key.itemName,
                itemPrice: key.itemPrice,
                id: key.itemCode,
                itemCode: key.itemCode,
              ),
              quantity: value);
          actualReturned.add(s);
        });
      } else {
        crateList.forEach((product) {
          SalesOrderItem s =
              SalesOrderItem(item: product, quantity: product.quantity.toInt());
          actualReturned.add(s);
        });
      }
      //Compare the length of the lists
      if (crateList.length > actualReturned.length) {
        //Iterate through elements and add elements that dont exit to actual returned
        crateList.forEach((product) {
          if (!actualReturned.contains(product.itemCode)) {
            actualReturned.add(SalesOrderItem(
                quantity: product.quantity.toInt(),
                item: Product(
                    quantity: product.quantity,
                    itemName: product.itemName,
                    itemPrice: product.itemPrice,
                    id: product.itemCode,
                    itemCode: product.itemCode)));
          } else {}
        });
      }
      setBusy(true);
      var result = await _crateManagementService.cratesReturn(
          expectedCrates: _crateList,
          reason: reason,
          actualReturnedCrates: actualReturned
              .where((salesOrderItem) => salesOrderItem.quantity > 0)
              .toList(),
          branch: branch,
          route: warehouse);
      setBusy(false);
      if (result) {
        await _dialogService.showDialog(
            title: 'Crate Return Success',
            description:
                'You have successfully returned the crates to the warehouse.');
        _navigationService.back(result: true);
      }
    }
  }

  void commitChanges() async {
    var dialogResponse = await _dialogService.showConfirmationDialog(
        title: 'Collect / Drop crate confirmation',
        cancelTitle: 'NO',
        confirmationTitle: 'YES, I AM SURE',
        description:
            'Are you sure you want to drop / collect the number of items you have listed ? ');
    if (dialogResponse.confirmed) {
      List<SalesOrderItem> salesOrderItems = <SalesOrderItem>[];
      itemSet.forEach((key, value) {
        SalesOrderItem s = SalesOrderItem(
            item: Product(
              quantity: value,
              itemName: key.itemName,
              itemPrice: key.itemPrice,
              id: key.id,
              itemCode: key.itemCode,
            ),
            quantity: crateTxnType == CrateTxnType.Drop ? value * -1 : value);
        //Update the sums
        computeTotal(value);
        salesOrderItems.add(s);
      });
      setBusy(true);

      var result = await _crateManagementService.collectDropCrates(
          customer: customerId,
          dnId: dnId,
          received: received,
          dropped: dropped,
          items: salesOrderItems,
          journeyId: journeyId,
          route: warehouse,
          customerCode: _customerCode);
      setBusy(false);
      if (result['status']) {
        await _dialogService.showDialog(
            title: 'Transaction Success',
            description: 'The action was performed successfully');
        _navigationService.back(result: true);
      } else {
        await _dialogService.showDialog(
            title: 'Transaction Failed', description: result['message']);
        _navigationService.back(result: false);
      }
    }
  }

  computeTotal(int val) {
    switch (crateTxnType) {
      case CrateTxnType.Return:
        break;
      case CrateTxnType.Drop:
        _dropped += val;
        break;
      case CrateTxnType.Pickup:
        _received += val;
        break;
    }
  }

  setCustomer(Customer customer) {
    _customerId = customer.name;
    _customerCode = customer.customerCode;
    _isValid = true;
    notifyListeners();
  }

  List<Customer> _customerList;
  List<Customer> get customerList => _customerList;

  _fetchCustomers() async {
    setBusy(true);
    _customerList = await _customerService.customers;
    setBusy(false);
  }
}
