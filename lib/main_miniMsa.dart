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
  ApplicationParameter appParam = ApplicationParameter(
      enableFullDelivery: true,
      enforceCreditLimit: true,
      enableCustomDelivery: false,
      enforceCustomerSecurity: true,
      enableAdhocSales: true,
      enableWalkIn: true,
      enableContractCustomers: true);
  _initService.setAvailableEnvList([
    AppEnv(
      flavor: Flavor.miniMsa,
      name: 'Mini-Mombasa',
      flavorValues: FlavorValues(
          // baseUrl: 'https://dds.ddsolutions.tech/dds-backend/api/v1',
          // baseUrl: 'https://demo.ddsolutions.tech/spvdev-backend/api/v1',
          // baseUrl: 'http://165.227.255.167:9087/spvdev-backend/api/v1',
          baseUrl: 'http://137.184.60.57:8585/spvdev-backend/api/v1',
          applicationParameter: appParam),
    ),
  ]);
  ByteData data =
      await PlatformAssetBundle().load('assets/ca/lets-encrypt-r3.pem');
  SecurityContext.defaultContext
      .setTrustedCertificatesBytes(data.buffer.asUint8List());
  runApp(MainApp());
}
