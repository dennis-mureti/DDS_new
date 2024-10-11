import 'package:badges/badges.dart' as b;
import 'package:distributor/core/enums.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConnectionStatusWidget extends StatelessWidget {
  final Function syncData;
  ConnectionStatusWidget({Key key, this.syncData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var connectionStatus = Provider.of<ConnectivityStatus>(context);
    if (connectionStatus == ConnectivityStatus.Offline) {
      return b.Badge(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(Icons.signal_wifi_connected_no_internet_4),
        ),
        badgeColor: Colors.yellow,
      );
    } else {
      return IconButton(
          onPressed: () => syncData(),
          icon: Icon(
            Icons.sync_outlined,
            color: Colors.white,
          ));
    }
  }
}
