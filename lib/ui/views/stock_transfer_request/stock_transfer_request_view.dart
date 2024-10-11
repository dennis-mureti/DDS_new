import 'package:distributor/conf/style/lib/text_styles.dart';
import 'package:distributor/ui/views/stock_transfer_request/stock_transfer_request_viewmodel.dart';
import 'package:distributor/ui/widgets/action_button.dart';
import 'package:distributor/ui/widgets/dumb_widgets/empty_content_container.dart';
import 'package:distributor/ui/widgets/quantity_input/quantity_input_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

import '../../widgets/dumb_widgets/busy_widget.dart';

class StockTransferRequestView extends StatelessWidget {
  const StockTransferRequestView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<StockTransferRequestViewModel>.reactive(
      onModelReady: (model) => model.init(),
      viewModelBuilder: () => StockTransferRequestViewModel(),
      builder: (context, model, child) {
        return Scaffold(
            appBar: AppBar(
              title: Text(
                'Stock Transfer Request',
                style: kAppBarTextStyle,
              ),
            ),
            body: model.isBusy
                ? Center(child: BusyWidget())
                : Column(
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
                                        "Source Outlet : ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Expanded(
                                          child: DropdownButton(
                                        onChanged: model.updateSelectedOutlet,
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
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SearchBar(),
                      ),
                      model.productList.isNotEmpty
                          ? Expanded(
                              child: ListView.separated(
                                itemBuilder: (context, index) {
                                  var product = model.productList[index];
                                  return ListTile(
                                    visualDensity: VisualDensity.compact,
                                    isThreeLine: false,
                                    subtitle: Text(
                                      '${product.itemCode}',
                                      style: kTileSubtitleTextStyle,
                                    ),
                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${product.itemName}',
                                            style: kTileLeadingTextStyle,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            model.removeQuantity(product);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Icon(
                                                Icons.remove_circle_outline),
                                          ),
                                        ),
                                        GestureDetector(
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.grey
                                                    .withOpacity(0.1),
                                                border: Border.all(
                                                  color: Colors.grey
                                                      .withOpacity(0.1),
                                                )),
                                            width: 60,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                model
                                                    .getQuantity(product)
                                                    .toString(),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                          onTap: () async {
                                            var result = await showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return QuantityInput(
                                                    title:
                                                        'Quantity to Request',
                                                    description:
                                                        '${product.itemName}',
                                                    initialQuantity: model
                                                        .getQuantity(product),
                                                    minQuantity: 0,
                                                    maxQuantity: 100000,
                                                  );
                                                });
                                            if (result != null) {
                                              model.updateQuantity(
                                                  product: product,
                                                  newVal: result);
                                            }
                                          },
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            model.addQuantity(product);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:
                                                Icon(Icons.add_circle_outline),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                itemCount: model.productList.length,
                                separatorBuilder: (context, index) {
                                  return Divider(
                                    height: 1,
                                  );
                                },
                              ),
                            )
                          : model.stockTransferType == null ?
                              Center(child: EmptyContentContainer(label: 'Select an outlet type'),)
                          : Center(child: EmptyContentContainer(
                                  label: 'No SKUs found for the outlet.')),
                      ActionButton(
                        label: 'Continue',
                        onPressed: model.stockTransferItems.isNotEmpty
                            ? model.commit
                            : null,
                      ),
                    ],
                  ));
      },
    );
  }
}

class SearchBar extends HookViewModelWidget<StockTransferRequestViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, StockTransferRequestViewModel viewModel) {
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
