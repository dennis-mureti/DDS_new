import 'package:distributor/conf/style/lib/text_styles.dart';
import 'package:distributor/src/ui/views/pos/item_selection/pos_viewmodel.dart';
import 'package:distributor/src/ui/views/pos/pos_card_widget.dart';
import 'package:distributor/src/ui/views/pos/styles/text.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stacked/stacked.dart';

import '../../../../../ui/widgets/quantity_input/quantity_input_view.dart';

class POSView extends StatelessWidget {
  const POSView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<POSViewmodel>.reactive(
      viewModelBuilder: () => POSViewmodel(),
      onModelReady: (model) => model.init(),
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Post New Sale'),
            actions: [
              IconButton(
                onPressed: model.navigateToScannerView,
                tooltip: 'Use Barcode',
                icon: Icon(
                  // Icons.barcode_reader,
                  Icons.qr_code_scanner,
                ),
              ),
              IconButton(
                onPressed: model.itemsInCart.isEmpty
                    ? null
                    : () => model.navigateToCart(model.itemsInCart),
                // icon: Badge(
                //   child: Icon(Icons.shopping_cart),
                //   label: Text(model.itemsInCart.length.toString()),
                //   isLabelVisible: !model.itemsInCart.isEmpty,
                //   backgroundColor: model.itemsInCart.isEmpty
                //       ? Colors.transparent
                //       : Colors.red,
                // ),
              )
            ],
          ),
          body: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // IconButton(onPressed: model.search, icon: Icon(Icons.search)),
                  // IconButton(onPressed: model.sort, icon: Icon(Icons.sort)),
                  IconButton(
                    onPressed: model.toggleView,
                    icon: Icon(
                      Icons.list,
                      color: model.isToggled ? Colors.red : Colors.black,
                    ),
                  ),

                  IconButton(
                      onPressed: () async {
                        var result = showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Container(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Filter By Category",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              )),
                                          IconButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              icon: Icon(Icons.close))
                                        ],
                                      ),
                                      Center(child: Text("No categories found"))
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                      icon: Icon(Icons.more_vert)),
                ],
              ),
              model.isBusy
                  ? BusyWidget()
                  : Expanded(
                      child: model.isToggled
                          ? ListView.builder(
                              itemCount: model.items.length,
                              itemBuilder: (context, index) {
                                var item = model.items[index];
                                return Dismissible(
                                  background: Container(
                                    color: Colors.green,
                                    child: Icon(Icons.add),
                                  ),
                                  secondaryBackground: Container(
                                    color: Colors.red,
                                    child: Icon(Icons.remove_circle),
                                  ),
                                  confirmDismiss: (direction) async {
                                    if (direction ==
                                        DismissDirection.startToEnd) {
                                      //Add to the quantity
                                      var newVal = item.quantity + 1;
                                      if (newVal <=
                                          item.initialQuantity.toInt()) {
                                        model.updateQuantity(
                                            product: item, newVal: newVal);
                                      }
                                    }
                                    if (direction ==
                                        DismissDirection.endToStart) {
                                      //Reduce the quantity
                                      var newVal = item.quantity - 1;
                                      if (newVal >= 0) {
                                        model.updateQuantity(
                                            product: item, newVal: newVal);
                                      }
                                    }
                                    return false;
                                  },
                                  key: Key(item.itemCode),
                                  child: ListTile(
                                    onLongPress: () =>
                                        model.navigateToItem(item),
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
                                                'How many pcs for ${item.itemName} would you like to order ?',
                                            initialQuantity:
                                                model.getQuantity(item),
                                          );
                                        },
                                      );
                                      print(
                                          "result from quantity input : $result");
                                      if (result != null) {
                                        model.updateQuantity(
                                            product: item, newVal: result);
                                      }
                                    },
                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.itemName,
                                            style: productNameTextStyle,
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${item.itemCode}',
                                          style: kTileSubtitleTextStyle,
                                        ),
                                        Text(
                                            '${item.itemPrice.toStringAsFixed(2)}'),
                                        Text(model
                                            .getTotal(item)
                                            .toStringAsFixed(2)),
                                      ],
                                    ),
                                    trailing: Container(
                                      width: 30,
                                      child: Text(
                                          model.getQuantity(item).toString()),
                                    ),
                                  ),
                                );
                              },
                            )
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: 150,
                                        crossAxisSpacing: 10,
                                        mainAxisExtent: 170),
                                itemBuilder: (context, index) {
                                  var item = model.items[index];
                                  return GestureDetector(
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
                                                'How many pcs for ${item.itemName} would you like to order ?',
                                            initialQuantity:
                                                model.getQuantity(item),
                                          );
                                        },
                                      );
                                      print("the result from $result");
                                      if (result != null) {
                                        model.updateQuantity(
                                            product: item, newVal: result);
                                      }
                                    },
                                    child: POSCardWidget(
                                      item: item,
                                    ),
                                  );
                                },
                                itemCount: model.items.length,
                                scrollDirection: Axis.vertical,
                              ),
                            ),
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget buildDetails(BuildContext context, var item) {
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Text(
              item.name,
              style: context.textTheme.titleSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
            )),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Text(item.itemCode,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              textAlign: TextAlign.center),
        ),
      ],
    );
  }
}
