import 'package:distributor/conf/style/lib/text_styles.dart';
import 'package:distributor/ui/widgets/dumb_widgets/product_quantity_container.dart';
import 'package:flutter/material.dart';
import 'package:tripletriocore/tripletriocore.dart';

class ProductQuantityTile extends StatelessWidget {
  final Product product;
  const ProductQuantityTile({Key key, @required this.product})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.symmetric(horizontal: 10),
      child: ListTile(
        dense: true,
        // visualDensity: VisualDensity.compact,
        title: Text(
          product.itemName ?? "",
          style: kTileLeadingTextStyle,
        ),
        subtitle: Row(
          children: [
            product.isSynced
                ? Container(
                    width: 0,
                  )
                : Icon(
                    Icons.timer_sharp,
                    size: 12,
                  ),
            Text(
              product.itemCode.toString() ?? "",
              style: kTileSubtitleTextStyle,
            ),
          ],
        ),
        trailing: ProductQuantityContainer(
          quantity: product.quantity.toInt(),
        ),
      ),
    );
  }
}
