import 'package:distributor/conf/style/lib/text_styles.dart';
import 'package:distributor/src/strings.dart';
import 'package:distributor/ui/views/crate/crate_viewmodel.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';
import 'package:distributor/ui/widgets/dumb_widgets/empty_content_container.dart';
import 'package:distributor/ui/widgets/dumb_widgets/product_quantity_container.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class CrateView extends StatelessWidget {
  const CrateView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CrateViewModel>.reactive(
        onModelReady: (model) => model.init(),
        fireOnModelReadyOnce: false,
        disposeViewModel: true,
        builder: (context, model, child) {
          return model.hasSelectedJourney == true
              ? !model.hasJourneys
                  ? _buildCenterContainer(kStringNoJourney)
                  : model.isBusy
                      ? Center(child: BusyWidget())
                      : model.crateList.isEmpty
                          ? Center(
                              child: EmptyContentContainer(
                                  label: 'There are no crates available.'))
                          : ListView.builder(
                              itemBuilder: (context, index) {
                                var crate = model.crateList[index];
                                bool isSynced = crate.isSynced ?? true;
                                return ListTile(
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            crate.itemName,
                                            style: kTileLeadingTextStyle,
                                          ),
                                        ],
                                      ),
                                      ProductQuantityContainer(
                                        quantity: crate.quantity.toInt(),
                                      ),
                                    ],
                                  ),
                                  trailing: PopupMenuButton(
                                    itemBuilder: (context) {
                                      return <PopupMenuEntry<Object>>[
                                        PopupMenuItem(
                                          child: Text('Collect Crates'),
                                          value: 'receive_crates',
                                        ),
                                        PopupMenuItem(
                                            child: Text('Drop Crates'),
                                            value: 'drop_crates'),
                                      ];
                                    },
                                    onSelected: (x) {
                                      model.handleOrderAction(x);
                                    },
                                  ),
                                  subtitle: Row(
                                    children: [
                                      isSynced == true
                                          ? Container(
                                              width: 0,
                                            )
                                          : Icon(
                                              Icons.timer_sharp,
                                              size: 12,
                                            ),
                                      Text(
                                        crate.itemCode,
                                        style: kTileSubtitleTextStyle,
                                      ),
                                    ],
                                  ),
                                  // trailing: IconButton(
                                  //   onPressed: () {},
                                  //   icon: Icon(Icons.more_vert),
                                  // ),
                                );
                              },
                              itemCount: model.crateList.length,
                            )
              : Center(
                  child:
                      EmptyContentContainer(label: kStringNoJourneySelected));
        },
        viewModelBuilder: () => CrateViewModel());
  }

  _buildCenterContainer(String text) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: (Text(text)),
        ),
      ],
    );
  }
}
