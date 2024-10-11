import 'package:distributor/conf/style/lib/text_styles.dart';
import 'package:distributor/src/ui/views/partial_delivery/manage_sales_returns_view.dart';
import 'package:distributor/src/ui/views/pos/sales_returns/sales_returns_viewmodel.dart';
import 'package:distributor/ui/widgets/action_button.dart';
import 'package:distributor/ui/widgets/dumb_widgets/app_bar_column_title.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class SalesReturnsView extends StatelessWidget {
  final invoice;
  const SalesReturnsView({Key key, this.invoice}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SalesReturnsViewModel>.reactive(
        onModelReady: (model) => model.init(),
        builder: (context, model, child) {
          return Scaffold(
              appBar: AppBar(
                title: AppBarColumnTitle(
                  mainTitle: 'Sales Returns',
                  subTitle: invoice['deliveryNoteId'],
                ),
              ),
              body: model.isBusy
                  ? Center(child: BusyWidget())
                  : Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 10),
                            child: Text(
                                'Confirm that these are the number of stock items that you are returning to the outlet',
                                style: kLeadingBodyText),
                          ),
                          Divider(),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              'Items',
                              textAlign: TextAlign.right,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemBuilder: (context, index) {
                                var salesOrderRequestItem =
                                    model.invoice['deliveryItems'][index];
                                return Column(
                                  children: [
                                    Container(
                                      // margin: EdgeInsets.symmetric(vertical: 4),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 4,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        salesOrderRequestItem[
                                                            'itemName'],
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ],
                                                  ),
                                                  // Row(
                                                  //   children: [
                                                  //     Text(
                                                  //       'Delivered ${salesOrderRequestItem.quantityDelivered.toStringAsFixed(0)}',
                                                  //     ),
                                                  //     SizedBox(
                                                  //       width: 4,
                                                  //     ),
                                                  //     // Text(
                                                  //     //   '${salesOrderRequestItem.lineAmount.toStringAsFixed(2)}',
                                                  //     // ),
                                                  //   ],
                                                  // ),
                                                ],
                                              ),
                                            ),

                                            // Expanded(
                                            //     child: UnitsDeliveredTextForm(
                                            //         salesOrderRequestItem, index)),
                                            _ReasonIconButton(
                                                index,
                                                model.reasons,
                                                salesOrderRequestItem)
                                            // IconButton(
                                            //   onPressed: () async {
                                            //     await showModalBottomSheet(
                                            //       context: (context),
                                            //       builder: (context) => Container(
                                            //         color: Colors.white,
                                            //         child: Column(
                                            //           crossAxisAlignment:
                                            //               CrossAxisAlignment.start,
                                            //           mainAxisSize:
                                            //               MainAxisSize.max,
                                            //           children: [
                                            //             Row(
                                            //               mainAxisAlignment:
                                            //                   MainAxisAlignment
                                            //                       .spaceBetween,
                                            //               children: [
                                            //                 Padding(
                                            //                   padding:
                                            //                       const EdgeInsets
                                            //                           .all(8.0),
                                            //                   child: Text(
                                            //                     'Reason for Return',
                                            //                     style: TextStyle(
                                            //                         fontSize: 16,
                                            //                         fontWeight:
                                            //                             FontWeight
                                            //                                 .w800),
                                            //                   ),
                                            //                 ),
                                            //                 IconButton(
                                            //                   icon:
                                            //                       Icon(Icons.close),
                                            //                   onPressed: () {
                                            //                     Navigator.pop(
                                            //                         context);
                                            //                   },
                                            //                 ),
                                            //               ],
                                            //             ),
                                            //             ...model.reasons
                                            //                 .map(
                                            //                   (reason) =>
                                            //                       CheckboxListTile(
                                            //                     title: Text(reason),
                                            //                     controlAffinity:
                                            //                         ListTileControlAffinity
                                            //                             .leading,
                                            //                     value: model
                                            //                         .checkReasonStatus(
                                            //                             index,
                                            //                             reason),
                                            //                     onChanged: (_) {
                                            //                       model
                                            //                           .updateSalesOrderRequestReason(
                                            //                               index,
                                            //                               reason);
                                            //
                                            //                       //Show snackbar
                                            //                     },
                                            //                   ),
                                            //                 )
                                            //                 .toList(),
                                            //           ],
                                            //         ),
                                            //       ),
                                            //     );
                                            //   },
                                            //   icon: Icon(
                                            //     Icons.more_vert,
                                            //     size: 30,
                                            //     // color: Colors.white,
                                            //   ),
                                            //   visualDensity: VisualDensity.compact,
                                            // ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    model
                                                .fetchReasonsBySKU(
                                                    salesOrderRequestItem[
                                                        'itemCode'])
                                                .length ==
                                            0
                                        ? const Text(
                                            'You have not added any stock returns for this SKU',
                                            textAlign: TextAlign.start,
                                          )
                                        : ListView.builder(
                                            itemBuilder: (context, index) {
                                              var result =
                                                  model.fetchReasonsBySKU(
                                                      salesOrderRequestItem[
                                                          'itemCode']);
                                              var salesReturn = result[index];
                                              return Row(
                                                children: [
                                                  Text(salesReturn['quantity']
                                                      .toString()),
                                                  const SizedBox(width: 5),
                                                  const Text('x'),
                                                  const SizedBox(width: 5),
                                                  Text(salesReturn['reason']),
                                                ],
                                              );
                                            },
                                            itemCount: model
                                                .fetchReasonsBySKU(
                                                    salesOrderRequestItem[
                                                        'itemCode'])
                                                .length,
                                            shrinkWrap: true,
                                            physics:
                                                const ClampingScrollPhysics(),
                                          ),
                                  ],

                                  //@TODO List of reasons
                                  // subtitle: Text(
                                  //     'Reason : ${model.getReasonForItem(index)}'),
                                );
                              },
                              itemCount: model.invoice['deliveryItems'].length,
                            ),
                          ),
                          Container(
                              // height: 30,
                              child: model.isBusy
                                  ? const Center(
                                      child: BusyWidget(),
                                    )
                                  : ActionButton(
                                      label: 'Make Sales Return',
                                      onPressed: model.makeSalesReturns,
                                    ))
                        ],
                      ),
                    ));
        },
        viewModelBuilder: () => SalesReturnsViewModel(invoice));
  }
}

class _ReasonIconButton extends HookViewModelWidget<SalesReturnsViewModel> {
  final int index;
  final List reasons;
  final salesOrderRequestItem;
  _ReasonIconButton(this.index, this.reasons, this.salesOrderRequestItem);
  @override
  Widget buildViewModelWidget(
      BuildContext context, SalesReturnsViewModel model) {
    return IconButton(
      onPressed: () async {
        var result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ManageSalesReturnsView(
                    reasons: reasons,
                    salesOrderRequestItem: salesOrderRequestItem,
                    index: index,
                  )),
        );
        if (result is List) {
          model.updateSalesReturnUnits(
              result, salesOrderRequestItem['itemCode']);
        }
        // await showModalBottomSheet(
        //   // isScrollControlled: true,
        //   context: (context),
        //   builder: (context) => StatefulBuilder(
        //       builder: (context, setState) => Container(
        //             color: Colors.white,
        //             child: Column(
        //               crossAxisAlignment: CrossAxisAlignment.start,
        //               mainAxisSize: MainAxisSize.max,
        //               children: [
        //                 Row(
        //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                   children: [
        //                     Padding(
        //                       padding: const EdgeInsets.all(8.0),
        //                       child: Text(
        //                         'Reason for Return',
        //                         style: TextStyle(
        //                             fontSize: 16, fontWeight: FontWeight.w800),
        //                       ),
        //                     ),
        //                     IconButton(
        //                       icon: Icon(Icons.close),
        //                       onPressed: () {
        //                         Navigator.pop(context);
        //                       },
        //                     ),
        //                   ],
        //                 ),
        //                 ...model.reasons
        //                     .map(
        //                       (reason) => CheckboxListTile(
        //                         // groupValue: model.getCurrentValue(index, reason),
        //                         title: Row(
        //                           children: [
        //                             Expanded(child: Text(reason)),
        //                             Container(
        //                               child: TextFormField(
        //                                   // initialValue: '0',
        //                                   //@TODO Check if the corresponding checkbox is enabled
        //                                   // enabled: false,
        //                                   onChanged: (value) {
        //                                     model.updateSalesOrderRequestReason(
        //                                         index, value, reason);
        //                                   },
        //                                   keyboardType: TextInputType.number),
        //                               width: 50,
        //                             ),
        //                           ],
        //                         ),
        //
        //                         controlAffinity:
        //                             ListTileControlAffinity.leading,
        //                         value: model.checkReasonStatus(index, reason),
        //                         onChanged: (_) {
        //                           setState(() {
        //                             // Add / Remove the reason
        //
        //                             // Enable / Disable textform field
        //
        //                             // If disabled reset value to zero
        //                             // _checked = value;
        //                           });
        //                           //If enabled display a text editing
        //
        //                           //model.updateSalesOrderRequestReason(index, reason);
        //
        //                           //Show snackbar
        //                         },
        //                       ),
        //                     )
        //                     .toList(),
        //                 ElevatedButton(
        //                   onPressed: null,
        //                   child: Text('Submit'),
        //                 )
        //               ],
        //             ),
        //           )),
        // );
      },
      icon: Icon(
        Icons.add_circle_outline,
        size: 30,
        // color: Colors.white,
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}
