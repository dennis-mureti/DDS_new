import 'package:distributor/ui/widgets/quantity_input/quantity_input_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class QuantityInput extends StatelessWidget {
  // The initial quantity for the input
  final int initialQuantity;

  // The minimum quantity that the input should allow
  final int minQuantity;

  //The max quantity that the input should allow
  final int maxQuantity;

  final String title;

  final String description;

  const QuantityInput(
      {Key key,
      this.initialQuantity,
      this.minQuantity,
      this.maxQuantity,
      this.title = "Enter Quantity to Edit",
      this.description = ""})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<QuantityInputViewModel>.reactive(
      builder: (BuildContext, model, child) {
        return AlertDialog(
          scrollable: true,
          title: Container(
            width: MediaQuery.of(context).size.width * 0.92,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Divider(),
                Text(description),
              ],
            ),
          ),
          content: Column(
            children: [
              _TextEditingHook(),
              if (model.displayError)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    model.errorMsg,
                    style: TextStyle(
                        color: Colors.red, fontStyle: FontStyle.italic),
                  ),
                )
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 3.5,
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red)),
                    onPressed: model.cancel,
                    child: Row(
                      children: [
                        Icon(Icons.cancel),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          'Cancel'.toUpperCase(),
                          style: TextStyle(),
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 3.5,
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.green)),
                    onPressed: model.displayError ? null : model.submit,
                    child: Row(
                      children: [
                        Icon(Icons.check_circle),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          'OK'.toUpperCase(),
                          style: TextStyle(),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
        ;
      },
      viewModelBuilder: () {
        return QuantityInputViewModel(
            initialQuantity: initialQuantity,
            maxQuantity: maxQuantity,
            minQuantity: minQuantity);
      },
    );
  }
}

class _TextEditingHook extends HookViewModelWidget<QuantityInputViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, QuantityInputViewModel model) {
    var controller =
        useTextEditingController(text: model.initialQuantity.toString());
    return TextFormField(
      autofocus: true,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: Icon(
              Icons.refresh_outlined,
              color: Colors.grey,
            ),
            onPressed: () {
              model.resetQuantity();
              controller.text = model.quantity.toString();
            },
          ),
          focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Colors.grey.withOpacity(0.5), width: 1)),
          border: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Colors.grey.withOpacity(0.5), width: 1))),
      controller: controller,
      onChanged: (value) {
        model.updateQuantity(value);
      },
      // onEditingComplete: () {
      //   //Close the keyboard
      //   print('on edit complete');
      // },
      // onFieldSubmitted: (val) {
      //   model.updateQuantity(val);
      //   print('on edit field submitted');
      // },
    );
  }
}
