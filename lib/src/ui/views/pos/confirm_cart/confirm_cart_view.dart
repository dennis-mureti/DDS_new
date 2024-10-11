import 'package:distributor/src/ui/views/pos/confirm_cart/confirm_cart_viewmodel.dart';
import 'package:distributor/src/ui/views/pos/shared/custom_extended_button.dart';
import 'package:distributor/src/ui/views/pos/styles/text.dart';
import 'package:distributor/ui/widgets/action_button.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class ConfirmCartView extends StatelessWidget {
  final List orderedItems;
  const ConfirmCartView({Key key, @required this.orderedItems})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ConfirmCartViewModel>.reactive(
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Confirm Items'),
            actions: [
              // IconButton(
              //     onPressed: () => model.clearCart(), icon: Icon(Icons.delete))
            ],
          ),
          body: Container(
            child: Column(
              children: [
                Expanded(
                    child: ListView.builder(
                  itemBuilder: (context, index) {
                    var item = orderedItems[index];
                    return ListTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(item.quantity.toString()),
                            flex: 1,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            flex: 9,
                            child: Text(
                              item.itemName,
                              style: productNameTextStyle,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              (item.quantity * item.itemPrice)
                                  .toStringAsFixed(2),
                              style: productLinePriceTextStyle,
                              textAlign: TextAlign.right,
                            ),
                          ),
                          // IconButton(onPressed: null, icon: Icon(Icons.delete))
                        ],
                      ),
                    );
                  },
                  itemCount: orderedItems.length,
                )),
                ActionButton(
                  label: 'Proceed to Checkout',
                  onPressed: () => model.navigateToCheckOut(orderedItems),
                ),
              ],
            ),
          ),
        );
      },
      viewModelBuilder: () => ConfirmCartViewModel(),
    );
  }
}
