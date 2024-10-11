import 'package:distributor/conf/style/lib/text_styles.dart';
import 'package:distributor/core/helper.dart';
import 'package:distributor/src/ui/views/pos_item_confirmation/pos_item_confirmationviewmodel.dart';
import 'package:distributor/ui/widgets/action_button.dart';
import 'package:distributor/ui/widgets/dumb_widgets/empty_content_container.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class POSItemConfirmationView extends StatelessWidget {
  final List items;
  final num total;
  const POSItemConfirmationView({Key key, this.items, this.total})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<POSItemConfirmationViewModel>.reactive(
      viewModelBuilder: () => POSItemConfirmationViewModel(),
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Confirm Items'),
          ),
          body: model.items.isNotEmpty
              ? Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          var item = model.items[index];
                          num totalPrice = item.itemPrice * item.quantity;
                          return ListTile(
                            leading: Text(item.quantity.toString()),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                model.deleteItem(item);
                              },
                            ),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.itemName,
                                        style: kTileLeadingTextStyle,
                                      ),
                                    ),
                                    Text(
                                      Helper.formatCurrency(totalPrice),
                                      style: kTileLeadingTextStyle,
                                    ),
                                  ],
                                ),
                                Text(
                                  item.itemCode,
                                  style: kTileSubtitleTextStyle,
                                ),
                              ],
                            ),
                          );
                        },
                        itemCount: items.length,
                      ),
                    ),
                    ActionButton(
                      label: 'Proceed to Payment',
                      onPressed: model.items.isNotEmpty
                          ? () => model.navigateToAddPayment()
                          : null,
                    )
                  ],
                )
              : const Center(
                  child: EmptyContentContainer(
                      label: 'You have not added any items to the cart')),
        );
      },
    );
  }
}
