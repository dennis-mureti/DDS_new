import 'package:camera/camera.dart';
import 'package:distributor/src/ui/views/pos/scanner/scanner_viewmodel.dart';
import 'package:distributor/ui/widgets/action_button.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../../../ui/widgets/dumb_widgets/misc_widgets.dart';

class ScannerView extends StatelessWidget {
  const ScannerView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ScannerViewModel>.reactive(
        onModelReady: (model) => model.init(),
        builder: (context, model, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Scan SKU'),
              actions: [
                IconButton(
                    onPressed: model.items.isNotEmpty ? model.clearItems : null,
                    icon: Icon(Icons.refresh))
              ],
            ),
            body: Container(
              child: model.isBusy
                  ? Center(child: BusyWidget())
                  : Column(
                      children: [
                        //Camera widget
                        FutureBuilder<void>(
                          future: model.initializeControllerFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              // If the Future is complete, display the preview.
                              return Container(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: AspectRatio(
                                    child:
                                        CameraPreview(model.cameraController),
                                    aspectRatio: 4 / 1,
                                  ),
                                ),
                              );
                            } else {
                              // Otherwise, display a loading indicator.
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                          },
                        ),
                        Divider(),
                        model.items.isNotEmpty
                            ? Expanded(child:
                                ListView.builder(itemBuilder: (context, index) {
                                return Text('');
                              }))
                            : Expanded(
                                child: Center(child: Text("No items added"))),

                        //List scanned items
                        // Expanded(),
                        Spacer(),
                        ActionButton(onPressed: null, label: 'Checkout')
                      ],
                    ),
            ),
          );
        },
        viewModelBuilder: () => ScannerViewModel());
  }
}
