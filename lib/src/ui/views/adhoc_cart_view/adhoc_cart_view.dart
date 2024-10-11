import 'package:distributor/conf/style/lib/text_styles.dart';
import 'package:distributor/ui/views/orders/create_order/sales_order_view_model.dart';
import 'package:distributor/ui/widgets/action_button.dart';
import 'package:distributor/ui/widgets/dumb_widgets/app_bar_column_title.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';
import 'package:distributor/ui/widgets/dumb_widgets/empty_content_container.dart';
import 'package:distributor/ui/widgets/quantity_input/quantity_input_view.dart';
import 'package:distributor/ui/widgets/smart_widgets/sales_order_item/sales_order_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:tripletriocore/tripletriocore.dart';

class AdhocCartView extends StatelessWidget {
  final Customer customer;
  final bool isWalkin;

  const AdhocCartView({Key key, this.customer, this.isWalkin})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SalesOrderViewModel>.reactive(
      builder: (context, model, child) => WillPopScope(
        onWillPop: () async {
          model.onWillPopScope();
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            // leading: IconButton(
            //   icon: Icon(FontAwesomeIcons.chevronLeft),
            //   onPressed: () async {
            //     Navigator.pop(context, false);
            //   },
            // ),
            title: AppBarColumnTitle(
              mainTitle: 'Cart',
              subTitle: isWalkin ? model.customerName : customer.name,
            ),
          ),
          body: model.isBusy
              ? Center(
                  child: BusyWidget(),
                )
              : model.productList.isEmpty
                  ? Center(
                      child: EmptyContentContainer(label: 'No SKUs found'),
                    )
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SearchBar(),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: model.productList.length,
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
                                            'How many pcs for ${item.itemName} would you like to order ?',
                                        initialQuantity:
                                            model.getQuantity(item),
                                      );
                                    },
                                  );

                                  if (result != null) {
                                    model.editQuantityManually(item, result);
                                    model.addToTotal(result * item.itemPrice,
                                        item: item);
                                    model.updateQuantity(
                                        product: item, newVal: result);
                                    model.updateAdhocCartService(item, result);
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                subtitle: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        '${item.itemPrice.toStringAsFixed(2)}'),
                                    Text(
                                        model.getTotal(item).toStringAsFixed(2))
                                  ],
                                ),
                                trailing:
                                    Text(model.getQuantity(item).toString()),
                              );
                            },
                          ),
                        ),
                        ActionButton(
                          label: 'Continue to Confirmation',
                          onPressed: model.hasItems
                              // ? () => model.navigateToAdhocPaymentView()n
                              ? () =>
                                  model.navigateToPOSConfirmationPaymentView()
                              : null,
                        )
                      ],
                    ),
        ),
      ),
      viewModelBuilder: () =>
          SalesOrderViewModel(customer: customer, isWalkIn: isWalkin),
      onModelReady: (model) => model.initializeAdhoc(),
    );
  }
}

class _ResultsView extends HookViewModelWidget<SalesOrderViewModel> {
  _ResultsView();
  @override
  Widget buildViewModelWidget(BuildContext context, SalesOrderViewModel model) {
    return ListView.builder(
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        itemCount: model.productList.length,
        itemBuilder: (context, index) {
          Product product = model.productList[index];
          //Check if the user has this item in stock
          if (model.checkIfStockExists(product)) {
            return SalesOrderItemWidget(
              item: product,
              salesOrderViewModel: model,
              // quantity: model.getAdhocQuantity(product),
            );
          } else {
            return Container(height: 0);
          }
        });
  }
}

class SearchBar extends HookViewModelWidget<SalesOrderViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, SalesOrderViewModel viewModel) {
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
