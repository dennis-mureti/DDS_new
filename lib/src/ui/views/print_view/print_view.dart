import 'dart:typed_data';

import 'package:distributor/core/helper.dart';
import 'package:distributor/core/models/invoice.dart';
import 'package:distributor/src/ui/views/print_view/print_viewmodel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:stacked/stacked.dart';
import 'package:tripletriocore/tripletriocore.dart';

class PrintView extends StatelessWidget {
  final String title;
  final Invoice invoice;
  final User user;
  var deliveryNote;
  String orderId;
  List items;
  String customerTIN;

  PrintView(
      {Key key,
      this.invoice,
      this.title,
      this.customerTIN,
      @required this.deliveryNote,
      this.user,
      this.orderId = "",
      List items})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String fontRoot = "assets/fonts/proxima_nova/normal/proxima.ttf";
    // final double fontSize = 60.5;
    final double fontSize = 24;
    return ViewModelBuilder<PrintViewModel>.reactive(
      onModelReady: (model) => model.init(),
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: [
              IconButton(
                  onPressed: () async {
                    // _print(model, fontRoot, fontSize);
                    try {
                      return await compute(
                          _print(model, fontRoot, fontSize), null);
                    } catch (exception, stackTrace) {
                      print(exception);
                      // await sent.Sentry.captureException(exception,
                      //     stackTrace: stackTrace);
                    }
                  },
                  icon: const Icon(Icons.print))
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              double height = constraints.maxHeight * PdfPageFormat.mm;
              double width = constraints.maxWidth;
              // const width = 2.28346457 * PdfPageFormat.inch;
              double margin = 5 * PdfPageFormat.mm;
              double marginTop = 5 * PdfPageFormat.mm;
              double marginBottom = 5 * PdfPageFormat.mm;
              double printHeight = 300.0 * PdfPageFormat.mm;
              return PdfPreview(
                useActions: false,
                allowSharing: false,
                canChangePageFormat: false,
                build: (format) async {
                  return await _generatePdf(
                      format.copyWith(
                        // height: height * 0.74,
                        // width: width,
                        marginLeft: margin,
                        marginRight: margin,
                        marginTop: marginTop,
                        marginBottom: marginBottom,
                      ),
                      title,
                      model,
                      height,
                      fontRoot,
                      fontSize);
                },
                pageFormats: <String, PdfPageFormat>{
                  'roll57': PdfPageFormat.roll57,
                  'A4': PdfPageFormat.a4,
                  'Letter': PdfPageFormat.letter,
                },
              );
            },
          ),
        );
      },
      viewModelBuilder: () {
        return PrintViewModel(deliveryNote, invoice);
      },
    );
  }

  _print(PrintViewModel model, String fontRoot, double fontSize) async {
    var result = false;
    if (model.invoice.transactionStatus.toLowerCase() != "completed") {
      result = await model.confirmSale();
    } else {
      result = true;
    }

    final font = await rootBundle.load(fontRoot);
    final ttf = pw.Font.ttf(font);
    if (result) {
      const imageProvider = const AssetImage('assets/images/dds_logo.png');

      final image = await flutterImageProvider(imageProvider);
      final width = PdfPageFormat.roll57.availableWidth * PdfPageFormat.mm;
      final marginBottom = 15.0 * PdfPageFormat.mm;
      final marginLeft = 0.0 * PdfPageFormat.mm;
      final marginRight = 0.0 * PdfPageFormat.mm;
      final pdf = pw.Document(compress: true);
      // final PdfImage image = PdfImage.jpeg(pdf.document, image: bytes);
      final pw.TextStyle style = pw.TextStyle(
        font: ttf,
        fontSize: fontSize,
      );
      List<pw.Widget> widgets = [];
      _buildWidgetTree() {
        List<pw.Widget> tree = [
          _buildHeader(image, model, style),
          _buildSellersDetail(user, style, model),
          // _buildSectionHeader("URA Information", style),
          // _buildURAInformation(style, model),
          _buildSectionHeader("Buyers Details", style),
          _buildBuyerDetails(model, style),
          _buildSectionHeader("Goods and Services Details", style),
          ..._buildGoodsAndServices(
              items ??
                  deliveryNote.deliveryItems ??
                  model.finalizedInvoice.items,
              style),
          _buildSpacer(),
          // _buildSectionHeader("Tax Details", style),
          // _buildTaxDetails(model, style),
          _buildSectionHeader("Summary", style),
          _buildSummary(model, style),
          pw.SizedBox(height: 20),
          _drawQRCode(model),
          pw.SizedBox(height: 20),
          _buildFooter(model, style),
          pw.SizedBox(height: 20),
          _buildSpacer(),
        ];
        widgets.addAll(tree);
      }

      _buildWidgetTree();
      pdf.addPage(
        pw.Page(
          theme: pw.ThemeData(
              paragraphStyle: pw.TextStyle(fontSize: fontSize, font: ttf),
              defaultTextStyle: pw.TextStyle(fontSize: fontSize, font: ttf)),
          pageFormat: PdfPageFormat.roll57.copyWith(
              width: width * 2.65,
              // width: PdfPageFormat.roll80.width * PdfPageFormat.mm,
              marginBottom: marginBottom,
              marginLeft: marginLeft,
              marginRight: marginRight),
          build: (pw.Context context) => pw.Center(
            child: pw.Column(
                mainAxisSize: pw.MainAxisSize.max,
                children: widgets,
                crossAxisAlignment: pw.CrossAxisAlignment.stretch),
          ),
        ),
      );
      var result = await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => await pdf.save(),
      );
      print("layout result is $result");
    }
  }

  Future<Uint8List> _generatePdf(
      PdfPageFormat format,
      String title,
      PrintViewModel model,
      double widgetHeight,
      String fontRoot,
      double fontSize) async {
    List<pw.Widget> widgets = [];
    final font = await rootBundle.load(fontRoot);
    final ttf = pw.Font.ttf(font);
    const imageProvider = AssetImage('assets/images/dds_logo.png');
    final image = await flutterImageProvider(imageProvider);
    final width = PdfPageFormat.roll57.width * PdfPageFormat.mm;
    final marginBottom = 10.0 * PdfPageFormat.mm;
    final marginLeft = 5.0 * PdfPageFormat.mm;
    final marginRight = 5.0 * PdfPageFormat.mm;
    final pdf = pw.Document(compress: true);
    final pw.TextStyle style = pw.TextStyle(
      font: ttf,
      fontSize: fontSize,
    );
    _buildWidgetTree() {
      List<pw.Widget> tree = [
        // _buildPrintRef(model, style),
        _buildHeader(image, model, style),
        // _buildSectionHeader("Sellers Detail", style),
        _buildSellersDetail(user, style, model),
        _buildSectionHeader("Buyers Details", style),
        _buildBuyerDetails(model, style),
        _buildSectionHeader("Goods and Services Details", style),
        // ..._buildGoodsAndServices(items ?? deliveryNote.deliveryItems, style),
        _buildSpacer(),
        // _buildSectionHeader("Tax Details", style),
        // _buildTaxDetails(model, style),
        _buildSectionHeader(
            "Summary", style.copyWith(fontWeight: pw.FontWeight.bold)),
        _buildSummary(model, style),
        pw.SizedBox(height: 20),
        // _buildFooter(model, style),
        pw.SizedBox(height: 20),
        // _buildSpacer(),
      ];
      widgets.addAll(tree);
    }

    _buildWidgetTree();
    pdf.addPage(
      pw.Page(
          theme: pw.ThemeData(
              header0: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              paragraphStyle: pw.TextStyle(fontSize: fontSize),
              defaultTextStyle: pw.TextStyle(fontSize: fontSize)),
          pageFormat: PdfPageFormat.roll57.copyWith(
              width: width,
              marginBottom: marginBottom,
              marginLeft: marginLeft,
              marginRight: marginRight),
          build: (pw.Context context) => pw.Center(
              child: pw.Column(
                  mainAxisSize: pw.MainAxisSize.max,
                  children: widgets,
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch))),
    );
    return await pdf.save();
  }

  ///
  /// Build the header of the invoice
  ///
  _buildHeader(
      pw.ImageProvider image, PrintViewModel model, pw.TextStyle style) {
    return pw.Row(children: [
      pw.Padding(
        child: pw.Container(
            child: pw.Image(image, height: 150), width: 300, height: 320),
        // child: pw.Image(image, height: 150),
        // width: 100,
        // height: 100),
        padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      ),
      pw.Text(title.toUpperCase(),
          style: style.copyWith(fontSize: 55, fontWeight: pw.FontWeight.bold)),
      // pw.Placeholder(fallbackHeight: 50, fallbackWidth: 50),
    ], mainAxisAlignment: pw.MainAxisAlignment.spaceBetween);
  }

  _buildBuyerDetails(PrintViewModel model, pw.TextStyle style) {
    return pw.Column(children: [
      pw.Row(children: [
        pw.Text('Customer Name :', style: style),
        pw.Text(deliveryNote.customerName ?? "", style: style)
      ]),
      // customerTIN.isNotEmpty
      //     ? pw.Row(children: [
      //         pw.Text('Customer TIN :', style: style),
      //         pw.Text(customerTIN ?? "", style: style)
      //       ])
      //     : pw.Container(height: 0),
    ]);
  }

  _buildGoodsAndServices(List deliveryItems, pw.TextStyle style) {
    return deliveryItems.map((deliveryItem) {
      num deliveredQty =
          deliveryItem['deliveredQty'] ?? deliveryItem['quantity'] ?? 0.0;
      num total = deliveredQty * deliveryItem['itemRate'];
      if (deliveredQty > 0.0) {
        return pw.Padding(
          padding: pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Row(children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                        deliveryItem['itemName'].toString().toUpperCase(),
                        style: style),
                  ),
                ]),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    // pw.SizedBox(width: 1),
                    // pw.Container(
                    //   width: 30,
                    //   child: pw.Text(deliveryItem['itemCode'],
                    //       style: style, textAlign: pw.TextAlign.left),
                    // ),
                    // pw.SizedBox(width: 5),
                    // pw.Expanded(
                    //   flex: 3,
                    //   child: pw.Text(deliveryItem['itemCode'],
                    //       style: style.copyWith(
                    //           fontWeight: pw.FontWeight.bold, fontSize: 16)),
                    // ),
                    pw.Container(
                      width: 20,
                      child: pw.Text(deliveredQty.toString(),
                          style: style, textAlign: pw.TextAlign.right),
                    ),
                    pw.SizedBox(width: 5),
                    pw.Container(
                      child: pw.Text(
                          Helper.formatCurrency(deliveryItem['itemRate']),
                          style: style,
                          textAlign: pw.TextAlign.right),
                    ),
                    pw.SizedBox(width: 5),
                    pw.Container(
                        child: pw.Text(Helper.formatCurrency(total),
                            style: style, textAlign: pw.TextAlign.left))
                  ],
                ),
              ]),
        );
      } else {
        return pw.Container(height: 0);
      }
    }).toList();
  }

  _buildSectionHeader(final String sectionHeader, pw.TextStyle style) {
    return pw.Column(children: [
      pw.Divider(thickness: 1.5),
      pw.Text(sectionHeader, style: style),
      pw.Divider(thickness: 1.5),
    ]);
  }

  _buildSellersDetail(
    User user,
    pw.TextStyle textStyle,
    PrintViewModel model,
  ) {
    var deliveryNoteId = deliveryNote.deliveryNoteId == null
        ? deliveryNote.referenceNo
        : orderId;
    return pw.Column(children: [
      pw.SizedBox(height: 5),
      pw.Text('DDS SAAS'.toUpperCase(), style: textStyle),
      pw.Text('P.O BOX 64443-00620 Nairobi'.toUpperCase(), style: textStyle),
      pw.Text('info@foursumlimited.co.ke', style: textStyle),
      pw.Text('Tel:0719555999,0737644430,0732', style: textStyle),
      pw.Text("PIN : P051969170B", style: textStyle),
      pw.Text(user.branch.toUpperCase(), style: textStyle),
      pw.SizedBox(height: 5),
      pw.Row(children: [
        pw.Text("Date: "),
        pw.Text("${Helper.formatToTime(model.dateTime)}"),
        pw.SizedBox(width: 5),
        pw.Text("${Helper.formatDate(model.dateTime)} "),
      ], mainAxisAlignment: pw.MainAxisAlignment.center),
      _buildSpacer(),
      pw.Row(
        children: [
          pw.Text('Transaction Id : ', style: textStyle),
          pw.Text('${model.invoice.id}', style: textStyle),
        ],
      ),
      pw.Row(
        children: [
          pw.Text('Transaction Date : ', style: textStyle),
          pw.Text(
              '${Helper.formatDateFromString(model.invoice.transactionDate)} ${Helper.formatTimeFromString(model.invoice.transactionDate)}',
              style: textStyle),
        ],
      ),
      // pw.Row(
      //   children: [
      //     pw.Text('Transaction Time : ', style: textStyle),
      //     pw.Text(
      //         '${Helper.formatTimeFromString(model.invoice.transactionDate)}',
      //         style: textStyle),
      //   ],
      // ),
      pw.Row(
        children: [
          pw.Text('Type : ', style: textStyle),
          pw.Text('${model.invoice.transactionType}', style: textStyle),
        ],
      ),
      pw.Row(
        children: [
          pw.Text('Transaction Status : ', style: textStyle),
          pw.Text(
              '${model.finalizedInvoice == null ? model.invoice.transactionType : model.finalizedInvoice.transactionStatus}',
              style: textStyle),
        ],
      ),
      pw.Row(
        children: [
          pw.Text('Served By : ', style: textStyle),
          pw.Text(user.full_name, style: textStyle),
        ],
      ),
    ]);
  }

  _buildSpacer() {
    return pw.SizedBox(height: 10);
  }

  _buildFooter(PrintViewModel model, pw.TextStyle style) {
    return pw.Column(children: [
      // _buildSpacer(),
      pw.SizedBox(height: 2),
      pw.Text("Powered by DDS ver:${model.versionCode}", style: style),
      pw.SizedBox(height: 1),
    ], crossAxisAlignment: pw.CrossAxisAlignment.center);
  }

  _buildSummary(PrintViewModel model, pw.TextStyle style) {
    double totalTendered =
        model.finalizedInvoice.gross - model.finalizedInvoice.discount;

    // subtotal - discount * 0.16

    double tax = model.finalizedInvoice?.gross * 0.16 / 1.16;
    double totalBeforeTax = model.finalizedInvoice.gross - tax;

    // computed tax
    double computedTax =
        (totalBeforeTax - model.finalizedInvoice.discount) * 0.16;

    double change =
        (model.finalizedInvoice.gross + model.finalizedInvoice.discount) -
            totalTendered;

    return pw.Column(children: [
      pw.SizedBox(height: 5),
      pw.Row(children: [
        pw.Text('Subtotal', style: style),
        _buildCurrencyWidget(totalBeforeTax, style),
      ], mainAxisAlignment: pw.MainAxisAlignment.spaceBetween),
      pw.Row(children: [
        pw.Text('Tax Amount', style: style),
        _buildCurrencyWidget(model.finalizedInvoice?.tax, style),
      ], mainAxisAlignment: pw.MainAxisAlignment.spaceBetween),
      pw.Row(children: [
        pw.Text('Discount', style: style),
        _buildCurrencyWidget(model.finalizedInvoice?.discount, style),
      ], mainAxisAlignment: pw.MainAxisAlignment.spaceBetween),
      pw.Row(children: [
        pw.Text('Withholding Tax', style: style),
        _buildCurrencyWidget(model.finalizedInvoice?.withholdingTax, style),
      ], mainAxisAlignment: pw.MainAxisAlignment.spaceBetween),
      pw.Row(children: [
        pw.Text('Total', style: style),
        _buildCurrencyWidget(model.finalizedInvoice?.gross, style),
      ], mainAxisAlignment: pw.MainAxisAlignment.spaceBetween),
      pw.Row(children: [
        pw.Text('Total tendered', style: style),
        _buildCurrencyWidget(totalTendered, style),
      ], mainAxisAlignment: pw.MainAxisAlignment.spaceBetween),
      pw.Row(children: [
        pw.Text('Change', style: style),
        _buildCurrencyWidget(change, style),
      ], mainAxisAlignment: pw.MainAxisAlignment.spaceBetween),
      pw.SizedBox(height: 5),
      pw.Row(children: [
        pw.Text('Currency', style: style),
        pw.Text(model.currency)
      ], mainAxisAlignment: pw.MainAxisAlignment.spaceBetween),
      pw.Row(children: [
        pw.Text('Number Of Items', style: style),
        pw.Text('${model.invoice.items.length}', style: style),
      ], mainAxisAlignment: pw.MainAxisAlignment.spaceBetween),
    ]);
  }

  _buildTaxDetails(PrintViewModel model, pw.TextStyle style) {
    return pw.Column(children: [
      pw.SizedBox(height: 5),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text('Tax Category : ', style: style),
          pw.Text('A: Standard (${(model.taxRate * 100).toStringAsFixed(0)}%)',
              style: style),
        ],
      ),
      pw.SizedBox(height: 3),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Net Amt', style: style),
          // pw.Text('Tax Amt', style: style),
          pw.Text('Gross Amt', style: style),
        ],
      ),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _buildCurrencyWidget(model.finalizedInvoice?.net, style),
          // _buildCurrencyWidget(tax, style),
          _buildCurrencyWidget(model.finalizedInvoice?.gross, style),
        ],
      ),
    ]);
  }

  _buildCurrencyWidget(
    num val,
    pw.TextStyle style,
  ) {
    return pw.Text('${Helper.formatCurrency(val)}', style: style);
  }

  ///
  /// Build printer information
  /// Build version info
  ///
  _buildPrintRef(PrintViewModel model, pw.TextStyle style) {
    return pw.Row(children: [
      pw.Text("${model.versionCode}-${model.deviceId}"),
    ], mainAxisAlignment: pw.MainAxisAlignment.end);
  }

  _buildURAInformation(pw.TextStyle style, PrintViewModel model) {
    return pw.Column(children: [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Document Type', style: style),
          pw.Text('${model.documentType}', style: style),
        ],
      ),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Issued Date', style: style),
          pw.Text('${model.invoice.transactionDate}', style: style)
        ],
      ),
      // pw.Row(
      //   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      //   children: [
      //     pw.Text('Time', style: style),
      //     pw.Text(
      //         '${Helper.formatTimeFromString(model.invoice.transactionDate)}',
      //         style: style),
      //   ],
      // ),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Device No', style: style),
          pw.Text(model.invoice.deviceNo, style: style)
        ],
      ),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('FDN', style: style),
          pw.Text('${model.finalizedInvoice.fdn}', style: style)
        ],
      ),
      pw.SizedBox(height: 5),
      pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text('Verification Code', style: style),
          pw.Text('${model.finalizedInvoice.verificationCode}', style: style),
        ],
      ),
    ]);
  }

  _drawQRCode(PrintViewModel model) {
    return pw.Center(
      child: pw.BarcodeWidget(
        // drawText: true,
        color: PdfColor.fromHex("#000000"),
        barcode: pw.Barcode.qrCode(),
        data: model.finalizedInvoice.verificationCode.toString(),
        // data: "This is a test",
        width: 300,
        height: 300,
      ),
    );
  }
}
