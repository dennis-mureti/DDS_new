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
  ApplicationParameter appParam = ApplicationParameter(
      enableFullDelivery: true,
      enforceCreditLimit: false,
      enableCustomDelivery: false,
      enforceCustomerSecurity: false,
      enableOfflineService: false,
      returnEmptyCrates: true,
      returnEmptyStock: true,
      currency: "Kshs",
      enableAdhocSales: false,
      enableWalkIn: true,
      enableContractCustomers: true);
  InitService _initService = locator<InitService>();
  _initService.setAvailableEnvList([
    AppEnv(
      flavor: Flavor.miniNrb,
      name: 'Mini-Nrb',
      flavorValues: FlavorValues(
          baseUrl: 'https://mbnl.ddsolutions.tech/dds-backend/api/v1',
          applicationParameter: appParam),
    ),
  ]);
  ByteData data =
      await PlatformAssetBundle().load('assets/ca/lets-encrypt-r3.pem');
  SecurityContext.defaultContext
      .setTrustedCertificatesBytes(data.buffer.asUint8List());
  runApp(MainApp());
}
