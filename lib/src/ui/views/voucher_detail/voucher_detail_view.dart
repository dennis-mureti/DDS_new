import 'package:distributor/conf/style/lib/text_styles.dart';
import 'package:distributor/core/helper.dart';
import 'package:distributor/src/ui/views/voucher_detail/voucher_detail_viewmodel.dart';
import 'package:distributor/ui/shared/widgets.dart';
import 'package:distributor/ui/widgets/dumb_widgets/app_bar_column_title.dart';
import 'package:distributor/ui/widgets/dumb_widgets/misc_widgets.dart';
import 'package:distributor/ui/widgets/dumb_widgets/product_quantity_container.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:tripletriocore/tripletriocore.dart';

class VoucherDetailView extends StatelessWidget {
  final String transactionId;
  final String voucherType;
  final String transactionStatus;

  const VoucherDetailView(
      {Key key,
      @required this.transactionId,
      @required this.voucherType,
      @required this.transactionStatus})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<VoucherDetailViewmodel>.reactive(
        onModelReady: (model) => model.init(),
        builder: (context, model, child) {
          return Scaffold(
            appBar: AppBar(
              title: AppBarColumnTitle(
                mainTitle: 'Voucher Details',
                subTitle: transactionId,
              ),
            ),
            body: Container(
              child: model.stockTransaction == null
                  ? BusyWidget()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                          !model.displayUserTransactionDropdown
                              ? Container()
                              : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: DropdownButton(
                                          dropdownColor: Colors.white,
                                          disabledHint:
                                              Text('Operation not possible'),
                                          isExpanded: true,
                                          value: model.status,
                                          onChanged: model.disableDropdown
                                              ? null
                                              : (String val) {
                                                  model.setStatus(val);
                                                },
                                          hint: Text(
                                              'Accept or Cancel this transaction'),
                                          items: model.statusStrings
                                              .map(
                                                (e) => DropdownMenuItem(
                                                  child: _buildDropDownIcon(e),
                                                  value: e,
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          Container(
                            width: double.infinity,
                            child: Material(
                              color: Colors.grey.withOpacity(0.1),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0, vertical: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ReportFieldRow(
                                        field: 'Status',
                                        value: transactionStatus),
                                    ReportFieldRow(
                                        field: 'Voucher Type',
                                        value:
                                            model.stockTransaction.voucherType),
                                    ReportFieldRow(
                                        field: 'Voucher Subtype',
                                        value: model
                                            .stockTransaction.voucherSubType),
                                    ReportFieldRow(
                                      field: 'Entry Date',
                                      value: Helper.formatDate(DateTime.parse(
                                          model.stockTransaction.entryDate)),
                                    ),
                                    Text('Remarks'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 16.0, left: 15),
                              child: Text(
                                'Items'.toUpperCase(),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          model.stockTransaction.items != null
                              ? Expanded(
                                  child: ListView.builder(
                                    itemBuilder: (context, index) {
                                      Product p =
                                          model.stockTransaction.items[index];
                                      return ListTile(
                                        title: Text(p.itemName,
                                            style: kTileLeadingTextStyle),
                                        subtitle: Text(p.itemCode,
                                            style: kTileSubtitleTextStyle),
                                        trailing: ProductQuantityContainer(
                                          quantity: p.quantity,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14,
                                              color: Colors.black87),
                                        ),
                                      );
                                    },
                                    itemCount:
                                        model.stockTransaction.items.length,
                                  ),
                                )
                              : Expanded(
                                  child: ListView(
                                    children: [
                                      Center(child: Text('No items')),
                                    ],
                                  ),
                                ),
                        ]),
            ),
          );
        },
        viewModelBuilder: () => VoucherDetailViewmodel(
            transactionId, voucherType, transactionStatus));
  }

  _buildDropDownIcon(String e) {
    switch (e.toLowerCase()) {
      case 'accept':
        return Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              e,
              style:
                  TextStyle(fontWeight: FontWeight.w600, color: Colors.green),
            )
          ],
        );
        break;
      case 'cancel':
        return Row(
          children: [
            Icon(
              Icons.cancel,
              color: Colors.red,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              e,
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red),
            )
          ],
        );
        break;
    }
  }
}
