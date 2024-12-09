import 'package:distributor/app/locator.dart';
import 'package:distributor/core/models/app_models.dart';
import 'package:distributor/services/user_service.dart';
import 'package:distributor/src/ui/common/transaction_viewmodel.dart';
import 'package:stacked_services/stacked_services.dart';

class VoucherDetailViewmodel extends TransactionViewmodel {
  //Transaction status
  static const String kTransactionStatusNotCreated = 'STN Not Created';

  final _dialogService = locator<DialogService>();
  final _navigationService = locator<NavigationService>();
  final _userService = locator<UserService>();

  final String transactionId;
  final String voucherType;
  final String transactionStatus;

  List<String> statusStrings = ["Accept", "Cancel"];

  Transaction _stockTransaction;
  Transaction get stockTransaction => _stockTransaction;

  VoucherDetailViewmodel(
      this.transactionId, this.voucherType, this.transactionStatus);

  init() async {
    await getTransaction();
  }

  //@TODO Check if this really works

  /**
   * If the source warehouse is the same os the users warehouse do not display toggle
   * If the transaction status contains STN Do not display 
   */
  bool get displayUserTransactionDropdown {
    if (_userService.user.salesChannel.toLowerCase() ==
            _stockTransaction.sourceWarehouse.toLowerCase()
        // || this.transactionStatus.toLowerCase().contains('stn')
        ) {
      return false;
    } else {
      return true;
    }
  }

  getTransaction() async {
    setBusy(true);
    var result = await getStockTransaction(transactionId, voucherType);
    setBusy(false);
    if (result is Transaction) {
      _stockTransaction = result;
      notifyListeners();
    } else {}
    return;
  }

  String _status;
  String get status => _status;

  setStatus(String val) async {
    _status = val;
    var dialogResponse = await _dialogService.showConfirmationDialog(
        title: 'Change Status',
        description:
            'Are you sure you want to $val the status of this pending transaction?',
        cancelTitle: 'NO',
        confirmationTitle: 'Yes');
    if (dialogResponse.confirmed) {
      var response = await commitStatusChange(val);
      if (response is bool) {
        await _dialogService.showDialog(
            title: 'Success',
            description: 'The transaction has been ${val}ed successfully');
        _disableDropdown = true;
        getTransaction();
        _navigationService.back(result: true);
      } else {
        await _dialogService.showDialog(
            title: 'Pending Transaction Error',
            description: response.toString());
        _status = null;
        _navigationService.back(result: true);
      }
    }
    notifyListeners();
  }

  bool _disableDropdown = false;
  bool get disableDropdown => _disableDropdown;

  commitStatusChange(String val) async {
    switch (status.toLowerCase()) {
      case 'accept':
        return await approveTransaction(stockTransaction);
        break;
      case 'cancel':
        return await cancelTransaction(stockTransaction);
        break;
    }
  }

  showConfirmationDialog() async {
    var dialogResponse = await _dialogService.showConfirmationDialog(
        title: '$status transaction',
        description: 'Are you sure you want to $status this transaction ? ');
    return dialogResponse;
  }
}
