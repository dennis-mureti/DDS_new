import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PrintButton extends StatelessWidget {
  const PrintButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        //List of pdf widgets
        List<pw.Widget> widgets = [];
        //Profile image
        const imageProvider = const AssetImage('assets/images/mini_logo.png');
        final image = pw.ClipOval(
          child: pw.Image(
            await flutterImageProvider(imageProvider),
            fit: pw.BoxFit.cover,
            width: 200,
            height: 200,
          ),
        );

        //container for profile image decoration
        final container = pw.Center(
          child: pw.Container(
            child: image,
            padding: const pw.EdgeInsets.all(5),
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              border: pw.Border.all(
                color: PdfColors.blue,
                width: 10,
              ),
            ),
          ),
        );

        //add decorated image container to widgets list
        // widgets.add(container);
        // widgets.add(pw.SizedBox(height: 20));

        for (int i = 0; i < 5; i++) {
          widgets.add(
            pw.Text(
              'Heading',
              style: pw.TextStyle(
                fontSize: 25,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          );
          widgets.add(pw.SizedBox(height: 5));
          widgets.add(
            pw.Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed sed accumsan augue, ut tincidunt lectus. Vestibulum venenatis euismod eros suscipit rhoncus. Sed vulputate congue turpis ut cursus. Proin sollicitudin nulla vel nisi vulputate sagittis. Morbi neque mauris, auctor id posuere eu, egestas porttitor justo. Donec tempus egestas lorem in convallis. Quisque fermentum, augue ut facilisis pretium, risus dolor viverra est, ac consequat tellus risus vitae sapien. ',
              style: const pw.TextStyle(color: PdfColors.grey),
            ),
          );
          widgets.add(pw.SizedBox(height: 20));
        }

        final pdf = pw.Document();
        final width = PdfPageFormat.roll57.availableWidth * PdfPageFormat.mm;
        final height = 300.0 * PdfPageFormat.mm;
        final marginTop = 5.0 * PdfPageFormat.mm;
        final marginBottom = 20.0 * PdfPageFormat.mm;
        final roll57Format = PdfPageFormat(width, 300.0 * PdfPageFormat.mm);

        final pageFormat = PdfPageFormat(width, height,
            marginTop: marginTop, marginBottom: marginBottom);
        pdf.addPage(
          pw.Page(
              pageFormat: PdfPageFormat.roll57
                  .copyWith(width: width, marginBottom: marginBottom),
              build: (pw.Context context) => pw.Column(
                  children: widgets,
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch)),
        );
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save(),
          // format: roll57Format,
        );
      },
      icon: Icon(Icons.print),
      color: Colors.yellow,
    );
  }
}
