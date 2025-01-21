import 'package:distributor/conf/dds_brand_guide.dart';
import 'package:distributor/conf/style/lib/text_styles.dart';
import 'package:distributor/src/ui/views/adhoc_payment/adhoc_payment_viewmodel.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class AdhocPaymentView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AdhocPaymentViewmodel>.reactive(
        onModelReady: (model) => model.init(),
        builder: (context, model, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Selling : Payment',
                style: kAppBarTextStyle,
              ),
            ),
            body: Container(
              margin: const EdgeInsets.only(
                  left: 10.0, right: 10.0, bottom: 10.0, top: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Amount Due :  ${model.currency} ${model.total.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  DropdownButton(
                      key: const Key('paymentmodes'),
                      items: model.paymentModes
                          .map((e) => DropdownMenuItem(
                                child: Text(e),
                                value: e,
                              ))
                          .toList(),
                      value: model.paymentMode,
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      hint: const Text('Select payment mode'),
                      onChanged: (val) {
                        model.setPaymentType(val);
                      }),
                  const SizedBox(
                    height: 8,
                  ),
                  _buildPaymentFields(model.paymentMode),
                  const SizedBox(
                    height: 8,
                  ),
                  // _RemarksTextField(),
                  const SizedBox(
                    width: 24,
                  ),
                  model.isBusy
                      ? const Center(child: BusyWidget())
                      : Container(
                          width: MediaQuery.of(context).size.width,
                          child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    kColDDSPrimaryDark)),
                            onPressed: model.enableCheckout
                                ? () {
                                    model.completeAdhoc();
                                  }
                                : null,
                            child: const Text(
                              'COMPLETE',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          );
        },
        viewModelBuilder: () => AdhocPaymentViewmodel());
  }

  _buildPaymentFields(String paymentType) {
    switch (paymentType) {
      case 'MPESA':
        return _MPESAFormField();
        break;
      case 'Equitel':
        return _AirtelFormField();
        break;
      default:
        return Container();
        break;
    }
  }
}

class _RemarksTextField extends HookViewModelWidget<AdhocPaymentViewmodel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, AdhocPaymentViewmodel model) {
    var remarksController = useTextEditingController();
    return TextFormField(
      controller: remarksController,
      minLines: 1,
      maxLines: 3,
      onChanged: model.updateRemarks,
      keyboardType: TextInputType.name,
      decoration: const InputDecoration(
        hintText: 'Remarks',
      ),
    );
  }
}

class _MPESAFormField extends HookViewModelWidget<AdhocPaymentViewmodel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, AdhocPaymentViewmodel model) {
    return Container(
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(hintText: 'Till/Paybill Number'),
          ),
          TextFormField(
            decoration: const InputDecoration(hintText: 'Telephone Number'),
          ),
          TextFormField(
            decoration: const InputDecoration(hintText: 'Reference'),
          ),
          TextFormField(
            decoration: const InputDecoration(hintText: 'Telephone Number'),
          ),
          TextFormField(
            decoration: const InputDecoration(hintText: 'Payer Name'),
          ),
        ],
      ),
    );
  }
}

class _AirtelFormField extends HookViewModelWidget<AdhocPaymentViewmodel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, AdhocPaymentViewmodel viewModel) {
    return Container(
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(hintText: 'Till/Paybill Number'),
          ),
          TextFormField(
            decoration: InputDecoration(hintText: 'Telephone Number'),
          ),
          TextFormField(
            decoration: InputDecoration(hintText: 'Reference'),
          ),
          TextFormField(
            decoration: InputDecoration(hintText: 'Telephone Number'),
          ),
          TextFormField(
            decoration: InputDecoration(hintText: 'Payer Name'),
          ),
        ],
      ),
    );
  }
}
