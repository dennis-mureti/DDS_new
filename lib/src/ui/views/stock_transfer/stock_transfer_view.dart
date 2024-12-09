import 'package:distributor/conf/style/lib/text_styles.dart';
import 'package:distributor/src/ui/views/stock_transfer/stock_transfer_viewmodel.dart';
import 'package:distributor/ui/widgets/action_button.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';
import 'package:distributor/ui/widgets/dumb_widgets/empty_content_container.dart';
import 'package:distributor/ui/widgets/smart_widgets/return_stock_tile/return_stock_tile_widget.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:tripletriocore/tripletriocore.dart';

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
                'Return Stock To Branch',
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
                            Expanded(
                              child: ListView.separated(
                                itemBuilder: (context, index) {
                                  Product product = model.productList[index];
                                  return ReturnStockTileWidget(
                                    product: product,
                                    onChange: model.onChange,
                                  );
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
                                        label: 'Return To Branch',
                                        onPressed: model.transferStock,
                                      ))
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
