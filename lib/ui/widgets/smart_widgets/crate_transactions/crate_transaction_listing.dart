import 'dart:convert';

import 'package:distributor/conf/style/lib/colors.dart';
import 'package:distributor/conf/style/lib/text_styles.dart';
import 'package:distributor/src/strings.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';
import 'package:distributor/ui/widgets/dumb_widgets/empty_content_container.dart';
import 'package:distributor/ui/widgets/smart_widgets/crate_transactions/crate_transaction_listing_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class CrateTransactionListingView extends StatelessWidget {
  CrateTransactionListingView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CrateTransactionListingViewModel>.reactive(
      onModelReady: (model) => model.init(),
      fireOnModelReadyOnce: false,
      disposeViewModel: false,
      builder: (context, model, child) {
        return model.hasSelectedJourney == true
            ? model.isBusy
                ? Center(child: BusyWidget())
                : model.crateTransactionListings.isNotEmpty
                    ? RefreshIndicator(
                        backgroundColor: kColorDDSPrimaryDark,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            var crateTxn =
                                model.crateTransactionListings[index];
                            bool isSynced = !crateTxn['transactionItemId']
                                .toString()
                                .toLowerCase()
                                .contains("off");
                            var description =
                                json.decode(crateTxn['description']);
                            return ListTile(
                              title: Row(
                                children: [
                                  Text(
                                      description['customer'] ??
                                          "Unknown Customer",
                                      style: kTileLeadingTextStyle),
                                ],
                              ),
                              subtitle: Row(
                                children: [
                                  isSynced
                                      ? Container()
                                      : Icon(
                                          Icons.timer_sharp,
                                          size: 12,
                                        ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    child: Text(
                                      crateTxn['itemName'],
                                      style: kTileSubtitleTextStyle,
                                    ),
                                  ),
                                  _buildTransactionWidget(crateTxn['quantity']),
                                  // Text(
                                  //     "Received : ${description['received'] ?? "-"} | Dropped : ${description['dropped'] ?? "-"}"),
                                ],
                              ),
                            );
                          },
                          itemCount: model.crateTransactionListings.length,
                        ),
                        onRefresh: () => model.getCrateTransactions())
                    : Container(
                        child: Center(
                          child: EmptyContentContainer(
                              label: kStringNoCrateTransactions),
                        ),
                      )
            : Container(
                child: Center(
                  child:
                      EmptyContentContainer(label: kStringNoCrateTransactions),
                ),
              );
      },
      viewModelBuilder: () => CrateTransactionListingViewModel(),
    );
  }

  _buildTransactionWidget(int value) {
    // var received = description['received'];
    // var dropped = description['dropped'];
    if (value >= 0) {
      return Text(
        "RECEIVED : ${value}",
        style: kCrateReceivedTextStyle,
      );
    }
    if (value.isNegative) {
      return Text(
        "DROPPED : ${value * -1}",
        style: kCrateDroppedTextStyle,
      );
    }
    return Text("");
  }
}
