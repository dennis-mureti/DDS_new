import 'package:distributor/services/access_controller_service.dart';

import 'package:distributor/services/api_service.dart';
import 'package:distributor/services/crate_,management_service.dart';

import 'package:distributor/services/customer_service.dart';
import 'package:distributor/services/firestore_service.dart';
import 'package:distributor/services/init_service.dart';
import 'package:distributor/services/journey_service.dart';
import 'package:distributor/services/location_repository.dart';
import 'package:distributor/services/location_service.dart';
import 'package:distributor/services/logistics_service.dart';
import 'package:distributor/services/order_service.dart';
import 'package:distributor/services/out_of_route.dart';
import 'package:distributor/services/remote_config_service.dart';
import 'package:distributor/services/start_day_service.dart';
import 'package:distributor/services/stock_controller_service.dart';
import 'package:distributor/services/remote_storage_repository.dart';
import 'package:distributor/services/transaction_service.dart';
import 'package:distributor/services/user_service.dart';
import 'package:distributor/services/visit_service.dart';
import 'package:distributor/services/waypoint_service.dart';
import 'package:injectable/injectable.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';

@module
abstract class ThirdPartyServicesModule {
  @lazySingleton
  NavigationService get navigationService;
  @lazySingleton
  DialogService get dialogService;
  @lazySingleton
  SnackbarService get snackbarService;
  @lazySingleton
  InitService get initService;
  @lazySingleton
  ApiService get appService;
  @lazySingleton
  UserService get userService;
  @lazySingleton
  CustomerService get customerService;
  @lazySingleton
  AccessControlService get accessControlService;
  @lazySingleton
  StockControllerService get stockControlService;
  @lazySingleton
  LogisticsService get logisticsService;
  @lazySingleton
  JourneyService get journeyService;
  @lazySingleton
  CrateManagementService get crateManagementService;
  @lazySingleton
  OrderService get orderService;
  // @lazySingleton
  // LocationService get locationService;
  @lazySingleton
  TransactionService get transactionService;
  @lazySingleton
  RemoteConfigService get remoteConfigService;
  @lazySingleton
  FirestoreService get firestoreService;
  @lazySingleton
  LocationRepository get locationRepository;
  @lazySingleton
  RemoteStorageRepository get remoteStorageRepository;
  @lazySingleton
  WaypointService get waypointService;
   @lazySingleton
  VisitService get visitService;
   @lazySingleton
  OutOfRouteService get outOfRouteService;
   @lazySingleton
  StartDayService get startDayService;
}
