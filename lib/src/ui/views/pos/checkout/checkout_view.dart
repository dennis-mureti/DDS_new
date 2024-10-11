import 'package:distributor/src/ui/views/pos/checkout/checkout_viewmodel.dart';
import 'package:distributor/src/ui/views/pos/shared/custom_extended_button.dart';
import 'package:distributor/ui/widgets/action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

import '../../../../../ui/widgets/dumb_widgets/busy_widget.dart';

class CheckoutView extends StatelessWidget {
  final cartItems;
  const CheckoutView({Key key, this.cartItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CheckOutViewModel>.reactive(
        onModelReady: (model) => model.init(),
        builder: (context, model, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Checkout'),
            ),
            body: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(color: Colors.blueGrey),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    child: Row(
                      children: [
                        Text(
                          'Cart Total',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Kshs ${model.total}',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  Expanded(
                    child: ListView(
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
                                Row(
                                  children: [
                                    Expanded(
                                      child: RadioListTile(
                                        title: Text('Walk In'),
                                        value: 'walkin',
                                        onChanged: model.setCustomerType,
                                        groupValue: model.customerType,
                                      ),
                                    ),
                                    Expanded(
                                      child: RadioListTile(
                                        title: Text('Contract'),
                                        value: 'contract',
                                        onChanged: model.setCustomerType,
                                        groupValue: model.customerType,
                                      ),
                                    )
                                  ],
                                ),
                                _buildCustomerDisplay(
                                    model.customerTypesDisplay),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Payment Info'.toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  // crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: [
                                        Radio(
                                          value: 'cash',
                                          onChanged: model.setPaymentMode,
                                          groupValue: model.paymentMode,
                                        ),
                                        Text('Cash'),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Radio(
                                          value: 'mpesa',
                                          onChanged: model.setPaymentMode,
                                          groupValue: model.paymentMode,
                                        ),
                                        Text('mPesa'),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Radio(
                                          value: 'multipay',
                                          onChanged: model.setPaymentMode,
                                          groupValue: model.paymentMode,
                                        ),
                                        Text('Multipay'),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Radio(
                                          value: 'cheque',
                                          onChanged: model.setPaymentMode,
                                          groupValue: model.paymentMode,
                                        ),
                                        Text('Cheque'),
                                      ],
                                    ),
                                  ],
                                ),
                                _buildPaymentDisplay(model.paymentModeDisplay),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  model.isBusy
                      ? Center(child: BusyWidget())
                      : ActionButton(
                          label: 'Complete',
                          onPressed:
                              model.isValid ? () => model.postSale() : null,
                        ),
                ],
              ),
            ),
          );
        },
        viewModelBuilder: () => CheckOutViewModel(cartItems));
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

  _buildPaymentDisplay(PaymentModeDisplay paymentModeDisplay) {
    switch (paymentModeDisplay) {
      case PaymentModeDisplay.none:
        return Container();
      case PaymentModeDisplay.cash:
        return _CashConfirmationWidget();
      case PaymentModeDisplay.mixed:
        return _MixedPaymentWidget();
      case PaymentModeDisplay.mobile:
        return _MpesaConfirmationWidget();
      case PaymentModeDisplay.cheque:
        return _ChequeConfirmationWidget();
      default:
        return Container();
    }
  }
}

class _WalkinWidget extends HookViewModelWidget<CheckOutViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CheckOutViewModel model) {
    var nameController = useTextEditingController();
    var phoneController = useTextEditingController();
    return Column(
      children: [
        TextFormField(
          controller: nameController,
          onChanged: model.setCustomerName,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(1.0),
              ),
              filled: true,
              fillColor: Colors.grey[200],
              label: Text('Customer Name'),
              hintText: 'Enter the customer name'),
        ),
      ],
    );
  }
}

class _CustomerWidget extends HookViewModelWidget<CheckOutViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CheckOutViewModel model) {
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

class _MpesaConfirmationWidget extends HookViewModelWidget<CheckOutViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CheckOutViewModel model) {
    var telephone = useTextEditingController();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextFormField(
            keyboardType: TextInputType.phone,
            onChanged: model.setPhoneNumber,
            decoration: InputDecoration(
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(1.0),
              ),
              filled: true,
              fillColor: Colors.grey[200],
              label: Text(
                'Telephone number',
              ),
              suffixIcon: Icon(Icons.arrow_right_alt_sharp),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChequeConfirmationWidget extends HookViewModelWidget<CheckOutViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CheckOutViewModel model) {
    var drawerName = useTextEditingController();
    var chequeNumber = useTextEditingController();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextFormField(
            controller: drawerName,
            keyboardType: TextInputType.name,
            onChanged: model.setDrawerName,
            decoration: InputDecoration(
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(1.0),
              ),
              filled: true,
              fillColor: Colors.grey[200],
              label: Text(
                'Enter Drawer Name',
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          TextFormField(
            controller: chequeNumber,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(1.0),
              ),
              filled: true,
              fillColor: Colors.grey[200],
              label: Text(
                'Enter Cheque Number',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CashConfirmationWidget extends HookViewModelWidget<CheckOutViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CheckOutViewModel model) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Receive Ksh ${model.total.toStringAsFixed(2)} cash from customer.',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _MixedPaymentWidget extends HookViewModelWidget<CheckOutViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CheckOutViewModel model) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            keyboardType: TextInputType.number,
            onChanged: model.setCashAmount,
            decoration: InputDecoration(
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(1.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
                label: Text(
                  'Enter Cash Amount',
                ),
                hintText: 'Enter Cash Amount to receive from customer'),
          ),
          SizedBox(
            height: 5,
          ),
          model.cashAmount == 0
              ? Container()
              : Text("Amount to be deducted from mPesa is ${model.difference}"),
          SizedBox(
            height: 5,
          ),
          TextFormField(
            keyboardType: TextInputType.phone,
            onChanged: model.setPhoneNumber,
            decoration: InputDecoration(
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(1.0),
              ),
              filled: true,
              fillColor: Colors.grey[200],
              label: Text(
                'Enter customer number',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
