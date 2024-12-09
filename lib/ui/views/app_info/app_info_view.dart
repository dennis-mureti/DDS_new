import 'package:distributor/ui/views/app_info/app_info_viewmodel.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';
import 'package:distributor/ui/widgets/dumb_widgets/generic_container.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class AppInfoView extends StatelessWidget {
  const AppInfoView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AppInfoViewModel>.reactive(
        onModelReady: (model) => model.init(),
        builder: (context, model, child) => Scaffold(
              appBar: AppBar(
                title: Text('About'),
              ),
              body: model.isBusy
                  ? BusyWidget()
                  : GenericContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Image.asset(
                                'assets/images/dds_logo.png',
                              ),
                            ),
                          ),
                          Text(
                              'DDS Version : ${model.appVersion?.versionCode}'),
                          Divider(),
                          Text(
                              'Android Version : ${model.androidDeviceInfo.version.release}'),
                          Text('Product : ${model.androidDeviceInfo.product}'),
                          Text('Brand : ${model.androidDeviceInfo.brand}'),
                          Text(
                              'Manufacturer : ${model.androidDeviceInfo.manufacturer}'),
                          Text('Device : ${model.androidDeviceInfo.device}'),
                          Text(
                              'Device Id : ${model.androidDeviceInfo.androidId}'),
                        ],
                      ),
                    ),
            ),
        viewModelBuilder: () => AppInfoViewModel());
  }
}
