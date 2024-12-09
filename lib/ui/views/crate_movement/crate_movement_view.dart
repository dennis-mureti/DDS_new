import 'package:distributor/conf/style/lib/colors.dart';
import 'package:distributor/conf/style/lib/text_styles.dart';
import 'package:distributor/core/enums.dart';
import 'package:distributor/ui/views/crate_movement/crate_movement_viewmodel.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';
import 'package:distributor/ui/widgets/dumb_widgets/empty_content_container.dart';
import 'package:distributor/ui/widgets/dumb_widgets/generic_container.dart';
import 'package:distributor/ui/widgets/smart_widgets/customer_text_input/customer_textinput.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:tripletriocore/tripletriocore.dart';

class CrateMovementView extends StatelessWidget {
  final CrateTxnType crateTxnType;
  final DeliveryStop deliveryStop;
  final Customer customer;
  const CrateMovementView(
      {Key key, this.crateTxnType, this.customer, this.deliveryStop})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CrateMovementViewModel>.reactive(
        onModelReady: (model) => model.init(),
        builder: (context, model, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                _buildTitle(crateTxnType),
                style: kAppBarTextStyle,
              ),
            ),
            body: GenericContainer(
              child: model.isBusy
                  ? Center(child: BusyWidget())
                  : Column(
                      children: [
                        if (model.crateList.isNotEmpty)
                          Text(_buildLead(crateTxnType),
                              style: kLeadingBodyText),
                        crateTxnType == CrateTxnType.Return &&
                                model.crateList.isNotEmpty
                            ? CheckboxListTile(
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                value: model.disableTextFormField,
                                onChanged: (_) =>
                                    model.toggleDisableTextFormField(),
                                title: Text(
                                    'Would you like to edit the quantity of crates ? '),
                              )
                            : Container(),

                        //Check if it is a reliever journey
                        model.isReliever && crateTxnType == CrateTxnType.Return
                            ? Row(
                                children: [
                                  Text(
                                    'Route : ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    child: DropdownButton(
                                        isExpanded: true,
                                        hint: Text('Select Route'),
                                        value: model.warehouse,
                                        items: model.warehouseList
                                            .map((e) => DropdownMenuItem(
                                                  child: Text(e.name),
                                                  value: e.name,
                                                ))
                                            .toList(),
                                        onChanged: (s) =>
                                            model.setWarehouse(s)),
                                  ),
                                ],
                              )
                            : Container(),

                        //Check if it is a multibranch
                        model.isMultiBranch ? Container() : Container(),

                        crateTxnType == CrateTxnType.Return &&
                                model.crateList.isNotEmpty &&
                                model.disableTextFormField
                            ? Row(
                                children: [
                                  Text(
                                    'Reason For Editing : ',
                                    style: kLabelTextStyle,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    child: DropdownButton(
                                      isExpanded: true,
                                      hint: Text('Reason for difference'),
                                      items: model.editReasons
                                          .map((e) => DropdownMenuItem(
                                                child: Text(e),
                                                value: e,
                                              ))
                                          .toList(),
                                      onChanged: model.setReason,
                                      value: model.reason,
                                    ),
                                  ),
                                ],
                              )
                            : Container(),

                        model.branches != null &&
                                model.branches.isNotEmpty &&
                                !model.isReliever
                            ? Row(
                                children: [
                                  Text(
                                    'Branch : ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    child: DropdownButton(
                                        isExpanded: true,
                                        hint: Text('Select Branch'),
                                        value: model.branch,
                                        items: model.branches
                                            .map((e) => DropdownMenuItem(
                                                  child: Text(e['name']),
                                                  value: e['name'],
                                                ))
                                            .toList(),
                                        onChanged: (s) => model.setBranch(s)),
                                  ),
                                ],
                              )
                            : Container(),
                        // Divider(),
                        deliveryStop != null &&
                                crateTxnType != CrateTxnType.Return
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    Text(
                                      'Customer : ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      deliveryStop.customerId,
                                      style: TextStyle(),
                                    ),
                                  ],
                                ),
                              )
                            : crateTxnType == CrateTxnType.Return
                                ? Container()
                                : Row(
                                    children: [
                                      Text(
                                        'Customer Name : ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Expanded(
                                        child: CustomerTextInput(
                                            customerList: model.customerList,
                                            onSelected: model.setCustomer),
                                      ),
                                    ],
                                  ),
                        Divider(),
                        model.crateList.isEmpty
                            ? Expanded(
                                child: Center(
                                  child: EmptyContentContainer(
                                      label: 'There are no crates.'),
                                ),
                              )
                            : Expanded(
                                child: ListView.builder(
                                  itemBuilder: (context, index) {
                                    var crate = model.crateList[index];
                                    return Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(crate.itemName,
                                                  style: kTileLeadingTextStyle),
                                              SizedBox(
                                                height: 4,
                                              ),
                                              Text(
                                                crate.itemCode,
                                                style: kTileSubtitleTextStyle,
                                              ),
                                            ],
                                          ),
                                          Container(
                                            width: 70,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                              child: TextFormField(
                                                inputFormatters: <
                                                    TextInputFormatter>[
                                                  FilteringTextInputFormatter
                                                      .allow(RegExp("[0-9]")),
                                                ],
                                                style: TextStyle(fontSize: 16),
                                                textAlign: TextAlign.center,
                                                initialValue:
                                                    model.disableTextFormField
                                                        ? crate.quantity
                                                            .toStringAsFixed(0)
                                                        : crate.quantity
                                                            .toStringAsFixed(0),
                                                enabled:
                                                    model.disableTextFormField,
                                                onChanged: (val) {
                                                  //@TODO Max value of crates
                                                  model.updateItemSet(
                                                      val, crate);
                                                },
                                                onEditingComplete: () {
                                                  FocusScope.of(context)
                                                      .nextFocus();
                                                },
                                                onFieldSubmitted: (val) {
                                                  // Check if this item exists
                                                  model.updateItemSet(
                                                      val, crate);
                                                },
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  itemCount: model.crateList.length,
                                ),
                              ),
                        model.isBusy
                            ? Center(
                                child: BusyWidget(),
                              )
                            : model.crateList.isNotEmpty
                                ? Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  kColorDDSPrimaryDark)),
                                      onPressed:
                                          crateTxnType == CrateTxnType.Return
                                              ? model.commitReturnCrates
                                              : model.isValid == true ||
                                                      model.customerId != null
                                                  ? model.commitChanges
                                                  : null,
                                      child: Text(
                                        'UPDATE',
                                        style: TextStyle(
                                            // fontFamily: 'NerisBlack',
                                            color: Colors.white),
                                      ),
                                    ),
                                  )
                                : Container(),
                      ],
                    ),
            ),
          );
        },
        viewModelBuilder: () =>
            CrateMovementViewModel(deliveryStop, crateTxnType));
  }

  _buildTitle(CrateTxnType crateTxnType) {
    switch (crateTxnType) {
      case CrateTxnType.Drop:
        return 'Leave Crates with Customer';

      case CrateTxnType.Pickup:
        return 'Collect Crates From Customer';

      case CrateTxnType.Return:
        return 'Return Crates To Warehouse';
      default:
        return 'Collect / Drop Crates';
    }
  }

  _buildLead(CrateTxnType crateTxnType) {
    switch (crateTxnType) {
      case CrateTxnType.Drop:
        return 'Enter the number of crates that have left behind with the customer.';

      case CrateTxnType.Pickup:
        return 'Enter the number of crates that you have collected from the customer.';

      case CrateTxnType.Return:
        return 'Confirm that these are the number of crates you have in stock. Edit the quantities and select a reason for editing.';
      default:
        return 'Select the crate, action and the quantity.';
    }
  }
}
