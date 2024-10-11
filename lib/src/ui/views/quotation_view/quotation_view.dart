import 'package:distributor/src/ui/views/pos/styles/text.dart';
import 'package:distributor/src/ui/views/quotation_view/quotation_viewmodel.dart';
import 'package:distributor/ui/widgets/action_button.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';
import 'package:distributor/ui/widgets/dumb_widgets/generic_container.dart';
import 'package:distributor/ui/widgets/quantity_input/quantity_input_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class QuotationView extends StatelessWidget {
  const QuotationView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<QuotationViewModel>.reactive(
      onModelReady: (model) => model.init(),
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Create Quotation'),
          ),
          body: GenericContainer(
            child: model.isBusy
                ? Center(child: BusyWidget())
                : model.items.isNotEmpty
                    ? Column(
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Customer Information'.toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  // Row(
                                  //   children: [
                                  //     // Expanded(
                                  //     //   child: RadioListTile(
                                  //     //     title: Text('Walk In'),
                                  //     //     value: 'walkin',
                                  //     //     onChanged: model.setCustomerType,
                                  //     //     groupValue: model.customerType,
                                  //     //   ),
                                  //     // ),
                                  //     Expanded(
                                  //       child: RadioListTile(
                                  //         title: Text('Contract'),
                                  //         value: 'contract',
                                  //         onChanged: model.setCustomerType,
                                  //         groupValue: model.customerType,
                                  //       ),
                                  //     )
                                  //   ],
                                  // ),
                                  _buildCustomerDisplay(
                                      CustomerTypesDisplay.contract),
                                ],
                              ),
                            ),
                          ),
                          SearchBar(),
                          Expanded(
                            child: ListView.builder(
                              itemCount: model.items.length,
                              itemBuilder: (context, index) {
                                var item = model.items[index];
                                return Dismissible(
                                  background: Container(
                                    color: Colors.green,
                                    child: Icon(
                                      Icons.add_circle,
                                      color: Colors.white,
                                    ),
                                  ),
                                  secondaryBackground: Container(
                                    color: Colors.red,
                                    child: Icon(
                                      Icons.remove_circle,
                                      color: Colors.white,
                                    ),
                                  ),
                                  confirmDismiss: (direction) async {
                                    if (direction ==
                                        DismissDirection.startToEnd) {
                                      //Add to the quantity
                                      var newVal = item.quantity + 1;
                                      model.updateQuantity(
                                          product: item, newVal: newVal);
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
                                    onTap: () async {
                                      var result = await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return QuantityInput(
                                            title: 'Enter Quantity',
                                            minQuantity: 0,
                                            maxQuantity: 200000,
                                            description:
                                                'How many pcs for ${item.itemName} would you like to order ?',
                                            initialQuantity:
                                                model.getQuantity(item),
                                          );
                                        },
                                      );

                                      if (result != null) {
                                        model.updateQuantity(
                                            product: item, newVal: result);
                                      }
                                    },
                                    // leading: Container(
                                    //   width: 30,
                                    //   height: 30,
                                    //   decoration: BoxDecoration(
                                    //       border: Border.all(width: 0.2)),
                                    // ),
                                    title: Text(
                                      item.itemName,
                                      style: productNameTextStyle,
                                    ),
                                    subtitle: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            '${item.itemPrice.toStringAsFixed(2)}'),
                                        Text(model
                                            .getTotal(item)
                                            .toStringAsFixed(2))
                                      ],
                                    ),
                                    trailing: Text(
                                        model.getQuantity(item).toString()),
                                  ),
                                );
                              },
                            ),
                          ),
                          model.isBusy
                              ? BusyWidget()
                              : ActionButton(
                                  onPressed: model.isValid
                                      ? model.navigateToConfirmQuotationView
                                      : null,
                                  label: 'Preview Quotation',
                                )
                        ],
                      )
                    : Center(
                        child: Text("There are no items available."),
                      ),
          ),
        );
      },
      viewModelBuilder: () => QuotationViewModel(),
    );
  }
}

_buildCustomerDisplay(CustomerTypesDisplay customerTypesDisplay) {
  switch (customerTypesDisplay) {
    case CustomerTypesDisplay.none:
      return Container();
    case CustomerTypesDisplay.walkin:
      return _WalkinWidget();
    case CustomerTypesDisplay.contract:
      return _CustomerWidget();
    default:
      return Container();
  }
}

class _WalkinWidget extends HookViewModelWidget<QuotationViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, QuotationViewModel model) {
    var nameController = useTextEditingController();
    var phoneController = useTextEditingController();
    return Column(
      children: [
        TextFormField(
          onChanged: model.updateCustomerName,
          controller: nameController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(label: Text('Customer Name')),
        ),
        // TextFormField(
        //   controller: phoneController,
        //   keyboardType: TextInputType.phone,
        //   decoration: InputDecoration(label: Text('Phone Number')),
        // ),
      ],
    );
  }
}

class _CustomerWidget extends HookViewModelWidget<QuotationViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, QuotationViewModel model) {
    return DropdownButton(
      onChanged: model.updateContractCustomer,
      value: model.contractCustomer,
      hint: Text('Customer Name'),
      isExpanded: true,
      items: model.customersList
          .map((e) => DropdownMenuItem(
                child: Text(e.name),
                value: e,
              ))
          .toList(),
    );
  }
}

class SearchBar extends HookViewModelWidget<QuotationViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, QuotationViewModel viewModel) {
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
