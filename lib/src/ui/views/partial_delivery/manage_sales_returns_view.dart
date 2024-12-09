import 'package:distributor/src/ui/views/partial_delivery/manage_sales_return_viewmodel.dart';
import 'package:distributor/ui/widgets/dumb_widgets/generic_container.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class ManageSalesReturnsView extends StatefulWidget {
  final List reasons;
  final int index;
  final salesOrderRequestItem;
  const ManageSalesReturnsView(
      {Key key, this.reasons, this.salesOrderRequestItem, this.index})
      : super(key: key);

  @override
  State<ManageSalesReturnsView> createState() => _ManageSalesReturnsViewState();
}

class _ManageSalesReturnsViewState extends State<ManageSalesReturnsView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ManageSalesReturnViewModel>.reactive(
      builder: (BuildContext context, ManageSalesReturnViewModel model,
              Widget child) =>
          Scaffold(
        appBar: AppBar(
          title: Text(widget.salesOrderRequestItem['itemName']),
          actions: [
            IconButton(
              onPressed: model.salesReturns.isEmpty ? null : model.reset,
              icon: Icon(Icons.delete),
              tooltip: 'Clear Sales Returns',
            )
          ],
        ),
        body: GenericContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
                child: Text(
                  'Update the Sales Returns quantities for ${widget.salesOrderRequestItem['itemName']}.\nDispatched quantity for current journey is ${model.maxQuantity}.'
                  '\nAvailable quantity for return for current journey is ${model.availableQuantity}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    String reason = widget.reasons[index];
                    return Row(
                      children: [
                        Expanded(child: Text(reason)),
                        Container(
                          child: TextFormField(
                              // initialValue: '0',
                              //@TODO Check if the corresponding checkbox is enabled
                              // enabled: false,
                              onChanged: (value) {
                                model.updateSalesReturns(index, value);
                              },
                              keyboardType: TextInputType.number),
                          width: 50,
                        ),
                      ],
                    );
                  },
                  itemCount: widget.reasons.length,
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                    onPressed: model.salesReturns.isEmpty
                        ? null
                        : () => model.confirmSalesReturnForSKU(),
                    child: Text('Submit Sales Returns')),
              )
            ],
          ),
        ),
      ),
      viewModelBuilder: () => ManageSalesReturnViewModel(
          widget.salesOrderRequestItem, widget.reasons, widget.index),
    );
  }
}
