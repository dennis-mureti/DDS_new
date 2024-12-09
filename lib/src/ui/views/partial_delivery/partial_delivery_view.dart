import 'package:distributor/conf/style/lib/text_styles.dart';
import 'package:distributor/src/ui/views/partial_delivery/manage_sales_returns_view.dart';
import 'package:distributor/src/ui/views/partial_delivery/partial_delivery_viewmodel.dart';
import 'package:distributor/ui/widgets/dumb_widgets/app_bar_column_title.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:tripletriocore/tripletriocore.dart';

class PartialDeliveryView extends StatefulWidget {
  final SalesOrder salesOrder;
  final DeliveryJourney deliveryJourney;
  final DeliveryNote deliveryNote;
  final DeliveryStop deliveryStop;

  const PartialDeliveryView(
      {Key key,
      this.salesOrder,
      this.deliveryJourney,
      @required this.deliveryNote,
      @required this.deliveryStop})
      : super(key: key);

  @override
  State<PartialDeliveryView> createState() => _PartialDeliveryViewState();
}

class _PartialDeliveryViewState extends State<PartialDeliveryView> {
  @override
  Widget build(BuildContext context) {
    print(widget.deliveryStop.isTechnicalStop.toString());
    return ViewModelBuilder<PartialDeliveryViewModel>.reactive(
        onModelReady: (model) => model.init(),
        builder: (context, model, child) {
          return Scaffold(
            appBar: AppBar(
              title: AppBarColumnTitle(
                mainTitle: 'Sales Returns',
                subTitle: model.deliveryStop.deliveryNoteId,
              ),
            ),
            body: Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              child: model.userLocation == null
                  ? Center(child: BusyWidget())
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                              'Confirm that these are the number of stock items that you are returning to the warehouse',
                              style: kLeadingBodyText),
                        ),
                        // model.reasons.isEmpty
                        //     ? Container()
                        //     : DropdownButton(
                        //         hint: Text('Reason for returns'),
                        //         isExpanded: true,
                        //         value: model.reason,
                        //         items: model.reasons
                        //             .map((e) => DropdownMenuItem(
                        //                   child: Text(e),
                        //                   value: e,
                        //                 ))
                        //             .toList(),
                        //         onChanged: (e) {
                        //           model.updateReason(e);
                        //         }),
                        // ReasonTextView(),
                        Divider(),
                        Text('Items'),
                        //Fetch SKUS
                        Expanded(
                          child: ListView.builder(
                            itemBuilder: (context, index) {
                              var salesOrderRequestItem =
                                  model.deliveryNote.deliveryItems[index];
                              return Column(
                                children: [
                                  Container(
                                    // margin: EdgeInsets.symmetric(vertical: 4),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Row(
                                        children: [
                                          // Column(
                                          //   mainAxisAlignment:
                                          //       MainAxisAlignment.center,
                                          //   crossAxisAlignment:
                                          //       CrossAxisAlignment.center,
                                          //   children: [
                                          //     Text(
                                          //       salesOrderRequestItem['quantity']
                                          //           .toStringAsFixed(0),
                                          //       style: TextStyle(
                                          //           fontSize: 18,
                                          //           fontWeight: FontWeight.w600),
                                          //     ),
                                          //   ],
                                          // ),
                                          // SizedBox(
                                          //   width: 5,
                                          // ),
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
                                                              FontWeight.bold),
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
                                      ? Text(
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
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text('x'),
                                                SizedBox(
                                                  width: 5,
                                                ),
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
                                          physics: ClampingScrollPhysics(),
                                        ),
                                ],

                                //@TODO List of reasons
                                // subtitle: Text(
                                //     'Reason : ${model.getReasonForItem(index)}'),
                              );
                            },
                            itemCount: model.deliveryStop.deliveryItems.length,
                          ),
                        ),
                        Container(
                          height: 50,
                          child: model.isBusy
                              ? Center(
                                  child: BusyWidget(),
                                )
                              : ElevatedButton(
                                  child: Text(
                                    'Make Sales Returns',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  onPressed: () {
                                    model.makeSalesReturns();
                                  },
                                ),
                        )
                      ],
                    ),
            ),
          );
        },
        viewModelBuilder: () => PartialDeliveryViewModel(widget.salesOrder,
            widget.deliveryJourney, widget.deliveryNote, widget.deliveryStop));
  }
}

class _ReasonIconButton extends HookViewModelWidget<PartialDeliveryViewModel> {
  final int index;
  final List reasons;
  final salesOrderRequestItem;
  _ReasonIconButton(this.index, this.reasons, this.salesOrderRequestItem);
  @override
  Widget buildViewModelWidget(
      BuildContext context, PartialDeliveryViewModel model) {
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

// class _ReasonForReturnCheckBox
//     extends HookViewModelWidget<PartialDeliveryViewModel> {
//   final salesOrderRequestItem;
//   final int index;
//   final String reason;
//
//   _ReasonForReturnCheckBox(this.salesOrderRequestItem, this.index, this.reason);
//
//   @override
//   Widget buildViewModelWidget(
//       BuildContext context, PartialDeliveryViewModel model) {
//     return CheckboxListTile(
//         title: Text(reason),
//         controlAffinity: ListTileControlAffinity.leading,
//         value: false,
//         onChanged: (_) => model.updateSalesOrderRequestReason(index, reason));
//   }
// }

class UnitsDeliveredTextForm
    extends HookViewModelWidget<PartialDeliveryViewModel> {
  final salesOrderRequestItem;
  final int index;

  UnitsDeliveredTextForm(this.salesOrderRequestItem, this.index);
  @override
  Widget buildViewModelWidget(
      BuildContext context, PartialDeliveryViewModel model) {
    return TextFormField(
      initialValue: salesOrderRequestItem['quantity'].toString(),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        if (value.isNotEmpty) {
          if (int.parse(value) <= salesOrderRequestItem['quantity']) {
            model.updateSalesOrderRequestItem(index, value);
          }
        }
      },
    );
  }
}
