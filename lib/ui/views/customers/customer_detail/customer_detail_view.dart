import 'package:distributor/conf/style/lib/colors.dart';
import 'package:distributor/conf/style/lib/fonts.dart';
import 'package:distributor/conf/style/lib/text_styles.dart';
import 'package:distributor/core/helper.dart';
import 'package:distributor/ui/config/brand.dart';
import 'package:distributor/ui/views/customers/customer_detail/accounts_tab/accounts_tab.dart';
import 'package:distributor/ui/views/customers/customer_detail/contacts_tab_view/contacts_tab_view.dart';
import 'package:distributor/ui/views/customers/customer_detail/customer_detail_viewmodel.dart';
import 'package:distributor/ui/views/customers/customer_detail/notifications/notifications_tab.dart';
import 'package:distributor/ui/views/customers/customer_detail/order_history/order_history_view_tab.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:tripletriocore/tripletriocore.dart';

class CustomerDetailView extends StatefulWidget {
  final Customer customer;

  const CustomerDetailView({@required this.customer, Key key})
      : assert(customer != null),
        super(key: key);

  @override
  _CustomerDetailViewState createState() => _CustomerDetailViewState();
}

class _CustomerDetailViewState extends State<CustomerDetailView>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  int currentIndex = 0;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  updateCurrentIndex(int val) {
    setState(() {
      currentIndex = val;
    });
  }

  @override
  initState() {
    _tabController = TabController(length: 4, initialIndex: 0, vsync: this);
    super.initState();
  }

  _buildAddButton(CustomerDetailViewModel model) {
    Widget toDisplay = Container();
    switch (currentIndex) {
      case 0:
        toDisplay = Container();
        break;
      case 1:
        toDisplay = IconButton(
          icon: Icon(Icons.add_circle_outline_sharp),
          onPressed: model.enablePlaceOrder
              ? () {
                  model.navigateToPlaceOrder();
                }
              : null,
        );

        break;
      case 2:
        toDisplay = IconButton(
          icon: Icon(Icons.add_circle_outline_sharp),
          onPressed: model.enableAddPayment
              ? () {
                  model.navigateTOAddPayment();
                }
              : null,
        );

        break;
      case 3:
        toDisplay = IconButton(
          icon: Icon(Icons.add_circle_outline_sharp),
          onPressed: model.enableAddIssue
              ? () {
                  model.navigateToAddIssue();
                }
              : null,
        );
        break;
      default:
        toDisplay = Container();

        break;
    }

    return toDisplay;
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CustomerDetailViewModel>.reactive(
      onModelReady: (model) {},
      viewModelBuilder: () =>
          CustomerDetailViewModel(customer: widget.customer),
      builder: (context, model, child) => Scaffold(
        backgroundColor: kDarkNeutral,
        appBar: AppBar(
          actionsIconTheme: IconThemeData(color: Colors.white),
          title: Text(
            '${widget.customer.name}',style: kAppBarTextStyle,
          ),
          automaticallyImplyLeading: true,
//          leading: IconButton(
//            icon: Icon(Icons.arrow_back),
//            onPressed: () => model.navigateToCustomers,
//          ),
          actions: <Widget>[
            // IconButton(
            //   onPressed: () {
            //     model.navigateToPaymentReferenceView(widget.customer);
            //   },
            //   splashColor: Colors.pink,
            //   tooltip: 'Link payment',
            //   icon: Icon(Icons.verified_user_outlined),
            // ),
            _buildAddButton(model),
            // _CreateOrderButton(),
            PopupMenuButton(
                onSelected: (x) {
                  model.navigateToPage(x);
                },
                itemBuilder: (context) => <PopupMenuEntry<Object>>[
                      PopupMenuItem(
                        child: Text(
                          'Place Order',
                          style: TextStyle(
                              color: model.enablePlaceOrder
                                  ? Colors.black
                                  : Colors.black.withOpacity(0.3)),
                        ),
                        value: 'place_order',
                      ),
                      // PopupMenuItem(
                      //   child: Text(
                      //     'Make Adhoc sale',
                      //     style: TextStyle(
                      //         color: model.enableAdhocSale
                      //             ? Colors.black
                      //             : Colors.black.withOpacity(0.3)),
                      //   ),
                      //   value: 'make_adhoc_sale',
                      // ),
                      PopupMenuDivider(),
                      // PopupMenuItem(
                      //   child: Text(
                      //     'Add Payment',
                      //     style: TextStyle(
                      //         color: model.enableAddPayment
                      //             ? Colors.black
                      //             : Colors.black.withOpacity(0.3)),
                      //   ),
                      //   value: 'add_payment',
                      // ),
                      // PopupMenuItem(
                      //   child: Text(
                      //     'Link Payment',
                      //     style: TextStyle(
                      //         color: model.enableLinkPayment
                      //             ? Colors.black
                      //             : Colors.black.withOpacity(0.3)),
                      //   ),
                      //   value: 'link_payment',
                      // ),
                      // PopupMenuDivider(),
                      PopupMenuItem(
                        child: Text(
                          'Add Issue',
                          style: TextStyle(
                              color: model.enableAddIssue
                                  ? Colors.black
                                  : Colors.black.withOpacity(0.3)),
                        ),
                        value: 'add_issue',
                      ),
                    ]),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: kColorDDSPrimaryLight,
            indicatorWeight: 3.0,
            labelPadding: EdgeInsets.only(bottom: 10.0),
            labelStyle: TextStyle(
                fontFamily: kFontThinBody,
                color: Colors.pink,
                fontSize: kBodyTextSize),
            unselectedLabelStyle: TextStyle(fontFamily: kFontThinBody),
            labelColor: kMutedYellowDark,
            unselectedLabelColor: Colors.white,
            onTap: (int) {
              //Check permission
              bool result = false;
              if (int == 0) {
                result = true;
                updateCurrentIndex(int);
              }
              if (int == 1) {
                // Does the user have authority to check orders
                if (model.enableOrdersTab) {
                  result = true;
                  updateCurrentIndex(int);
                }
              }
              if (int == 2) {
                // Does the user have authority to check accounts
                if (model.enableAccountsTab) {
                  result = true;
                  updateCurrentIndex(int);
                }
              }
              if (int == 3) {
                result = true;
                updateCurrentIndex(int);
              }
              if (!result) {
                //The user cannot view this tab
                _tabController.animateTo(_tabController.previousIndex);
              }
            },
            tabs: <Widget>[
              Tab(
                text: 'Info',
              ),
              Tab(
                text: 'Orders',
              ),
              Tab(
                text: 'Account',
              ),
              Tab(
                text: 'Issues',
              ),
            ],
          ),
        ),
        body: Container(
//          color: Color.fromRGBO(24, 24, 24, 1),
          child: TabBarView(
            controller: _tabController,
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              ContactsTabView(customer: widget.customer),
              OrderHistoryTab(customer: widget.customer),
              model.enableAccountsTab
                  ? AccountsTab(
                      customer: widget.customer,
                    )
                  : Container(),
              model.enableIssuesTab
                  ? NotificationsTab(
                      customer: widget.customer,
                    )
                  : Container(
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      child: Center(
                        child: Text(
                          'You dont have sufficient permissions to view issues',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }
}

class AccountsTableHeader extends StatelessWidget {
  const AccountsTableHeader({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          flex: 3,
          child: Text(
            'DATE',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
        Expanded(
            flex: 5,
            child: Text(
              'DESC',
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            )),
        Expanded(
          flex: 3,
          child: Text(
            'DB/CR',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            'BAL',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      ],
    );
  }
}

class AccountsTableRow extends StatefulWidget {
  final List<CustomerTransaction> customerTransaction;
  final int currentIndex;
  final String date;
  final String description;
  final CustomerRecordType customerRecordType;
  final num creditAmount;
  final num debitAmount;
  final num balanceAmount;
  final openingBalance;

  const AccountsTableRow(
      {this.description,
      @required this.openingBalance,
      @required this.currentIndex,
      @required this.customerTransaction,
      @required this.customerRecordType,
      this.date,
      this.creditAmount,
      this.debitAmount,
      this.balanceAmount,
      Key key})
      : super(key: key);

  @override
  _AccountsTableRowState createState() => _AccountsTableRowState();
}

class _AccountsTableRowState extends State<AccountsTableRow> {
  num amountToDisplay;
  String symbolToDisplay;
  CustomerTransaction _customerTransaction;
  int currentIndex;

  setDataToDisplay(
      {CustomerRecordType customerRecordType,
      num creditAmount,
      num debitAmount}) {
    switch (customerRecordType) {
      case CustomerRecordType.Opening:
        setState(() {
          symbolToDisplay = " ";
          amountToDisplay = null;
        });
        break;
      case CustomerRecordType.Closing:
        symbolToDisplay = " ";
        amountToDisplay = null;
        break;
      case CustomerRecordType.CustomerTransaction:
        // Check the values of the transaction
        if (creditAmount > 0) {
          setState(() {
            symbolToDisplay = "-";
            amountToDisplay = creditAmount;
          });
        } else {
          setState(() {
            symbolToDisplay = " ";
            amountToDisplay = debitAmount;
          });
        }
        break;
    }
  }

  @override
  void initState() {
    _customerTransaction = widget.customerTransaction[widget.currentIndex];
    currentIndex = widget.currentIndex;
    if (_customerTransaction.creditAmount > 0) {
      symbolToDisplay = "-";
      amountToDisplay = _customerTransaction.creditAmount;
    } else {
      symbolToDisplay = " ";
      amountToDisplay = _customerTransaction.debitAmount;
    }
    super.initState();
  }

  stepForward() {
    setState(() {
      currentIndex = currentIndex + 1;
      _customerTransaction = widget.customerTransaction[currentIndex + 1];
    });
  }

  stepBack() {
    setState(() {
      currentIndex = currentIndex - 1;
      _customerTransaction = widget.customerTransaction[currentIndex - 1];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        dense: true,
        onTap: () {
          showDialog(
              context: context,
              builder: (context) => Dialog(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              splashColor: Colors.pink,
                              icon: Icon(
                                Icons.close,
                                color: Colors.indigo,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'DATE',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                '${Helper.getDay(widget.customerTransaction[currentIndex].entryDate)}',
                                style: TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 14),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'DESCRIPTION',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  '${_customerTransaction.description}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                currentIndex == 0
                                    ? 'Opening Balance'
                                    : 'Previous Balance',
                                style: TextStyle(
                                    fontSize: 14, fontStyle: FontStyle.italic),
                              ),
                              Spacer(),
                              Text(
                                currentIndex == 0
                                    ? Helper.formatCurrency(
                                        widget.openingBalance)
                                    : Helper.formatCurrency(widget
                                        .customerTransaction[currentIndex - 1]
                                        .balanceAmount),
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          _customerTransaction.creditAmount > 0
                              ? Row(
                                  children: <Widget>[
                                    Text(
                                      'CREDIT : ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Spacer(),
                                    Text(
                                      ' - ${Helper.formatCurrency(_customerTransaction.creditAmount)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      'DEBIT : ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Spacer(),
                                    Text(
                                      '${Helper.formatCurrency(_customerTransaction.debitAmount)}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14),
                                      textAlign: TextAlign.right,
                                    ),
                                  ],
                                ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'BALANCE',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                  'Kshs ${Helper.formatCurrency(_customerTransaction.balanceAmount)}'),
                            ],
                          ),
                          Spacer(),
                          Container(
                            alignment: Alignment.bottomCenter,
                            child: Column(
                              children: <Widget>[
                                Text(
                                  'Record ${currentIndex + 1} of ${widget.customerTransaction.length}',
                                  style: TextStyle(fontSize: 14),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    IconButton(
                                      icon: Icon(Icons.keyboard_arrow_left),
                                      onPressed: currentIndex - 1 <= 0
                                          ? null
                                          : () {
//                                                setState(() {
//                                                  currentIndex -=
//                                                      currentIndex--;
//                                                });
                                            },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.keyboard_arrow_right),
                                      onPressed: currentIndex + 1 >=
                                              widget.customerTransaction.length
                                          ? null
                                          : () {
//                                                setState(() {
//                                                  currentIndex +=
//                                                      currentIndex++;
//                                                });
//                                                stepForward();
                                            },
                                    )
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ));
        },
        title: Row(
          children: <Widget>[
            Text(
              '${widget.description}',
            ),
          ],
        ),
        subtitle: Row(
          children: <Widget>[
            Text(
              '${widget.date}',
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              '$symbolToDisplay ${Helper.formatCurrency(amountToDisplay)}',
            ),
            Spacer(),
            Text(
              'Kshs${Helper.formatCurrency(widget.balanceAmount)}',
              style:
                  TextStyle(fontWeight: FontWeight.w500, color: Colors.black38),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomerTransactionRow extends StatelessWidget {
  final CustomerTransaction customerTransaction;
  final num openingBalance;
  final List<CustomerTransaction> customerTransactionList;
  final int currentIndex;
  CustomerTransactionRow(
      {this.customerTransaction,
      @required this.openingBalance,
      @required this.customerTransactionList,
      @required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return AccountsTableRow(
      currentIndex: currentIndex,
      customerTransaction: customerTransactionList,
      customerRecordType: CustomerRecordType.CustomerTransaction,
      date: Helper.getDay(customerTransaction.entryDate),
      description: customerTransaction.description,
      openingBalance: openingBalance,
      creditAmount: customerTransaction.creditAmount,
      debitAmount: customerTransaction.debitAmount,
      balanceAmount: customerTransaction.balanceAmount,
    );
  }
}

enum CustomerRecordType { Opening, Closing, CustomerTransaction }

class _CreateOrderButton extends HookViewModelWidget<CustomerDetailViewModel> {
  _CreateOrderButton({Key key}) : super(key: key);
  @override
  Widget buildViewModelWidget(
      BuildContext context, CustomerDetailViewModel model) {
    return IconButton(
      color: model.enableCreateOrderTab
          ? Colors.white
          : Colors.white.withOpacity(0.3),
      splashColor: Colors.pink,
      onPressed: model.canPlaceOrder()
          ? () async {
              await model
                  .navigateToCreateSalesOrderView(model.customer)
                  .then((value) {
                if (value != null) {
                  return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    backgroundColor: Colors.red,
                    content: Container(child: Text('No order was placed')),
                  ));
                } else {
                  //@TODO: Fetch the data again

                  return ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Colors.green,
                      content: Container(
                        child: Text(
                          '\u{1F44D} ${model.customer.name}\'s order was placed successfully.',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  );
                }
              });
            }
          : null,
      icon: Icon(Icons.add),
    );
  }
}
