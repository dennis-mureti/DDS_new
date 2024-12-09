import 'package:distributor/conf/style/lib/text_styles.dart';
import 'package:distributor/src/ui/text_styles.dart';
import 'package:distributor/ui/widgets/dumb_widgets/product_quantity_container.dart';
import 'package:distributor/ui/widgets/smart_widgets/return_stock_tile/return_stock_tile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:tripletriocore/tripletriocore.dart';

class ReturnStockTileWidget extends StatelessWidget {
  final Product product;
  final Function onChange;
  const ReturnStockTileWidget({Key key, this.product, @required this.onChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ReturnStockTileViewmodel>.reactive(
        builder: (context, model, child) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                ProductQuantityContainer(
                  quantity: model.getBalance,
                  style: kListStyleItemCount,
                  secondaryStyle: kListStyleItemCount,
                ),
                SizedBox(
                  width: 1,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.itemName,
                      style: kTileLeadingTextStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Text(
                      product.itemCode,
                      style: kTileSubtitleTextStyle,
                    ),
                  ],
                ),
                Spacer(),
                Container(
                  // width: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.black12, width: 2),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: model.canRemove
                                ? () {
                                    //Update the product
                                    // onChange();
                                    model.remove();
                                    // onRemove(model.item, val: model.quantity);
                                    onChange(model.product);
                                  }
                                : null,
                            icon: Icon(Icons.remove_circle_outline),
                            visualDensity: VisualDensity.compact,
                          ),
                          GestureDetector(
                            onTap: () async {
                              var result = await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return SimpleDialog(
                                      insetPadding:
                                          EdgeInsets.symmetric(horizontal: 12),
                                      title: Text(
                                          'Return ${product.itemName} To Branch'),
                                      children: [
                                        Divider(),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                              'Number of pieces available is ${model.maxQuantity}'),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextField(
                                            onChanged: (val) {
                                              model.updateProduct(val);
                                            },
                                            decoration:
                                                InputDecoration(filled: false),
                                            onSubmitted: (val) {
                                              model.updateProduct(val);
                                            },
                                            keyboardType: TextInputType.number,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              onChange(model.product);
                                              Navigator.pop(
                                                  context, model.product);
                                            },
                                            child: Text(
                                              'Submit',
                                              style: kActiveButtonTextStyle,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  });

                              if (result is Product) {
                                model.updateProduct(
                                    result.quantity.toStringAsFixed(0));
                                onChange(result);
                                model.notifyListeners();
                              }
                            },
                            child: ProductQuantityContainer(
                                quantity: model.quantity),
                          ),
                          IconButton(
                            onPressed: model.canAdd
                                ? () {
                                    model.add();
                                    // onAdd(model.item, val: model.quantity);
                                    onChange(model.product);
                                  }
                                : null,
                            icon: Icon(Icons.add_circle_outline),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        },
        viewModelBuilder: () => ReturnStockTileViewmodel(product, onChange));
  }
}
