import 'package:distributor/conf/style/lib/colors.dart';
import 'package:distributor/ui/widgets/smart_widgets/syncWidget/syncWidgetViewModel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class SyncWidget extends StatelessWidget {
  const SyncWidget({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SyncWidgetViewModel>.reactive(
        onModelReady: (model) => model.syncData(),
        builder: (context, model, child) {
          return Container(
            child: model.status
                ? Container()
                : Column(
                    children: [
                      // Text("Sync in progress"),
                      LinearProgressIndicator(
                        minHeight: 5,
                        // color: kColorDDSPrimaryDark,
                        color: Colors.white,
                        backgroundColor: kColorDDSPrimaryDark,
                      )
                    ],
                  ),
          );
        },
        viewModelBuilder: () => SyncWidgetViewModel());
  }
}
