import 'package:distributor/core/helper.dart';
import 'package:distributor/ui/config/brand.dart';
import 'package:distributor/ui/shared/widgets.dart';
import 'package:distributor/ui/views/customer_location.dart';
import 'package:distributor/ui/views/customers/customer_detail/contacts_tab_view/contacts_tab_view_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:tripletriocore/tripletriocore.dart';

class ContactsTabView extends StatelessWidget {
  final Customer customer;
  ContactsTabView({@required this.customer, Key key})
      : assert(customer != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ContactsTabViewViewModel>.nonReactive(
        builder: (context, model, child) => SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Material(
                                type: MaterialType.card,
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                                elevation: 2.0,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10.0),
                                  padding: const EdgeInsets.all(15.0),
                                  width: double.infinity,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Center(
                                          child: Text(
                                        'General Information'.toUpperCase(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18.0),
                                      )),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                          child: Container(
                                            width: 40.0,
                                            height: 2.0,
                                            color: kMutedPrimary,
                                          ),
                                        ),
                                      ),
                                      ReportFieldRow(
                                          field: 'Customer Type',
                                          value: customer.customerType),
                                      ReportFieldRow(
                                          field: 'Customer Group',
                                          value: customer.customerGroup),
                                      ReportFieldRow(
                                          field: 'Telephone',
                                          value: customer.telephone),

//                            Text('Area : ${widget.customer.area}'),
                                      ReportFieldRow(
                                          field: customer.idType,
                                          value: customer.idNumber),
                                      ReportFieldRow(
                                          field: 'Category',
                                          value: customer.customerGroup),
                                      ReportFieldRow(
                                          field: 'Status',
                                          value: customer.customerStatus),
                                      ReportFieldRow(
                                          field: 'Market Segment',
                                          value: customer.marketSegment),
                                      ReportFieldRow(
                                          field: 'Branch',
                                          value: customer.branch),
                                      //@TODO : Fix the route
                                      ReportFieldRow(
                                          field: 'Route',
                                          value: customer.route.toString()),
                                      ReportFieldRow(
                                          field: 'Price List',
                                          value: customer.defaultPriceList),
                                      // ReportFieldRow(
                                      //   field: 'Credit Limit',
                                      //   value:
                                      //       'Kshs ${Helper.formatCurrency(customer.creditLimit)}',
                                      // ),

                                      Row(
                                        children: [
                                          Text('Location'),
                                          TextButton.icon(
                                              onPressed: () async {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          CustomerLocation(
                                                            customer: customer,
                                                          ),
                                                      fullscreenDialog: false),
                                                );
                                              },
                                              icon: Icon(Icons.location_on),
                                              label: Text('')),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Material(
                                type: MaterialType.card,
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                                elevation: 1.0,
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 10.0),
                                  padding: EdgeInsets.all(15.0),
                                  width: double.infinity,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Center(
                                        child: Text(
                                          'Financial Information'.toUpperCase(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 18.0),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                          child: Container(
                                            width: 40.0,
                                            height: 2.0,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                      // ReportFieldRow(
                                      //   field: 'Credit Limit',
                                      //   value:
                                      //       'Kshs ${Helper.formatCurrency(customer.creditLimit)}',
                                      // ),
                                      ReportFieldRow(
                                        field: 'Terms of Payment',
                                        value: '${customer.termsOfPayment}',
                                      ),
                                      ReportFieldRow(
                                        field: 'Payment Mode',
                                        value: '${customer.paymentMode}',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
        viewModelBuilder: () => ContactsTabViewViewModel());
  }
}
