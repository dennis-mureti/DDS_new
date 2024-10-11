import 'package:distributor/conf/style/lib/text_styles.dart';
import 'package:distributor/ui/views/customers/customer_viewmodel.dart';
import 'package:distributor/ui/widgets/dumb_widgets/misc_widgets.dart';
import 'package:distributor/ui/widgets/smart_widgets/customer_text_input/customer_textinput.dart';
import 'package:flutter/material.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:tripletriocore/tripletriocore.dart';

class CustomerListWidget extends HookViewModelWidget<CustomerViewModel> {
  CustomerListWidget({Key key, reactive: true}) : super(key: key);

  @override
  Widget buildViewModelWidget(BuildContext context, CustomerViewModel model) {
    return model.customerList.length == 0
        ? NoInfoFound(text: 'No customers found.')
        : Column(
            children: [
              Row(
                // mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomerTextInput(
                        customerList: model.customerList,
                        onSelected: model.navigateToCustomer,
                      ),
                    ),
                  ),
                  // SizedBox(
                  //   width: 3,
                  // ),
                  //   Expanded(
                  //     child: DropdownButton(
                  //         isDense: true,
                  //         dropdownColor: Colors.white,
                  //         value: model.customerFilter,
                  //         onChanged: (val) {
                  //           model.toggleSortAscending();
                  //           model.customerFilter = val;
                  //         },
                  //         items: model.customerFilters
                  //             .map((e) => DropdownMenuItem(
                  //                   child: Text(
                  //                     e['value'],
                  //                   ),
                  //                   value: e['name'],
                  //                 ))
                  //             .toList()),
                  //   ),
                ],
              ),
              Divider(
                height: 0.5,
              ),
              Expanded(
                child: CustomerList(
                    customerList: model.listOfCustomers,
                    onTap: model.navigateToCustomer),
              ),
            ],
          );
  }
}

Widget CustomerList({List<Customer> customerList, Function onTap}) {
  return ListView.builder(
      itemCount: customerList.length,
      itemBuilder: (context, index) {
        Customer customer = customerList[index];
        return Container(
          child: ListTile(
            visualDensity: VisualDensity.comfortable,
            // trailing: Container(
            //   width: 60,
            //   height: 60,
            //   child: ClipOval(
            //     child: InkWell(
            //       onTap: () async {
            //         await showModalBottomSheet(
            //           context: (context),
            //           builder: (context) => Container(
            //             color: Colors.white,
            //             padding:
            //                 EdgeInsets.only(bottom: 40, left: 20, right: 20),
            //             child: Column(
            //               mainAxisSize: MainAxisSize.min,
            //               children: [
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     IconButton(
            //                       color: kColorMiniDarkBlue,
            //                       iconSize: 25,
            //                       onPressed: () {
            //                         Navigator.pop(context);
            //                       },
            //                       icon: Icon(Icons.close),
            //                     ),
            //                   ],
            //                 ),
            //                 ListTile(
            //                   leading: Icon(Icons.phone),
            //                   title: Text('Call'),
            //                   onTap: () async {
            //                     var result =
            //                         await launch('tel:${customer.telephone}');
            //                     Navigator.pop(context, result);
            //                   },
            //                 ),
            //                 ListTile(
            //                   leading: Icon(Icons.message),
            //                   title: Text('Send SMS'),
            //                   onTap: () async {
            //                     var result =
            //                         await launch('sms:${customer.telephone}');
            //                     Navigator.pop(context, result);
            //                   },
            //                 ),
            //                 ListTile(
            //                   leading: Icon(Icons.location_on),
            //                   title: Text('Location'),
            //                   onTap: () async {
            //                     await Navigator.of(context).push(
            //                       MaterialPageRoute(
            //                           builder: (context) => CustomerLocation(
            //                                 customer: customer,
            //                               ),
            //                           fullscreenDialog: false),
            //                     );
            //                     Navigator.pop(context);
            //                   },
            //                 )
            //               ],
            //             ),
            //           ),
            //         );
            //       },
            //       splashColor: Colors.pink,
            //       child: Material(
            //         color: kLightestBlue,
            //         type: MaterialType.button,
            //         elevation: 4,
            //         shadowColor: kLightBlue,
            //         child: SizedBox(
            //           width: 50,
            //           height: 50,
            //           child: Icon(Icons.contacts),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            onTap: () {
              onTap(customer);
            },
            title: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Text(
                '${customer.name}',
                style: kTileLeadingTextStyle,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Row(
                children: [
                  // Text(
                  //   'ROUTE',
                  //   style: kTileSubtitleTextStyle,
                  // ),
                  // SizedBox(
                  //   width: 5,
                  // ),
                  Text(
                    '${customer.branch}'.toUpperCase(),
                    style: kTileSubtitleTextStyle,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  customer.foreignName != null
                      ? Text(
                          '${customer.foreignName}'.toUpperCase(),
                          style: kTileSubtitleTextStyle.copyWith(
                              color: Colors.orangeAccent),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        );
      });
}
