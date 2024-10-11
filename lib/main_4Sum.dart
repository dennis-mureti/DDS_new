import 'dart:io';

import 'package:distributor/app/locator.dart';
import 'package:distributor/firebase_options.dart';
import 'package:distributor/main.dart';
import 'package:distributor/ui/setup_snackbar_ui.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tripletriocore/tripletriocore.dart';

import 'services/init_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
      .then((value) => print(value.name));
  setupLocator();
  setupSnackbarUi();
  InitService _initService = locator<InitService>();

  // Set the application parameters
  ApplicationParameter appParam = ApplicationParameter(
      enableOfflineService: false,
      enableFullDelivery: false,
      enforceCreditLimit: false,
      enableCustomDelivery: true,
      currency: "KES",
      taxRate: 0.16,
      enableReceivedReturns: true,
      defaultPriceList: "walk in",
      enforceCustomerSecurity: false,
      enableAdhocSales: true,
      enableWalkIn: true,
      enablePrintingService: true,
      enableContractCustomers: true);

  _initService.setAvailableEnvList([
    AppEnv(
      flavor: Flavor.fourSum,
      name: '4Sum',
      flavorValues: FlavorValues(
          baseUrl: 'https://4sum.ddsolutions.tech/spvdev-backend/api/v1',
          // baseUrl: 'https://testdds.ddsolutions.tech/dds-backend/api/v1',
          // baseUrl: 'https://4sum.ddsolutions.tech/dds-backend/api/v1',
          applicationParameter: appParam),
    )
  ]);
  // ByteData data =
  //     await PlatformAssetBundle().load('assets/ca/lets-encrypt-r3.pem');
  // SecurityContext.defaultContext
  //     .setTrustedCertificatesBytes(data.buffer.asUint8List());

  // await SentryFlutter.init(
  //   (options) {
  //     options.dsn =
  //         'https://dc6a134ce7c3892d74db6e51ee4b6274@o4507458625011712.ingest.us.sentry.io/4507458633269248';
  //     // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
  //     // We recommend adjusting this value in production.
  //     // options.tracesSampleRate = 1.0;
  //     // The sampling rate for profiling is relative to tracesSampleRate
  //     // Setting to 1.0 will profile 100% of sampled transactions:
  //     // options.profilesSampleRate = 1.0;
  //     options.useNativeBreadcrumbTracking();
  //   },
  //   appRunner: () => runApp(MainApp()),
  // );
  HttpOverrides.global = new MyHttpOverrides();
  runApp(MainApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
