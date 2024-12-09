import 'package:distributor/app/locator.dart';
import 'package:distributor/app/router.gr.dart';
import 'package:distributor/conf/style/lib/colors.dart';
import 'package:distributor/conf/style/lib/fonts.dart';
import 'package:distributor/conf/style/lib/text_styles.dart';
import 'package:distributor/core/enums.dart';
import 'package:distributor/main_viewmodel.dart';
import 'package:distributor/services/connectivity_service.dart';
import 'package:distributor/ui/shared/brand_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';
import 'package:distributor/app/router.gr.dart' as app_router;

import 'conf/dds_brand_guide.dart';

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<ConnectivityStatus>(
      create: (context) =>
          ConnectivityService().connectionStatusController.stream,
      child: ViewModelBuilder<MainViewModel>.reactive(
        builder: (context, model, child) {
          return MaterialApp(
            supportedLocales: const [Locale('en'), Locale('en_us')],
            title: Globals.appName,
            debugShowCheckedModeBanner: false,
            theme: _kAppTheme,
            initialRoute: Routes.startupView,
            onGenerateRoute: app_router.Router().onGenerateRoute,
            navigatorKey: locator<NavigationService>().navigatorKey,
          );
        },
        viewModelBuilder: () => MainViewModel(),
        onModelReady: (model) => model.init(),
      ),
    );
  }
}

final ThemeData _kAppTheme = _buildAppTheme();

ThemeData _buildAppTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    primaryColor: kColDDSPrimaryDark,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    // canvasColor: kCanvasColor,
    dialogTheme: DialogTheme(
      contentTextStyle: TextStyle(
          fontFamily: kFontThinBody,
          color: kColorDDSColorDark,
          fontSize: kBodyTextSize),
      titleTextStyle: TextStyle(
          color: kColorDDSPrimaryDark,
          fontFamily: kFontThinBody,
          fontSize: kMediumTextSize),
    ),
    appBarTheme: AppBarTheme(
      elevation: 1.0,
      color: kColDDSPrimaryDark,
      titleTextStyle: kAppBarTextStyle,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    buttonTheme: base.buttonTheme.copyWith(
      buttonColor: kColDDSPrimaryLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textTheme: ButtonTextTheme.normal,
    ),
    primaryIconTheme: base.iconTheme.copyWith(color: Colors.white),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: EdgeInsets.all(10.0),
      focusColor: Colors.grey,
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
            color: kColorMiniDarkBlue, style: BorderStyle.solid, width: 2),
      ),
      border: UnderlineInputBorder(
        borderSide: BorderSide(
            color: Colors.green, style: BorderStyle.solid, width: 2.0),
      ),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      filled: false,
    ),
    textTheme: _buildAppTextTheme(base.textTheme),
    primaryTextTheme: _buildAppTextTheme(base.primaryTextTheme),
    snackBarTheme: SnackBarThemeData(
        backgroundColor: kColorDDSPrimaryDark, actionTextColor: kColorNeutral),
  );
}

TextTheme _buildAppTextTheme(TextTheme base) {
  return base
      .copyWith(
        headlineSmall: base.headlineSmall.copyWith(
          color: kColorDDSPrimaryLight,
          fontFamily: kFontBoldBody,
        ),
        titleMedium: base.titleMedium.copyWith(
            fontFamily: kFontThinBody,
            color: kColorDDSColorDark,
            fontSize: kBodyTextSize),
        titleLarge: base.titleLarge.copyWith(
            fontFamily: kFontThinBody,
            fontSize: kBodyTextSize,
            color: kColorDDSPrimaryDark),
        bodySmall: base.bodySmall
            .copyWith(fontFamily: kFontThinBody, fontSize: kBodyTextSize),
        bodyLarge: base.bodyLarge.copyWith(
            fontFamily: kFontLightBody,
            fontSize: kBodyTextSize,
            color: kColorDDSColorDark),
        labelLarge: base.labelLarge.copyWith(color: kColDDSPrimaryLight),
        bodyMedium: base.bodyMedium.copyWith(
            fontFamily: kFontLightBody,
            fontSize: kBodyTextSize,
            color: kColorDDSColorDark),
      )
      .apply(
        fontFamily: kFontLightBody,
        displayColor: Colors.grey,
        bodyColor: Colors.black,
      );
}
