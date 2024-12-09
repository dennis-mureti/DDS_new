import 'dart:typed_data';

import 'package:distributor/app/locator.dart';
import 'package:distributor/app/router.gr.dart';
import 'package:distributor/core/enums.dart';
import 'package:distributor/core/models/invoice.dart';
import 'package:distributor/services/api_service.dart';
import 'package:distributor/services/journey_service.dart';
import 'package:distributor/services/location_repository.dart';
import 'package:distributor/services/user_service.dart';
import 'package:distributor/src/ui/views/print_view/print_view.dart';
import 'package:distributor/ui/views/custom_delivery/custom_delivery_view.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';

class DeliveryNoteViewModel extends BaseViewModel {
  DialogService _dialogService = locator<DialogService>();
  SnackbarService _snackbarService = locator<SnackbarService>();
  NavigationService _navigationService = locator<NavigationService>();
  JourneyService _journeyService = locator<JourneyService>();
  UserService _userService = locator<UserService>();
  User get _user => _userService.user;
  DeliveryJourney _deliveryJourney;
  DeliveryStop _deliveryStop;
  ApiService _apiService = locator<ApiService>();

  ApplicationParameter get appParams => _apiService.appParams;

  bool get enablePrint => appParams.enablePrintingService;
  bool get enableCustomDelivery => appParams.enableCustomDelivery;
  bool get enableFullDelivery => appParams.enableFullDelivery;
  bool get enableSalesReturns => appParams.enableSalesReturn;

  String get currency => appParams.currency;

  Future<Uint8List> generatePdf(PdfPageFormat format, String title) async {
    String title = "Receipt";
    final pdf = pw.Document(compress: true);
    // final font = await PdfGoogleFonts.nunitoExtraLight();

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) {
          return pw.Column(
            children: [
              pw.SizedBox(
                width: double.infinity,
                child: pw.FittedBox(
                  child: pw.Text(title),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Flexible(child: pw.FlutterLogo())
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  DeliveryJourney get deliveryJourney => _deliveryJourney;
  DeliveryStop get deliveryStop => _deliveryStop;
  final Customer customer;
  final _locationService = locator<LocationRepository>();

  DeliveryNote _deliveryNote;
  DeliveryNote get deliveryNote => _deliveryNote;

  getDeliveryNote() async {
    var result = await _apiService.api.getDeliveryNoteDetails(
        deliveryNoteId: deliveryStop.deliveryNoteId, token: _user.token);
    if (result is DeliveryNote) {
      _deliveryNote = result;
      notifyListeners();
    }
  }

  bool get isSynced => deliveryNote.isSynced;

  DeliveryNoteViewModel(
      DeliveryJourney deliveryJourney, DeliveryStop deliveryStop, this.customer)
      : _deliveryStop = deliveryStop,
        _deliveryJourney = deliveryJourney;

  String _deliveryLocation;
  String get deliveryLocation => _deliveryLocation;

  getCurrentLocation() async {
    setBusy(true);
    var result = await _locationService.getLocation();
    setBusy(false);
    if (result != null) {
      _deliveryLocation = "${result.latitude},${result.longitude}";
      notifyListeners();
      return;
    } else {
      // print(result);
      return;
    }
  }

  init() async {
    await getDeliveryNote();
    // await getCurrentLocation();
  }

  handleOrderAction(String action) async {
    switch (action) {
      case 'custom_delivery':
        if (_journeyService.currentJourney?.journeyId == null) {
          await _dialogService.showDialog(
              title: 'Error',
              description:
                  'You have not selected a journey.\nYou need to select a journey to fulfill a delivery');
        } else {
          var result = await _navigationService.navigateToView(
            CustomDeliveryView(
              deliveryNote: deliveryNote,
              deliveryStop: deliveryStop,
              customer: customer,
            ),
          );
          await getDeliveryNote();
        }
        break;
      case 'full_delivery':
        if (_journeyService.currentJourney?.journeyId != null) {
          DialogResponse response = await _dialogService.showConfirmationDialog(
              description:
                  'You are about to close the Sales Order ${deliveryStop.orderId} for ${deliveryStop.customerId}.',
              title: 'COMPLETE ORDER',
              confirmationTitle: 'CONFIRM',
              cancelTitle: 'CANCEL');
          if (response.confirmed) {
            setBusy(true);
            var result = await _journeyService.makeFullSODelivery(
              deliveryStop.orderId,
              deliveryStop.stopId,
              deliveryLocation,
              deliveryNote: deliveryNote,
            );
            setBusy(false);
            if (result is CustomException) {
              await _dialogService.showDialog(
                  title: result.title, description: result.description);
            } else {
              await getDeliveryNote();
              _snackbarService.showSnackbar(
                  message: 'The delivery was closed successfully',
                  title: 'Success');
            }
          }
        } else {
          await _dialogService.showDialog(
              title: 'Error',
              description:
                  'You have not selected a journey.\nYou need to select a journey to fulfill a delivery');
        }

        break;
      case 'partial_delivery':
        var result = await _navigationService.navigateTo(
            Routes.partialDeliveryView,
            arguments: PartialDeliveryViewArguments(
                deliveryJourney: deliveryJourney,
                deliveryStop: deliveryStop,
                deliveryNote: deliveryNote));
        if (result is CustomException) {
          await _dialogService.showDialog(
              title: result.title, description: result.description);
        } else {
          //Check if delivery was completed
          if (result is bool) {
            if (result) {
              _snackbarService.showSnackbar(
                  message: 'The partial delivery was closed successfully',
                  title: 'Success');
              await getDeliveryNote();
            }
          }
        }
        break;
      case 'add_payment':
        var result = await _navigationService.navigateTo(Routes.addPaymentView,
            arguments: AddPaymentViewArguments(customer: customer));
        if (result) {
          _snackbarService.showSnackbar(
              message: 'The payment was added successfully.', title: 'Success');
        }
        break;
      case 'not_possible':
        await _dialogService.showDialog(
            title: 'Operation not possible',
            description: 'You cannot perform this action.');
        break;
      case 'drop_crates': //Drop the crates at a customer
        _navigationService.navigateTo(Routes.crateMovementView,
            arguments: CrateMovementViewArguments(
                crateTxnType: CrateTxnType.Drop,
                customer: customer,
                deliveryStop: deliveryStop));
        break;
      case 'receive_crates': // Receive crates from a customer
        _navigationService.navigateTo(
          Routes.crateMovementView,
          arguments: CrateMovementViewArguments(
              crateTxnType: CrateTxnType.Pickup,
              customer: customer,
              deliveryStop: deliveryStop),
        );
        break;
      case 'crates_return':
        _navigationService.navigateTo(
          Routes.crateMovementView,
          arguments: CrateMovementViewArguments(
              crateTxnType: CrateTxnType.Return,
              customer: customer,
              deliveryStop: deliveryStop),
        );
        break;
    }
  }

  void printDocument() async {
    final doc = pw.Document();

    doc.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Text('Hello World'),
          ); // Center
        })); //
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save());
  }

  navigateToPreview() async {
    Invoice _invoice =
        Invoice.fromDeliveryNote(deliveryNote, currency, deliveryStop.orderId);
    await _navigationService.navigateToView(PrintView(
      invoice: _invoice,
      title: "e-Invoice",
      deliveryNote: deliveryNote,
      user: _user,
      orderId: deliveryStop.orderId,
      customerTIN: deliveryNote.customerTIN,
      // deliveryStop: deliveryStop,
    ));
  }
}
