import 'package:distributor/src/ui/views/journey_log/journey_log_viewmodel.dart';
import 'package:distributor/ui/widgets/dumb_widgets/misc_widgets.dart';
import 'package:distributor/ui/widgets/smart_widgets/map_view/delivery_journey_map_view.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stacked/stacked.dart';

class JourneyLog extends StatelessWidget {
  const JourneyLog({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<JourneyLogViewModel>.reactive(
      onModelReady: (model) => model.init(),
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Journey Detail"),
          ),
          body: model.isBusy
              ? BusyWidget()
              : Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: model.cameraPosition,
                      onMapCreated: model.onMapCreated,
                      myLocationEnabled: true,
                      mapType: MapType.hybrid,
                    ),
                    Positioned(
                        bottom: 50,
                        right: 10,
                        child: ElevatedButton(
                            child: Icon(Icons.pin_drop),
                            onPressed: () => model.addMarker()))
                  ],
                ),
        );
      },
      viewModelBuilder: () => JourneyLogViewModel(),
    );
  }
}

class JourneyMap extends StatefulWidget {
  const JourneyMap({Key key}) : super(key: key);

  @override
  State<JourneyMap> createState() => _JourneyMapState();
}

class _JourneyMapState extends State<JourneyMap> {
  GoogleMapController mapController;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [],
    );
  }
}
