import 'package:distributor/src/ui/views/quotation_view/quotation_detail_viewmodel.dart';
import 'package:distributor/ui/widgets/action_button.dart';
import 'package:distributor/ui/widgets/dumb_widgets/app_bar_column_title.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stacked/stacked.dart';

import '../../../../ui/widgets/dumb_widgets/busy_widget.dart';

class QuotationDetailView extends StatelessWidget {
  final String quotationId;
  final String customerName;
  final String status;
  const QuotationDetailView(
      {Key key, this.quotationId, this.customerName, this.status})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<QuotationDetailViewModel>.reactive(
      builder: (context, model, child) {
        return Scaffold(
            appBar: AppBar(
              title: AppBarColumnTitle(
                mainTitle: customerName ?? "",
                subTitle: quotationId,
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                      onPressed: () => model.navigateToPrint(),
                      icon: Icon(Icons.print)),
                )
              ],
            ),
            body: model.isBusy
                ? Center(
                    child: BusyWidget(),
                  )
                : Column(
                    children: [
                      //Customer details
                      Container(),
                      Expanded(
                        child: ListView.builder(
                          itemBuilder: (
                            context,
                            index,
                          ) {
                            var item = model.items[index];
                            return ListTile(
                              leading: Text(item['quantity'].toString()),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(item['itemName']),
                                  Text(item['itemPrice'].toStringAsFixed(2))
                                ],
                              ),
                              subtitle: Text(item['itemCode']),
                            );
                          },
                          itemCount: model.items.length,
                        ),
                      ),
                      status.toLowerCase() == 'closed'
                          ? Container()
                          : model.isBusy
                              ? BusyWidget()
                              : ActionButton(
                                  label: 'Generate Order From Quotation',
                                  onPressed: () => model.generateInvoice(),
                                )
                    ],
                  ));
      },
      onModelReady: (model) => model.init(),
      viewModelBuilder: () => QuotationDetailViewModel(quotationId),
    );
  }
}
