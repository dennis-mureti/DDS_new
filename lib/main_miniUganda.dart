import 'dart:io';

import 'package:distributor/app/locator.dart';
import 'package:distributor/firebase_options.dart';
import 'package:distributor/main.dart';
import 'package:distributor/ui/setup_snackbar_ui.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      currency: "UGX",
      taxRate: 0.18,
      defaultPriceList: "walk in",
      enforceCustomerSecurity: false,
      enableAdhocSales: true,
      enableWalkIn: true,
      enablePrintingService: true,
      enableContractCustomers: true);

  _initService.setAvailableEnvList([
    AppEnv(
      flavor: Flavor.miniUg,
      name: 'miniUg',
      flavorValues: FlavorValues(
          baseUrl: 'http://34.252.102.87:8888/dds-backend/api/v1',
          applicationParameter: appParam),
    )
  ]);
  ByteData data =
      await PlatformAssetBundle().load('assets/ca/lets-encrypt-r3.pem');
  SecurityContext.defaultContext
      .setTrustedCertificatesBytes(data.buffer.asUint8List());
  runApp(MainApp());
}
