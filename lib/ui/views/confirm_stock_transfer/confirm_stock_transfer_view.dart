import 'package:distributor/conf/style/lib/text_styles.dart';
import 'package:distributor/ui/views/confirm_stock_transfer/confirm_stock_transfer_viewmodel.dart';
import 'package:distributor/ui/widgets/action_button.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';
import 'package:distributor/ui/widgets/dumb_widgets/empty_content_container.dart';
import 'package:distributor/ui/widgets/dumb_widgets/product_quantity_container.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:tripletriocore/tripletriocore.dart';

class ConfirmStockTransferView extends StatelessWidget {
  final List<Product> stockTransferItems;
  const ConfirmStockTransferView({Key key, this.stockTransferItems})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ConfirmStockTransferViewModel>.reactive(
        builder: (context, model, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Confirm Stock Transfer Items'),
            ),
            body: stockTransferItems.isEmpty
                ? Center(
                    child: EmptyContentContainer(
                        label: 'You have not selected any items.'),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            var stockTransferItem =
                                model.stockTransferItems[index];
                            return ListTile(
                              trailing: ProductQuantityContainer(
                                  quantity: stockTransferItem.quantity),
                              title: Text(
                                stockTransferItem.itemName,
                                style: kTileLeadingTextStyle,
                              ),
                              subtitle: Text(
                                '${stockTransferItem.itemCode}',
                                style: kTileSubtitleTextStyle,
                              ),
                            );
                          },
                          itemCount: model.stockTransferItems.length,
                        ),
                      ),
                      model.isBusy
                          ? BusyWidget()
                          : ActionButton(
                              label: 'Submit',
                              onPressed: model.commit,
                            ),
                    ],
                  ),
          );
        },
        viewModelBuilder: () =>
            ConfirmStockTransferViewModel(stockTransferItems));
  }
}
