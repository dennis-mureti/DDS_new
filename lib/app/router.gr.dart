// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs

import 'package:auto_route/legacy.dart';
import 'package:distributor/ui/views/register/register_view.dart';
import 'package:flutter/material.dart';
import 'package:tripletriocore/tripletriocore.dart';

import '../core/enums.dart';
import '../core/models/payment_link.dart';
import '../src/ui/views/add_adhoc_sale/add_adhoc_sale_view.dart';
import '../src/ui/views/add_issue/add_issue_view.dart';
import '../src/ui/views/add_payment/add_payment_view.dart';
import '../src/ui/views/adhoc_cart_view/adhoc_cart_view.dart';
import '../src/ui/views/adhoc_detail/adhoc_detail.dart';
import '../src/ui/views/adhoc_payment/adhoc_payment_view.dart';
import '../src/ui/views/change_password/change_password.dart';
import '../src/ui/views/delivery_note/delivery_note_view.dart';
import '../src/ui/views/journey_log/journey_log.dart';
import '../src/ui/views/partial_delivery/partial_delivery_view.dart';
import '../src/ui/views/reset_password/reset_password_view.dart';
import '../src/ui/views/stock_transaction/stock_transaction_list_view.dart';
import '../src/ui/views/stock_transfer/stock_transfer_view.dart';
import '../src/ui/views/voucher_detail/voucher_detail_view.dart';
import '../ui/views/adhoc_sales/adhoc_sales_view.dart';
import '../ui/views/app_info/app_info_view.dart';
import '../ui/views/bug_report/bug_report.dart';
import '../ui/views/crate_movement/crate_movement_view.dart';
import '../ui/views/customer_location.dart';
import '../ui/views/customers/customer_detail/customer_detail_view.dart';
import '../ui/views/help/help_detail_view.dart';
import '../ui/views/help/help_view.dart';
import '../ui/views/home/home_view.dart';
import '../ui/views/journey/journey_view.dart';
import '../ui/views/journey_info/journey_info_view.dart';
import '../ui/views/link_payment/link_payment_view.dart';
import '../ui/views/login/login_view.dart';
import '../ui/views/manage_crate/manage_crate_view.dart';
import '../ui/views/notifications/notification_view.dart';
import '../ui/views/orders/create_order/create_sales_order_view.dart';
import '../ui/views/orders/order_confirmation/order_confirmation.dart';
import '../ui/views/orders/order_detail/order_detail_view.dart';
import '../ui/views/payment_reference/payment_reference_view.dart';
import '../ui/views/startup/startup_view.dart';
import '../ui/views/stock_collection/stock_collection_view.dart';
import '../ui/views/stock_return/stock_return_view.dart';
import '../ui/views/territory/territory_view.dart';
import '../ui/views/territory/territory_viewdetail.dart';
import '../ui/widgets/smart_widgets/map_view/delivery_journey_map_view.dart';

class Routes {
  static const String homeView = '/home-view';
  static const String startupView = '/';
  static const String loginView = '/login-view';
  static const String registerView = '/register-view';
  static const String adhocDetailView = '/adhoc-detail-view';
  static const String journeyView = '/journey-view';
  static const String customerDetailView = '/customer-detail-view';
  static const String createSalesOrderView = '/create-sales-order-view';
  static const String customerLocation = '/customer-location';
  static const String orderDetailView = '/order-detail-view';
  static const String orderConfirmation = '/order-confirmation';
  static const String deliveryJourneyMapView = '/delivery-journey-map-view';
  static const String territoryView = '/territory-view';
  static const String notificationView = '/notification-view';
  static const String stockReturnView = '/stock-return-view';
  static const String linkPaymentView = '/link-payment-view';
  static const String paymentReferenceView = '/payment-reference-view';
  static const String addPaymentView = '/add-payment-view';
  static const String partialDeliveryView = '/partial-delivery-view';
  static const String addIssueView = '/add-issue-view';
  static const String adhocCartView = '/adhoc-cart-view';
  static const String addAdhocSaleView = '/add-adhoc-sale-view';
  static const String stockTransactionListView = '/stock-transaction-list-view';
  static const String adhocPaymentView = '/adhoc-payment-view';
  static const String deliveryNoteView = '/delivery-note-view';
  static const String resetPasswordView = '/reset-password-view';
  static const String crateMovementView = '/crate-movement-view';
  static const String changePasswordView = '/change-password-view';
  static const String stockTransferView = '/stock-transfer-view';
  static const String voucherDetailView = '/voucher-detail-view';
  static const String stockCollectionView = '/stock-collection-view';
  static const String adhocSalesView = '/adhoc-sales-view';
  static const String manageCrateView = '/manage-crate-view';
  static const String helpView = '/help-view';
  static const String bugReportView = '/bug-report-view';
  static const String appInfoView = '/app-info-view';
  static const String helpDetailView = '/help-detail-view';
  static const String journeyLog = '/journey-log';
  static const String territoryDetailView = '/territory-detail-view';
  static const String journeyInfoView = '/journey-info-view';
  static const all = <String>{
    homeView,
    startupView,
    loginView,
    adhocDetailView,
    journeyView,
    customerDetailView,
    createSalesOrderView,
    customerLocation,
    orderDetailView,
    orderConfirmation,
    deliveryJourneyMapView,
    territoryView,
    notificationView,
    stockReturnView,
    linkPaymentView,
    paymentReferenceView,
    addPaymentView,
    partialDeliveryView,
    addIssueView,
    adhocCartView,
    addAdhocSaleView,
    stockTransactionListView,
    adhocPaymentView,
    deliveryNoteView,
    resetPasswordView,
    crateMovementView,
    changePasswordView,
    stockTransferView,
    voucherDetailView,
    stockCollectionView,
    adhocSalesView,
    manageCrateView,
    helpView,
    bugReportView,
    appInfoView,
    helpDetailView,
    journeyLog,
    territoryDetailView,
    journeyInfoView,
    registerView
  };
}

class Router extends RouterBase {
  @override
  List<RouteDef> get routes => _routes;
  final _routes = <RouteDef>[
    RouteDef(Routes.homeView, page: HomeView),
    RouteDef(Routes.startupView, page: StartupView),
    RouteDef(Routes.loginView, page: LoginView),
    RouteDef(Routes.registerView, page: RegisterView),
    RouteDef(Routes.adhocDetailView, page: AdhocDetailView),
    RouteDef(Routes.journeyView, page: JourneyView),
    RouteDef(Routes.customerDetailView, page: CustomerDetailView),
    RouteDef(Routes.createSalesOrderView, page: CreateSalesOrderView),
    RouteDef(Routes.customerLocation, page: CustomerLocation),
    RouteDef(Routes.orderDetailView, page: OrderDetailView),
    RouteDef(Routes.orderConfirmation, page: OrderConfirmation),
    RouteDef(Routes.deliveryJourneyMapView, page: DeliveryJourneyMapView),
    RouteDef(Routes.territoryView, page: TerritoryView),
    RouteDef(Routes.notificationView, page: NotificationView),
    RouteDef(Routes.stockReturnView, page: StockReturnView),
    RouteDef(Routes.linkPaymentView, page: LinkPaymentView),
    RouteDef(Routes.paymentReferenceView, page: PaymentReferenceView),
    RouteDef(Routes.addPaymentView, page: AddPaymentView),
    RouteDef(Routes.partialDeliveryView, page: PartialDeliveryView),
    RouteDef(Routes.addIssueView, page: AddIssueView),
    RouteDef(Routes.adhocCartView, page: AdhocCartView),
    RouteDef(Routes.addAdhocSaleView, page: AddAdhocSaleView),
    RouteDef(Routes.stockTransactionListView, page: StockTransactionListView),
    RouteDef(Routes.adhocPaymentView, page: AdhocPaymentView),
    RouteDef(Routes.deliveryNoteView, page: DeliveryNoteView),
    RouteDef(Routes.resetPasswordView, page: ResetPasswordView),
    RouteDef(Routes.crateMovementView, page: CrateMovementView),
    RouteDef(Routes.changePasswordView, page: ChangePasswordView),
    RouteDef(Routes.stockTransferView, page: StockTransferView),
    RouteDef(Routes.voucherDetailView, page: VoucherDetailView),
    RouteDef(Routes.stockCollectionView, page: StockCollectionView),
    RouteDef(Routes.adhocSalesView, page: AdhocSalesView),
    RouteDef(Routes.manageCrateView, page: ManageCrateView),
    RouteDef(Routes.helpView, page: HelpView),
    RouteDef(Routes.bugReportView, page: BugReportView),
    RouteDef(Routes.appInfoView, page: AppInfoView),
    RouteDef(Routes.helpDetailView, page: HelpDetailView),
    RouteDef(Routes.journeyLog, page: JourneyLog),
    RouteDef(Routes.territoryDetailView, page: TerritoryDetailView),
    RouteDef(Routes.journeyInfoView, page: JourneyInfoView),
  ];
  @override
  Map<Type, AutoRouteFactory> get pagesMap => _pagesMap;
  final _pagesMap = <Type, AutoRouteFactory>{
    HomeView: (data) {
      final args = data.getArgs<HomeViewArguments>(
        orElse: () => HomeViewArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) => HomeView(
          key: args.key,
          index: args.index,
        ),
        settings: data,
      );
    },
    StartupView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => const StartupView(),
        settings: data,
      );
    },
    LoginView: (data) {
      final args = data.getArgs<LoginViewArguments>(
        orElse: () => LoginViewArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) => LoginView(
          key: args.key,
          userId: args.userId,
          password: args.password,
        ),
        settings: data,
      );
    },
    RegisterView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => const RegisterView(),
        settings: data,
      );
    },
    AdhocDetailView: (data) {
      final args = data.getArgs<AdhocDetailViewArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => AdhocDetailView(
          key: args.key,
          referenceNo: args.referenceNo,
          customerId: args.customerId,
          baseType: args.baseType,
        ),
        settings: data,
      );
    },
    JourneyView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => JourneyView(),
        settings: data,
      );
    },
    CustomerDetailView: (data) {
      final args = data.getArgs<CustomerDetailViewArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => CustomerDetailView(
          customer: args.customer,
          key: args.key,
        ),
        settings: data,
      );
    },
    CreateSalesOrderView: (data) {
      final args = data.getArgs<CreateSalesOrderViewArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => CreateSalesOrderView(
          customer: args.customer,
          key: args.key,
        ),
        settings: data,
      );
    },
    CustomerLocation: (data) {
      final args = data.getArgs<CustomerLocationArguments>(
        orElse: () => CustomerLocationArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) => CustomerLocation(customer: args.customer),
        settings: data,
      );
    },
    OrderDetailView: (data) {
      final args = data.getArgs<OrderDetailViewArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => OrderDetailView(
          salesOrder: args.salesOrder,
          deliveryStop: args.deliveryStop,
          deliveryJourney: args.deliveryJourney,
          stopId: args.stopId,
          key: args.key,
        ),
        settings: data,
      );
    },
    OrderConfirmation: (data) {
      final args = data.getArgs<OrderConfirmationArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => OrderConfirmation(
          salesOrderRequest: args.salesOrderRequest,
          customer: args.customer,
          key: args.key,
        ),
        settings: data,
      );
    },
    DeliveryJourneyMapView: (data) {
      final args = data.getArgs<DeliveryJourneyMapViewArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => DeliveryJourneyMapView(
          deliveryJourney: args.deliveryJourney,
          key: args.key,
        ),
        settings: data,
      );
    },
    TerritoryView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => const TerritoryView(),
        settings: data,
      );
    },
    NotificationView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => NotificationView(),
        settings: data,
      );
    },
    StockReturnView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => const StockReturnView(),
        settings: data,
      );
    },
    LinkPaymentView: (data) {
      final args = data.getArgs<LinkPaymentViewArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => LinkPaymentView(
          customer: args.customer,
          paymentLink: args.paymentLink,
          key: args.key,
        ),
        settings: data,
      );
    },
    PaymentReferenceView: (data) {
      final args = data.getArgs<PaymentReferenceViewArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => PaymentReferenceView(
          customer: args.customer,
          key: args.key,
        ),
        settings: data,
      );
    },
    AddPaymentView: (data) {
      final args = data.getArgs<AddPaymentViewArguments>(
        orElse: () => AddPaymentViewArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) => AddPaymentView(
          key: args.key,
          customer: args.customer,
        ),
        settings: data,
      );
    },
    PartialDeliveryView: (data) {
      final args = data.getArgs<PartialDeliveryViewArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => PartialDeliveryView(
          key: args.key,
          salesOrder: args.salesOrder,
          deliveryJourney: args.deliveryJourney,
          deliveryNote: args.deliveryNote,
          deliveryStop: args.deliveryStop,
        ),
        settings: data,
      );
    },
    AddIssueView: (data) {
      final args = data.getArgs<AddIssueViewArguments>(
        orElse: () => AddIssueViewArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) => AddIssueView(
          key: args.key,
          customer: args.customer,
        ),
        settings: data,
      );
    },
    AdhocCartView: (data) {
      final args = data.getArgs<AdhocCartViewArguments>(
        orElse: () => AdhocCartViewArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) => AdhocCartView(
          key: args.key,
          customer: args.customer,
          isWalkin: args.isWalkin,
        ),
        settings: data,
      );
    },
    AddAdhocSaleView: (data) {
      final args = data.getArgs<AddAdhocSaleViewArguments>(
        orElse: () => AddAdhocSaleViewArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) => AddAdhocSaleView(
          key: args.key,
          customer: args.customer,
        ),
        settings: data,
      );
    },
    StockTransactionListView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => const StockTransactionListView(),
        settings: data,
      );
    },
    AdhocPaymentView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => AdhocPaymentView(),
        settings: data,
      );
    },
    DeliveryNoteView: (data) {
      final args = data.getArgs<DeliveryNoteViewArguments>(
        orElse: () => DeliveryNoteViewArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) => DeliveryNoteView(
          key: args.key,
          deliveryJourney: args.deliveryJourney,
          deliveryStop: args.deliveryStop,
          customer: args.customer,
        ),
        settings: data,
      );
    },
    ResetPasswordView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => ResetPasswordView(),
        settings: data,
      );
    },
    CrateMovementView: (data) {
      final args = data.getArgs<CrateMovementViewArguments>(
        orElse: () => CrateMovementViewArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) => CrateMovementView(
          key: args.key,
          crateTxnType: args.crateTxnType,
          customer: args.customer,
          deliveryStop: args.deliveryStop,
        ),
        settings: data,
      );
    },
    ChangePasswordView: (data) {
      final args = data.getArgs<ChangePasswordViewArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => ChangePasswordView(
          key: args.key,
          passwordChangeType: args.passwordChangeType,
          identityType: args.identityType,
          identityValue: args.identityValue,
        ),
        settings: data,
      );
    },
    StockTransferView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => const StockTransferView(),
        settings: data,
      );
    },
    VoucherDetailView: (data) {
      final args = data.getArgs<VoucherDetailViewArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => VoucherDetailView(
          key: args.key,
          transactionId: args.transactionId,
          voucherType: args.voucherType,
          transactionStatus: args.transactionStatus,
        ),
        settings: data,
      );
    },
    StockCollectionView: (data) {
      final args = data.getArgs<StockCollectionViewArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => StockCollectionView(
          key: args.key,
          deliveryStop: args.deliveryStop,
        ),
        settings: data,
      );
    },
    AdhocSalesView: (data) {
      final args = data.getArgs<AdhocSalesViewArguments>(
        orElse: () => AdhocSalesViewArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) => AdhocSalesView(
          key: args.key,
          customer: args.customer,
          saleType: args.saleType,
        ),
        settings: data,
      );
    },
    ManageCrateView: (data) {
      final args = data.getArgs<ManageCrateViewArguments>(
        orElse: () => ManageCrateViewArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) => ManageCrateView(
          key: args.key,
          crateTxnType: args.crateTxnType,
          crateType: args.crateType,
          customer: args.customer,
        ),
        settings: data,
      );
    },
    HelpView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => const HelpView(),
        settings: data,
      );
    },
    BugReportView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => const BugReportView(),
        settings: data,
      );
    },
    AppInfoView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => const AppInfoView(),
        settings: data,
      );
    },
    HelpDetailView: (data) {
      final args = data.getArgs<HelpDetailViewArguments>(
        orElse: () => HelpDetailViewArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) => HelpDetailView(
          key: args.key,
          id: args.id,
          title: args.title,
        ),
        settings: data,
      );
    },
    JourneyLog: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => const JourneyLog(),
        settings: data,
      );
    },
    TerritoryDetailView: (data) {
      final args = data.getArgs<TerritoryDetailViewArguments>(
        orElse: () => TerritoryDetailViewArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) => TerritoryDetailView(
          key: args.key,
          fence: args.fence,
        ),
        settings: data,
      );
    },
    JourneyInfoView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => const JourneyInfoView(),
        settings: data,
      );
    },
  };
}

/// ************************************************************************
/// Arguments holder classes
/// *************************************************************************

/// HomeView arguments holder class
class HomeViewArguments {
  final Key key;
  final int index;
  HomeViewArguments({this.key, this.index});
}

/// LoginView arguments holder class
class LoginViewArguments {
  final Key key;
  final String userId;
  final String password;
  LoginViewArguments({this.key, this.userId, this.password});
}

/// AdhocDetailView arguments holder class
class AdhocDetailViewArguments {
  final Key key;
  final String referenceNo;
  final String customerId;
  final String baseType;
  AdhocDetailViewArguments(
      {this.key,
      @required this.referenceNo,
      @required this.customerId,
      @required this.baseType});
}

/// CustomerDetailView arguments holder class
class CustomerDetailViewArguments {
  final Customer customer;
  final Key key;
  CustomerDetailViewArguments({@required this.customer, this.key});
}

/// CreateSalesOrderView arguments holder class
class CreateSalesOrderViewArguments {
  final Customer customer;
  final Key key;
  CreateSalesOrderViewArguments({@required this.customer, this.key});
}

/// CustomerLocation arguments holder class
class CustomerLocationArguments {
  final Customer customer;
  CustomerLocationArguments({this.customer});
}

/// OrderDetailView arguments holder class
class OrderDetailViewArguments {
  final SalesOrder salesOrder;
  final DeliveryStop deliveryStop;
  final DeliveryJourney deliveryJourney;
  final String stopId;
  final Key key;
  OrderDetailViewArguments(
      {this.salesOrder,
      @required this.deliveryStop,
      @required this.deliveryJourney,
      @required this.stopId,
      this.key});
}

/// OrderConfirmation arguments holder class
class OrderConfirmationArguments {
  final SalesOrderRequest salesOrderRequest;
  final Customer customer;
  final Key key;
  OrderConfirmationArguments(
      {@required this.salesOrderRequest, @required this.customer, this.key});
}

/// DeliveryJourneyMapView arguments holder class
class DeliveryJourneyMapViewArguments {
  final DeliveryJourney deliveryJourney;
  final Key key;
  DeliveryJourneyMapViewArguments({@required this.deliveryJourney, this.key});
}

/// LinkPaymentView arguments holder class
class LinkPaymentViewArguments {
  final Customer customer;
  final PaymentLink paymentLink;
  final Key key;
  LinkPaymentViewArguments(
      {@required this.customer, @required this.paymentLink, this.key});
}

/// PaymentReferenceView arguments holder class
class PaymentReferenceViewArguments {
  final Customer customer;
  final Key key;
  PaymentReferenceViewArguments({@required this.customer, this.key});
}

/// AddPaymentView arguments holder class
class AddPaymentViewArguments {
  final Key key;
  final Customer customer;
  AddPaymentViewArguments({this.key, this.customer});
}

/// PartialDeliveryView arguments holder class
class PartialDeliveryViewArguments {
  final Key key;
  final SalesOrder salesOrder;
  final DeliveryJourney deliveryJourney;
  final DeliveryNote deliveryNote;
  final DeliveryStop deliveryStop;
  PartialDeliveryViewArguments(
      {this.key,
      this.salesOrder,
      this.deliveryJourney,
      @required this.deliveryNote,
      @required this.deliveryStop});
}

/// AddIssueView arguments holder class
class AddIssueViewArguments {
  final Key key;
  final Customer customer;
  AddIssueViewArguments({this.key, this.customer});
}

/// AdhocCartView arguments holder class
class AdhocCartViewArguments {
  final Key key;
  final Customer customer;
  final bool isWalkin;
  AdhocCartViewArguments({this.key, this.customer, this.isWalkin});
}

/// AddAdhocSaleView arguments holder class
class AddAdhocSaleViewArguments {
  final Key key;
  final Customer customer;
  AddAdhocSaleViewArguments({this.key, this.customer});
}

/// DeliveryNoteView arguments holder class
class DeliveryNoteViewArguments {
  final Key key;
  final DeliveryJourney deliveryJourney;
  final DeliveryStop deliveryStop;
  final Customer customer;
  DeliveryNoteViewArguments(
      {this.key, this.deliveryJourney, this.deliveryStop, this.customer});
}

/// CrateMovementView arguments holder class
class CrateMovementViewArguments {
  final Key key;
  final CrateTxnType crateTxnType;
  final Customer customer;
  final DeliveryStop deliveryStop;
  CrateMovementViewArguments(
      {this.key, this.crateTxnType, this.customer, this.deliveryStop});
}

/// ChangePasswordView arguments holder class
class ChangePasswordViewArguments {
  final Key key;
  final PasswordChangeType passwordChangeType;
  final String identityType;
  final String identityValue;
  ChangePasswordViewArguments(
      {this.key,
      @required this.passwordChangeType,
      this.identityType,
      this.identityValue});
}

/// VoucherDetailView arguments holder class
class VoucherDetailViewArguments {
  final Key key;
  final String transactionId;
  final String voucherType;
  final String transactionStatus;
  VoucherDetailViewArguments(
      {this.key,
      @required this.transactionId,
      @required this.voucherType,
      @required this.transactionStatus});
}

/// StockCollectionView arguments holder class
class StockCollectionViewArguments {
  final Key key;
  final DeliveryStop deliveryStop;
  StockCollectionViewArguments({this.key, @required this.deliveryStop});
}

/// AdhocSalesView arguments holder class
class AdhocSalesViewArguments {
  final Key key;
  final Customer customer;
  final CustomerType saleType;
  AdhocSalesViewArguments({this.key, this.customer, this.saleType});
}

/// ManageCrateView arguments holder class
class ManageCrateViewArguments {
  final Key key;
  final String crateTxnType;
  final String crateType;
  final Customer customer;
  ManageCrateViewArguments(
      {this.key, this.crateTxnType, this.crateType, this.customer});
}

/// HelpDetailView arguments holder class
class HelpDetailViewArguments {
  final Key key;
  final String id;
  final String title;
  HelpDetailViewArguments({this.key, this.id, this.title});
}

/// TerritoryDetailView arguments holder class
class TerritoryDetailViewArguments {
  final Key key;
  final Fence fence;
  TerritoryDetailViewArguments({this.key, this.fence});
}
