// Will provide permission info to the respective services
import 'package:distributor/app/locator.dart';
import 'package:distributor/services/user_service.dart';

import 'package:tripletriocore/tripletriocore.dart';

class AccessControlService {
  UserService _userService = locator<UserService>();
  User get user => _userService.user;

  List<Authority> get authList => user.authorities;

  enableSignIn() {}
  bool get enableHomeTab {
    bool result = false;
    Authority authManageState = Authority(auth: 'DJ.CTRL');
    Authority authViewJourneyInfo = Authority(auth: 'DJ.VU');

    bool res1 = checkIfAuthExists(authList, authManageState);
    bool res2 = checkIfAuthExists(authList, authViewJourneyInfo);
    if (res1 || res2 || user.hasSalesChannel) {
      result = true;
    }
    return result;
  }

  bool checkIfAuthExists(List<Authority> authList, Authority authority) {
    bool result = false;
    authList.forEach((auth) {
      if (auth.auth == authority.auth) {
        result = true;
      }
    });
    return result;
  }

  // Listing Delivery Journeys
  // Required permissions delivery_journey.control" || "delivery_journey.view
  // Success : Return list of journeys
  // Default : View Display No journey assigned screen
  bool get enableJourneyTab {
    bool result = false;
    Authority authManageState = Authority(auth: 'DJ.CTRL');
    Authority authViewJourneyInfo = Authority(auth: 'DJ.VU');

    bool res1 = checkIfAuthExists(authList, authManageState);
    bool res2 = checkIfAuthExists(authList, authViewJourneyInfo);
    if (res1 || res2 || user.hasSalesChannel) {
      result = true;
    }
    return result;
  }

  // Show the delivery dashboard
  // Required permissions delivery_journey.control" || "delivery_journey.view
  // Success : Display delivery dashboard. Activate controls
  // Default : Display No journey assigned screen
  bool get enableDeliveryDashboard {
    Authority _authDeliveryJourneyControl =
        Authority(auth: 'delivery_journey.control');
    Authority _authDeliveryJourneyView =
        Authority(auth: 'delivery_journey.view');
    bool result = false;
    if (checkIfAuthExists(authList, _authDeliveryJourneyControl) ||
        (checkIfAuthExists(authList, _authDeliveryJourneyView))) {
      result = true;
    }
    return result;
  }

  /// Changing journey state
  /// Starting a journey
  /// Ending a journey
  /// Requires delivery_journey.control
  /// Success : Enable controls
  /// Default : Disable controls
  bool get enableJourneyControls {
    Authority _authDeliveryJourneyControl = Authority(auth: 'DN.INP');
    Authority _authDeliveryJourneyControl1 = Authority(auth: 'DN.AUTH');
    bool result = checkIfAuthExists(authList, _authDeliveryJourneyControl) ||
        checkIfAuthExists(authList, _authDeliveryJourneyControl1);
    return result;
  }

  /// Select delivery journey
  /// Requires delivery_journey.view
  /// Success : View the journey info.
  /// Default : Display no journey screen
  bool get viewJourneyInfo {
    bool result = checkIfAuthExists(authList, Authority(auth: 'SO.VU'));
    return result;
  }

  /// Stock balance tab enabled
  /// Requires virtual_stock_balance.view
  /// Success : Enable Tab, Navigate to stock balance, Fetch Stock balance
  /// Default : Disable stock balance tab
  bool get enableStockTab {
    Authority authViewStock = Authority(auth: 'VSB.VU');
    bool result =
        checkIfAuthExists(authList, authViewStock) || user.hasSalesChannel;
    return result;
  }

  /// Display Value of stock
  /// Requires virtual_stock_balance.view_cog
  /// Success : View value of stock
  /// Default : Hide the column
  bool get displayValueOfStockColumn {
    bool result = checkIfAuthExists(
            authList, Authority(auth: 'virtual_stock_balance.view_cog')) ||
        user.hasSalesChannel;
    return result;
  }

  /// Enable customers tab
  /// Requires customer_static.view || customer_financial.view
  /// Success : Enable Tab, Navigate to Customers tab, Fetch customer data
  /// Default : Disable customers tab
  bool get enableCustomerTab {
    if (checkIfAuthExists(authList, Authority(auth: 'CUS.VU')) ||
        checkIfAuthExists(authList, Authority(auth: 'CUF.VU')) ||
        checkIfAuthExists(authList, Authority(auth: 'CUA.VU')) ||
        checkIfAuthExists(authList, Authority(auth: 'CUI.VU')) ||
        checkIfAuthExists(authList, Authority(auth: 'SO.VU')) ||
        user.hasSalesChannel) {
      return true;
    }
    return false;
  }

  /// Enable orders tab
  /// Requires sales_order.view
  /// Success : Enable Tab, Navigate to tab, Fetch Orders
  /// Default : Disable tab
  bool get enableOrdersTab {
    return checkIfAuthExists(authList, Authority(auth: 'SO.VU'));
  }

  bool get enableMakeAdhocSale {
    return checkIfAuthExists(authList, Authority(auth: 'SIAS.INP')) ||
        user.hasSalesChannel;
  }

  /// Enable place order button
  /// Requires sales_order.input || sales_order.create
  /// Success : Navigate to place sales order
  /// Default : Disable button
  bool get enablePlaceOrderButton {
    return checkIfAuthExists(authList, Authority(auth: 'SO.INP'));
  }

  /// Enable Accounts tab
  /// Requires customer_account.view
  /// Success : Enable Tab, Navigate to Tab, Fetch Accounts
  /// Default : Disable button
  bool enableAccountsTab() {
    return checkIfAuthExists(authList, Authority(auth: 'CUA.VU'));
  }

  bool enableIssuesTab() {
    return checkIfAuthExists(authList, Authority(auth: 'CUI.VU'));
  }

  bool enableInfoTab() {
    if (checkIfAuthExists(authList, Authority(auth: 'CUS.VU')) ||
        checkIfAuthExists(authList, Authority(auth: 'CUF.VU'))) {
      return true;
    } else {
      return false;
    }
  }

  bool get enableAdhocView {
    return checkIfAuthExists(authList, Authority(auth: 'SIAS.INP')) ||
        user.hasSalesChannel;
  }

  bool get enableAddPaymentMenu {
    return checkIfAuthExists(authList, Authority(auth: 'PY.INP'));
  }

  bool get enableLinkPaymentMenu {
    return checkIfAuthExists(authList, Authority(auth: 'PY.LINK'));
  }

  bool get enableAddIssueMenu {
    return checkIfAuthExists(authList, Authority(auth: 'CUI.INP'));
  }

  bool get showCashOption {
    return checkIfAuthExists(authList, Authority(auth: 'PYI.CASH'));
  }

  bool get showMpesaOption {
    return checkIfAuthExists(authList, Authority(auth: 'PYI.MPESA'));
  }

  bool get showEquitelOption {
    return checkIfAuthExists(authList, Authority(auth: 'PYI.EQUITEL'));
  }
}
