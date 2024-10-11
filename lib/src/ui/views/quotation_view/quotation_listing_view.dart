import 'package:distributor/conf/style/lib/text_styles.dart';
import 'package:distributor/src/ui/views/quotation_view/quotation_viewmodel.dart';
import 'package:distributor/ui/views/home/home_viewmodel.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';
import 'package:distributor/ui/widgets/dumb_widgets/empty_content_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:tripletriocore/tripletriocore.dart';

class QuotationListingView extends HookViewModelWidget<HomeViewModel> {
  QuotationListingView({Key key}) : super(key: key);

  @override
  Widget buildViewModelWidget(BuildContext context, HomeViewModel model) {
    return model.isBusy
        ? Center(child: BusyWidget())
        : model.quotations.isEmpty
            ? Center(
                child: EmptyContentContainer(
                  label: "There are no quotations available",
                ),
              )
            : ListView.builder(
                itemBuilder: (context, index) {
                  var quotation = model.quotations[index];
                  // var customer = Customer.fromJson(quotation["customer"]);
                  return ListTile(
                    onTap: () => model.navigateToQuotationDetailView(quotation),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          quotation['customer']['customer_name'],
                          style: kTileLeadingTextStyle,
                        ),
                        Container(
                          child: Text(
                            '${quotation['status'].toUpperCase()}',
                            textAlign: TextAlign.right,
                          ),
                          width: 100,
                        ),
                      ],
                    ),
                    subtitle: Text(
                      quotation["id"],
                      style: kTileSubtitleTextStyle,
                    ),
                  );
                },
                itemCount: model.quotations.length,
              );
  }
}
