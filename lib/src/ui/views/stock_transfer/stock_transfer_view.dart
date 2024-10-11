import 'package:distributor/conf/style/lib/text_styles.dart';
import 'package:distributor/src/ui/views/stock_transfer/stock_transfer_viewmodel.dart';
import 'package:distributor/ui/widgets/action_button.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';
import 'package:distributor/ui/widgets/dumb_widgets/empty_content_container.dart';
import 'package:distributor/ui/widgets/quantity_input/quantity_input_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class StockTransferView extends StatelessWidget {
  const StockTransferView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<StockTransferViewmodel>.reactive(
        onModelReady: (model) => model.init(),
        disposeViewModel: true,
        builder: (context, model, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Return Stock To Warehouse',
                style: kAppBarTextStyle,
              ),
              actions: [
                // IconButton(
                //   icon: Icon(Icons.clear),
                //   onPressed: model.enableReturnToBranch ? model.reset : null,
                // )
              ],
            ),
            body: Container(
              child: model.productList == null
                  ? Center(child: BusyWidget())
                  : model.productList.isNotEmpty
                      ? Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              height: 50,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: RadioListTile(
                                      value: 'main',
                                      onChanged: model.updateStockTransferType,
                                      groupValue: model.stockTransferType,
                                      title: Text('Main Branch'),
                                    ),
                                  ),
                                  Expanded(
                                    child: RadioListTile(
                                      value: 'interoutlet',
                                      onChanged: model.updateStockTransferType,
                                      groupValue: model.stockTransferType,
                                      title: Text('Interoutlet'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            model.stockTransferType != null
                                ? model.stockTransferType.toLowerCase() ==
                                        "interoutlet"
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        child: Row(
                                          children: [
                                            Text(
                                              "Destination Outlet : ",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Expanded(
                                                child: DropdownButton(
                                              onChanged:
                                                  model.updateSelectedOutlet,
                                              isExpanded: true,
                                              value: model.selectedOutlet,
                                              items: model.outletList
                                                  .map(
                                                    (e) => DropdownMenuItem(
                                                      child: Text(e.name),
                                                      value: e,
                                                    ),
                                                  )
                                                  .toList(),
                                            ))
                                          ],
                                        ),
                                      )
                                    : Container()
                                : Container(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SearchBar(),
                            ),
                            Expanded(
                              child: ListView.separated(
                                itemBuilder: (context, index) {
                                  var item = model.productList[index];
                                  return ListTile(
                                    onTap: () async {
                                      var result = await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return QuantityInput(
                                            title: 'Enter Quantity',
                                            minQuantity: 0,
                                            maxQuantity:
                                                item.initialQuantity.toInt(),
                                            description:
                                                'How many pcs for ${item.itemName} would you like to return ?',
                                            initialQuantity:
                                                model.getQuantity(item),
                                            // model.getQuantity(item),
                                          );
                                        },
                                      );
                                      if (result != null) {
                                        model.updateQuantity(item, result);
                                        // model.editQuantityManually(item, result);
                                        // model.addToTotal(result * item.itemPrice,
                                        //     item: item);
                                        // model.updateQuantity(
                                        //     product: item, newVal: result);
                                      }
                                      // var difference = await showQuantityDialog(
                                      //     quantity: item.quantity, model: null);
                                      // if (difference is int) {
                                      //   num totalDifference =
                                      //       difference * item.itemPrice;
                                      //   //update the salesOrderViewmodel
                                      //   model.addToTotal(totalDifference,
                                      //       item: item);
                                      //   // Get the difference in terms of quantity
                                      //   num differenceInQuantity =
                                      //       totalDifference / item.itemPrice;
                                      //   if (differenceInQuantity != 0) {
                                      //     /// Check if there was an overall reduction in cart items
                                      //     /// If the difference is less than zero
                                      //     /// The number of cart items shall reduce
                                      //     if (differenceInQuantity < 0) {
                                      //       model.decreaseSalesOrderItems(item,
                                      //           (-(differenceInQuantity)).toInt());
                                      //     } else {
                                      //       model.increaseSalesOrderItems(
                                      //           item, differenceInQuantity.toInt());
                                      //     }
                                      //   }
                                      // }
                                    },
                                    // leading: Container(
                                    //   width: 30,
                                    //   height: 30,
                                    //   decoration: BoxDecoration(
                                    //       border: Border.all(width: 0.2)),
                                    // ),
                                    title: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${item.itemName}',
                                          style: kTileLeadingTextStyle,
//                    overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(
                                          height: 2,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              '${item.itemCode}',
                                              style: kTileSubtitleTextStyle,
//                    overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    // subtitle: Row(
                                    //   mainAxisAlignment:
                                    //   MainAxisAlignment.spaceBetween,
                                    //   children: [
                                    //     Text(
                                    //         '${item.itemPrice.toStringAsFixed(2)}'),
                                    //     Text(model
                                    //         .getTotal(item)
                                    //         .toStringAsFixed(2))
                                    //   ],
                                    // ),
                                    trailing: Text(
                                        model.getQuantity(item).toString()),
                                  );
                                  // Product product = model.productList[index];
                                  // return ReturnStockTileWidget(
                                  //   product: product,
                                  //   onChange: model.onChange,
                                  // );
                                },
                                itemCount: model.productList.length,
                                separatorBuilder: (context, index) {
                                  return Divider(
                                    height: 5,
                                  );
                                },
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              child: model.isBusy
                                  ? Center(child: BusyWidget())
                                  : ActionButton(
                                      label: 'Return Stock',
                                      onPressed: model.returnableItems.isEmpty
                                          ? null
                                          : model.transferStock,
                                    ),
                            )
                          ],
                        )
                      : Center(
                          child: EmptyContentContainer(
                            label:
                                'You currently have no stock to return to the branch.',
                          ),
                        ),
            ),
          );
        },
        viewModelBuilder: () => StockTransferViewmodel());
  }
}

class SearchBar extends HookViewModelWidget<StockTransferViewmodel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, StockTransferViewmodel viewModel) {
    var searchString =
        useTextEditingController(text: viewModel.skuSearchString);
    return TextFormField(
      controller: searchString,
      keyboardType: TextInputType.text,
      // textInputAction: TextInputAction.en,
      onChanged: viewModel.updateSearchString,
      // onTap: () => viewModel.toggleShowSummary(false),
      // onFieldSubmitted: (val) => viewModel.onFieldSubmitted(val),
      onEditingComplete: () {
        //Happens when the user presses the action
        // viewModel.onEditComplete();
        //Close the keyboard
      },
      decoration: InputDecoration(
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(1.0),
          ),
          filled: true,
          fillColor: Colors.grey[200],
          hintText: 'Search',
          prefixIcon: Icon(Icons.search),
          // hintText: 'Search for an SKU',
          suffixIcon: IconButton(
              onPressed: () {
                searchString.text = '';
                viewModel.resetSearch();
              },
              icon: Icon(Icons.cancel_outlined))),
    );
  }
}
