import 'dart:typed_data';

import 'package:distributor/core/helper.dart';
import 'package:distributor/src/ui/views/print_view/quotation_printviewmodel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:stacked/stacked.dart';

class QuotationPrintView extends StatelessWidget {
  final quotation;
  final quotationId;
  final List quotationItems;
  const QuotationPrintView(
      {Key key, this.quotation, this.quotationId, this.quotationItems});

  @override
  Widget build(BuildContext context) {
    final String fontRoot = "assets/fonts/proxima_nova/normal/proxima.ttf";
    final double fontSize = 60.5;
    return ViewModelBuilder<QuotationPrintViewModel>.reactive(
      onModelReady: (model) => model.init(),
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Quotation'),
            actions: [
              IconButton(
                onPressed: () async {
                  try {
                    return await compute(
                        _print(model, fontRoot, fontSize, quotationItems,
                            quotationId, quotation),
                        null);
                  } catch (exception, stackTrace) {
                    print(exception);

                    // await sent.Sentry.captureException(exception,
                    //     stackTrace: stackTrace);
                  }
                },
                icon: Icon(Icons.print),
              )
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
                  // onError: (context) {
                  //   return Text("Error");
                  // },
                  allowSharing: false,
                  canChangePageFormat: false,
                  build: (format) => _generatePdf(
                      format.copyWith(
                        // height: height * 0.74,
                        // width: width,
                        marginLeft: margin,
                        marginRight: margin,
                        marginTop: marginTop,
                        marginBottom: marginBottom,
                      ),
                      model,
                      quotationItems,
                      quotationId,
                      quotation,
                      height,
                      fontRoot,
                      fontSize),
                  pageFormats: <String, PdfPageFormat>{
                    'roll57': PdfPageFormat.roll57,
                    'A4': PdfPageFormat.a4,
                    'Letter': PdfPageFormat.letter,
                  });
            },
          ),
        );
      },
      viewModelBuilder: () => QuotationPrintViewModel(quotation, quotationId),
    );
  }
}

_print(QuotationPrintViewModel model, String fontRoot, double fontSize,
    List quotationItems, String quotationNumber, var quotation) async {
  final font = await rootBundle.load(fontRoot);
  final ttf = pw.Font.ttf(font);
  const imageProvider = AssetImage('assets/images/dds_logo.png');
  final image = await flutterImageProvider(imageProvider);
  final width = PdfPageFormat.roll57.availableWidth * PdfPageFormat.mm;
  final marginBottom = 15.0 * PdfPageFormat.mm;
  final marginLeft = 0.0 * PdfPageFormat.mm;
  final marginRight = 0.0 * PdfPageFormat.mm;
  final pdf = pw.Document(compress: true);
  final pw.TextStyle style = pw.TextStyle(
    font: ttf,
    fontSize: fontSize,
  );
  List<pw.Widget> widgets = [];
  _buildWidgetTree() {
    List<pw.Widget> tree = [
      _buildTitle(),
      _buildHeader(image, style),
      _buildSellersDetail(style),
      pw.Divider(thickness: 1.5),
      _buildCustomerInfo(model, quotationNumber, quotation),
      pw.SizedBox(height: 10),
      pw.Divider(thickness: 1.5),
      ..._buildItemsSection(quotationItems, model, style),
      pw.Divider(thickness: 1.5),
      pw.SizedBox(height: 10),
      _buildTaxInfo(model),
      pw.Divider(thickness: 1.5),
      pw.SizedBox(height: 10),
      // _buildValidationSection(),
      pw.SizedBox(height: 10),
      _buildPaymentFooterInfo(),
      pw.SizedBox(height: 20),
      pw.Divider(
        thickness: 2.0,
      )
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
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}

_buildSellersDetail(
  pw.TextStyle textStyle,
) {
  return pw.Column(children: [
    pw.SizedBox(height: 5),
    pw.Text('DDS SAASs'.toUpperCase(), style: textStyle),
    pw.Text('P.O BOX 64443-00620 Nairobi'.toUpperCase(), style: textStyle),
    pw.Text('info@foursumlimited.co.ke', style: textStyle),
    pw.Text('Tel:0719555999,0737644430,0732', style: textStyle),
    pw.Text("PIN : P051969170B", style: textStyle),
    pw.SizedBox(height: 5),
  ]);
}

Future<Uint8List> _generatePdf(
    PdfPageFormat format,
    QuotationPrintViewModel model,
    List quotationItems,
    quotationNumber,
    var quotation,
    double widgetHeight,
    String fontRoot,
    double fontSize) async {
  try {
    final font = await rootBundle.load(fontRoot);
    final ttf = pw.Font.ttf(font);
    const imageProvider = const AssetImage('assets/images/dds_logo.png');
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
    List<pw.Widget> widgets = [];
    _buildWidgetTree() {
      List<pw.Widget> tree = [
        _buildTitle(),
        _buildHeader(image, style),
        _buildSellersDetail(style),
        _buildCustomerInfo(model, quotationNumber, quotation),
        pw.SizedBox(height: 10),
        //..._buildItemsSection(quotationItems, model, style),
        pw.SizedBox(height: 10),
        _buildTaxInfo(model),
        pw.SizedBox(height: 10),
        // _buildValidationSection(),
        pw.SizedBox(height: 10),
        _buildPaymentFooterInfo()
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
                crossAxisAlignment: pw.CrossAxisAlignment.stretch)),
      ),
    );
    return await pdf.save();
  } catch (e) {
    print(e);
  }
}

///
/// The type of document
///
_buildTitle() {
  return pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
    pw.Text('',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 40))
  ]);
}

///
/// Branding anc 4Sum contact info
///
// _buildHeader(pw.ImageProvider image, pw.TextStyle style) {
//   return pw.Row(children: [
//     pw.Column(children: [
//       pw.Padding(
//         child: pw.Container(
//             child: pw.Image(image, height: 150), width: 200, height: 200),
//         padding: pw.EdgeInsets.symmetric(vertical: 5, horizontal: 5),
//       ),
//     ]),
//     pw.Column(children: [
//       pw.Text('FOURSUM LIMITED', style: style),
//       pw.Text('P.O BOX 64443-00620 Nairobi', style: style),
//       pw.Text('info@foursumlimited.co.ke', style: style),
//       pw.Text('Tel:0719555999,0737644430', style: style),
//       pw.Text('PIN:P051969170B', style: style),
//     ], crossAxisAlignment: pw.CrossAxisAlignment.start),
//   ], mainAxisAlignment: pw.MainAxisAlignment.spaceBetween);
// }

_buildHeader(pw.ImageProvider image, pw.TextStyle style) {
  return pw.Row(children: [
    pw.Padding(
      child: pw.Container(
          child: pw.Image(image, height: 150), width: 300, height: 320),
      padding: pw.EdgeInsets.symmetric(vertical: 5, horizontal: 5),
    ),
    pw.Text('QUOTATION',
        style: style.copyWith(fontSize: 55, fontWeight: pw.FontWeight.bold)),

    // pw.Placeholder(fallbackHeight: 50, fallbackWidth: 50),
  ], mainAxisAlignment: pw.MainAxisAlignment.spaceBetween);
}

///
/// Customer information
///
_buildCustomerInfo(
    QuotationPrintViewModel model, String quotationNo, var quotation) {
  return pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Row(children: [
          pw.Text('Customer : '),
          pw.Text(model.quotation['customer']['name']),
          // pw.Text('KRA PIN Number')
        ], crossAxisAlignment: pw.CrossAxisAlignment.start),
        pw.Row(children: [
          pw.Text("Quotation No: ${quotationNo}"),

          // pw.Text("Validity date: ${Helper.formatDateFromString(DateTime.now().toIso8601String())}"),
          // pw.Text(''),
          // pw.Text(''),
          // pw.Text('KRA PIN Number'),
          // pw.Text("Your Reference: "),
          // pw.Text("Delivery Mode: "),
          // pw.Text("Contact Person Mode: ")
        ], crossAxisAlignment: pw.CrossAxisAlignment.start),
        // pw.Column(children: [_drawQRCode(model)]),
        pw.Row(children: [
          pw.Text(
              "Document Date: ${Helper.formatDateFromString(DateTime.now().toIso8601String())}"),
        ]),
        pw.Column(
          children: [
            pw.Row(children: [
              // pw.Text("Invoice Number: "),
              // pw.Text(""),
              // pw.Row(children: [pw.Text("Control Code: "), pw.Text('')]),
              // pw.Row(children: [pw.Text("CU Serial Number: "), pw.Text('')]),
              // pw.Row(children: [pw.Text("Due date: "), pw.Text('')]),
              // pw.Row(children: [pw.Text("Your Reference: "), pw.Text('')]),
              // pw.Row(children: [pw.Text("Delivery Mode: "), pw.Text('')]),
              // pw.Row(children: [pw.Text("Contact Person Mode: "), pw.Text('')]),
              pw.SizedBox(height: 5),
            ], crossAxisAlignment: pw.CrossAxisAlignment.start)
          ],
        ),
      ]);
}

_buildTaxInfo(QuotationPrintViewModel model) {
  return pw.Column(children: [
    pw.SizedBox(height: 10),
    pw.Row(
      children: [
        pw.Text("Payment Term"),
        pw.Text("Cash"),
      ],
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    ),
    pw.Column(children: [
      // pw.Row(
      //   children: [
      //     pw.Text('Net:'),
      //     pw.Text('${model.quotation['net'].toStringAsFixed(2)}'),
      //   ],
      // ),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Subtotal : '),
          pw.Text('${model.net.toStringAsFixed(2)}'),
        ],
      ),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Discount Amount : '),
          pw.Text('${model.quotation['discount'].toStringAsFixed(2)}'),
        ],
      ),
      // pw.Row(
      //   children: [
      //     pw.Text('Withholding : '),
      //     pw.Text('${model.quotation['withholding'].toStringAsFixed(2)}'),
      //   ],
      // ),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('VAT Amount : '),
          pw.Text('${model.tax.toStringAsFixed(2)}'),
        ],
      ),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Withholding VAT : '),
          pw.Text(
              '${model.quotation['withHoldingTax']?.toStringAsFixed(2) ?? ""}'),
        ],
      ),

      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Total Amount : '),
          pw.Text('${model.total.toStringAsFixed(2)}'),
        ],
      ),
      pw.SizedBox(height: 10),
    ], crossAxisAlignment: pw.CrossAxisAlignment.start),
  ], mainAxisAlignment: pw.MainAxisAlignment.spaceBetween);
}

_buildValidationSection() {
  return pw.Row(children: [
    pw.Column(children: [
      pw.Text('Prepared By'),
      pw.Text('Approved By Finance'),
      pw.Text('Dispatched By'),
      pw.Text('Delivered By'),
      pw.Text('Received By'),
    ], crossAxisAlignment: pw.CrossAxisAlignment.start),
    pw.Column(children: [
      pw.Text('Signature'),
      pw.Text('Signature'),
      pw.Text('Signature'),
      pw.Text('Vehicle Reg No'),
      pw.Text('Signature'),
    ], crossAxisAlignment: pw.CrossAxisAlignment.start),
    pw.Column(children: [
      pw.Text('Date'),
      pw.Text('Date'),
      pw.Text('Date'),
      pw.Text('Signature'),
      pw.Text('Date'),
    ], crossAxisAlignment: pw.CrossAxisAlignment.start),
  ], mainAxisAlignment: pw.MainAxisAlignment.spaceBetween);
}

///
/// Render the payment information
///
_buildPaymentFooterInfo() {
  return pw.Column(children: [
    pw.Text(
        'Pay To Bank: Foursum Limited Bank: Equity Bank (Kenya) Limited Branch:'),
    pw.Text('Eastleigh Account number: 1340280343168'),
    pw.Text('Swift No. EQBLKENA'),
    pw.Text('Pay to Mpesa: Till Number : 8375158'),
    pw.SizedBox(height: 10),
    pw.Text(
        'Terms: Goods once sold cannot be returned. All goods belong to Foursum Limited until fully paid for. Signed Terms of Trade Apply.',
        textAlign: pw.TextAlign.center),
  ]);
}

_buildItemData(List items, QuotationPrintViewModel model, pw.TextStyle style) {
  List<TableRow> _rows = <TableRow>[];
  return items
      .map((item) => pw.Padding(
          padding: pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Column(children: [
            pw.Row(children: [
              pw.Expanded(
                flex: 3,
                child: pw.Text(item['itemName'].toString().toUpperCase(),
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
                //   child: pw.Text(item['itemCode'],
                //       style: style, textAlign: pw.TextAlign.left),
                // ),
                // pw.SizedBox(width: 10),
                // pw.Expanded(
                //   flex: 3,
                //   child: pw.Text(deliveryItem['itemCode'],
                //       style: style.copyWith(
                //           fontWeight: pw.FontWeight.bold, fontSize: 16)),
                // ),
                pw.Container(
                  width: 20,
                  child: pw.Text(item['quantity'].toString(),
                      style: style, textAlign: pw.TextAlign.right),
                ),
                pw.SizedBox(width: 5),
                pw.Container(
                  child: pw.Text(Helper.formatCurrency(item['itemPrice']),
                      style: style, textAlign: pw.TextAlign.right),
                ),
                pw.SizedBox(width: 5),
                pw.Container(
                    child: pw.Text(
                        Helper.formatCurrency(
                            (item['itemPrice'] * item['quantity'])),
                        style: style,
                        textAlign: pw.TextAlign.left))
              ],
            ),
          ])))
      .toList();
}

_buildItemsSection(
    List items, QuotationPrintViewModel model, pw.TextStyle style) {
  pw.TableRow header = pw.TableRow(
    children: [
      pw.Text('Item'),
      pw.Text('Description'),
      pw.Text('Qty'),
      pw.Text('Price'),
      // pw.Text('Price(VATExc)'),
      // pw.Text('Disc'),
      // pw.Text('Tax%'),
      // pw.Text('VAT Total'),
      pw.Text('Total')
    ],
  );
  // List<pw.TableRow> _itemDataRows = _buildItemData(items, model, style);
  // List<pw.TableRow> itemsSectionData = [header];
  // itemsSectionData.addAll(_itemDataRows);
  // return pw.Table(children: _buildItemData(items, model, style));
  return _buildItemData(items, model, style);
}

_drawQRCode(QuotationPrintViewModel model) {
  return pw.Center(
    child: pw.BarcodeWidget(
      // drawText: true,
      color: PdfColor.fromHex("#000000"),
      barcode: pw.Barcode.qrCode(),
      data: "",
      // data: "This is a test",
      width: 50,
      height: 50,
    ),
  );
}
