import 'package:distributor/src/ui/views/quotation_view/confirm_quotation_viewmodel.dart';
import 'package:distributor/ui/widgets/action_button.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:tripletriocore/tripletriocore.dart';

class ConfirmQuotationView extends StatelessWidget {
  final orderedItems;
  final Customer customer;
  const ConfirmQuotationView({Key key, this.orderedItems, this.customer})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ConfirmQuotationViewModel>.reactive(
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Confirm Quotation'),
          ),
          body: Column(
            children: [
              Container(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'Customer : '.toUpperCase(),
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 13),
                            ),
                            Text(' ${model.customer.name}')
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Text(
                              'Cart Total : '.toUpperCase(),
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 13),
                            ),
                            Text(' KSH ${model.total.toStringAsFixed(2)}'),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Text(
                              'Items  : '.toUpperCase(),
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 13),
                            ),
                            Text(' ${model.orderedItems.length.toString()}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    var item = model.orderedItems[index];
                    return ListTile(
                      leading: Text(item.quantity.toString()),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item.itemName),
                          Text((item.quantity * item.itemPrice)
                              .toStringAsFixed(2))
                        ],
                      ),
                      subtitle: Text(item.itemPrice.toStringAsFixed(2)),
                    );
                  },
                  itemCount: model.orderedItems.length,
                ),
              ),
              model.isBusy
                  ? BusyWidget()
                  : ActionButton(
                      label: 'Generate Quotation',
                      onPressed: () => model.generateQuotation(),
                    )
            ],
          ),
        );
      },
      viewModelBuilder: () => ConfirmQuotationViewModel(orderedItems, customer),
    );
  }
}
