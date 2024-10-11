import 'package:distributor/conf/style/lib/colors.dart';
import 'package:distributor/conf/style/lib/text_styles.dart';
import 'package:distributor/ui/views/stock_return/stock_return_viewmodel.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';
import 'package:distributor/ui/widgets/dumb_widgets/empty_content_container.dart';
import 'package:distributor/ui/widgets/dumb_widgets/generic_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class StockReturnView extends StatelessWidget {
  const StockReturnView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<StockReturnViewModel>.reactive(
      onModelReady: (model) => model.init(),
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Return Stocks To Branch'),
          ),
          body: GenericContainer(
            child: model.isBusy
                ? Center(
                    child: BusyWidget(),
                  )
                : model.productItems.isEmpty
                    ? EmptyContentContainer(
                        label: 'You have no stock to return to the branch.',
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Confirm that these are the number of stock items that you are returning to the warehouse',
                              style: kLeadingBodyText),
                          model.reasons.isEmpty
                              ? Container()
                              : DropdownButton(
                                  hint: Text('Reason for returns'),
                                  isExpanded: true,
                                  value: model.reason,
                                  items: model.reasons
                                      .map((e) => DropdownMenuItem(
                                            child: Text(e),
                                            value: e,
                                          ))
                                      .toList(),
                                  onChanged: (e) {
                                    model.updateReason(e);
                                  }),
                          // ReasonTextView(),
                          Divider(),
                          Text('Items'),
                          Expanded(
                            child: ListView.builder(
                              itemBuilder: (BuildContext context, int index) {
                                var product = model.productItems[index];
                                return Row(
                                  children: [
                                    Expanded(
                                        child: Text(product.itemName,
                                            style: kTileLeadingTextStyle)),
                                    Text(
                                      product.quantity.toStringAsFixed(0),
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                );
                              },
                              itemCount: model.productItems.length,
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            child: model.isBusy
                                ? BusyWidget()
                                : ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                kColorDDSPrimaryLight)),
                                    onPressed: model.commit,
                                    child: Text(
                                      'SUBMIT',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                          )
                        ],
                      ),
          ),
        );
      },
      viewModelBuilder: () => StockReturnViewModel(),
    );
  }
}

class ReasonTextView extends HookViewModelWidget<StockReturnViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, viewModel) {
    var controller = useTextEditingController(text: viewModel.reason);
    return TextFormField(
      controller: controller,
      onChanged: viewModel.updateReason,
      decoration: InputDecoration(hintText: 'Reason for returning'),
    );
  }
}
