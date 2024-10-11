import 'package:distributor/core/helper.dart';
import 'package:distributor/src/ui/views/pos/payment_view/payment_viewmodel.dart';
import 'package:distributor/ui/widgets/action_button.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';
import 'package:distributor/ui/widgets/dumb_widgets/generic_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class PaymentView extends StatelessWidget {
  final List items;
  final double total;
  final String ref;
  final String docType;
  PaymentView(
      {Key key, this.items, this.total = 0, this.ref, this.docType = ""})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PaymentViewModel>.reactive(
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Payment'),
          ),
          body: GenericContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 120,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('Total : '),
                              Text(
                                  'Kshs ${Helper.formatCurrency(model.total)}'),
                            ],
                          ),
                          Row(
                            children: [
                              Text('Number of items : ${model.items.length}'),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                const Text('Payment mode : '),
                                Expanded(
                                  child: DropdownButton(
                                    isExpanded: true,
                                    onChanged: model.setPaymentMode,
                                    items: model.paymentOptions
                                        .map(
                                          (e) => DropdownMenuItem(
                                            child: Text(e),
                                            value: e,
                                          ),
                                        )
                                        .toList(),
                                    value: model.paymentMode,
                                    hint: const Text(
                                        'Select the preferred payment mode.'),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                model.paymentMode != null
                    ? Expanded(
                        child: Card(
                        child: Padding(
                          child: _buildPaymentModeWidget(model.paymentMode),
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 8),
                        ),
                      ))
                    : Container(),
                model.isBusy
                    ? const Center(child: BusyWidget())
                    : ActionButton(
                        label: 'Finalize',
                        onPressed: model.paymentMode != null &&
                                model.paymentMode.toLowerCase() == "cash"
                            ? () {
                                if (model.cashValue < model.total) {
                                  print("less");
                                  return null;
                                } else {
                                  model.commit();
                                }
                              }
                            : () => model.commit(),
                      )
              ],
            ),
          ),
        );
      },
      viewModelBuilder: () =>
          PaymentViewModel(items, ref: ref, total: total, docType: docType),
    );
  }

  _buildPaymentModeWidget(String paymentMode) {
    switch (paymentMode.toLowerCase()) {
      case 'cash':
        return _CashPaymentModeWidget();
        break;
      case 'mpesa':
        return _MpesaPaymentModeWidget();
        break;
      case 'multipay':
        return _MultiPayPaymentModeWidget();
        break;
      case 'cheque':
        return _ChequePaymentModeWidget();
        break;
      case 'credit':
        return _CreditPaymentModeWidget();
        break;
      default:
        return Container();
        break;
    }
  }
}

class _CashPaymentModeWidget extends HookViewModelWidget<PaymentViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, PaymentViewModel model) {
    var controller = useTextEditingController();
    return Column(
      children: [
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: model.setCashAmount,
          decoration: InputDecoration(
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(1.0),
              ),
              filled: true,
              fillColor: Colors.grey[200],
              label: const Text(
                'Amount',
              ),
              hintText: 'Amount'),
        ),
        const SizedBox(height: 10),
        model.change > 0
            ? Row(
                children: [
                  const Text('Change : Refund Kshs '),
                  Text(model.change.toStringAsFixed(2)),
                ],
              )
            : model.change < 0
                ? Row(
                    children: [
                      const Text('Request : Kshs '),
                      Text(model.change.abs().toStringAsFixed(2)),
                      const Text(' to finalize the transaction.'),
                    ],
                  )
                : Container()
      ],
    );
  }
}

class _MpesaPaymentModeWidget extends HookViewModelWidget<PaymentViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, PaymentViewModel model) {
    var controller = useTextEditingController();
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      onChanged: model.setPhoneNumber,
      decoration: InputDecoration(
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(1.0),
          ),
          filled: true,
          fillColor: Colors.grey[200],
          label: const Text(
            'Telephone number',
          ),
          hintText: 'MPesa Phone number'),
    );
  }
}

class _CreditPaymentModeWidget extends HookViewModelWidget<PaymentViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, PaymentViewModel model) {
    return const Text("");
  }
}

class _MultiPayPaymentModeWidget extends HookViewModelWidget<PaymentViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, PaymentViewModel model) {
    return ListView(
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
              label: const Text(
                'Enter Cash Amount',
              ),
              hintText: 'Enter Cash Amount to receive from customer'),
        ),
        const SizedBox(
          height: 5,
        ),
        model.cashValue == 0 ? Container() : const Text(""),
        const SizedBox(
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
            label: const Text(
              'Enter customer number',
            ),
          ),
        ),
      ],
    );
  }
}

class _ChequePaymentModeWidget extends HookViewModelWidget<PaymentViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, PaymentViewModel model) {
    var drawerName = useTextEditingController();
    var chequeNumber = useTextEditingController();
    return ListView(
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
            label: const Text(
              'Enter Drawer Name',
            ),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        TextFormField(
          controller: chequeNumber,
          onChanged: model.setChequeNumber,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(1.0),
            ),
            filled: true,
            fillColor: Colors.grey[200],
            label: const Text(
              'Enter Cheque Number',
            ),
          ),
        ),
      ],
    );
  }
}
