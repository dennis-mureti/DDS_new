import 'package:badges/badges.dart' as badge;
import 'package:distributor/ui/widgets/reactive/transaction_popup/transaction_popupviewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class TransactionPopupView extends StatelessWidget {
  final String branchId;
  final Function onSelected;
  const TransactionPopupView({Key key, this.branchId, this.onSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<TransactionPopupViewModel>.reactive(
        onModelReady: (model) => model.init(),
        fireOnModelReadyOnce: false,
        disposeViewModel: true,
        createNewModelOnInsert: true,
        builder: (context, model, child) => badge.Badge(
              showBadge: model.hasPendingTransactions,
              badgeColor: Colors.red,
              position: badge.BadgePosition(top: 15, end: 10),
              toAnimate: true,
              animationDuration: Duration(seconds: 2),
              borderRadius: BorderRadius.circular(300),
              // animationType: BadgeAnimationType.scale,
              child: PopupMenuButton(
                // onSelected: (value) => model.onStockBalancePopupSelected(value),
                onSelected: (value) => model.onPopupAction(value),
                itemBuilder: (context) => <PopupMenuEntry<Object>>[
                  PopupMenuItem(
                    child: Text('Pending Transactions'),
                    value: 0,
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem(
                    child: Text('Return Stock'),
                    value: 1,
                  ),
                  // PopupMenuItem(
                  //   child: Text('Return Crates'),
                  //   value: 2,
                  // )
                ],
              ),
            ),
        viewModelBuilder: () => TransactionPopupViewModel(onSelected));
  }
}
