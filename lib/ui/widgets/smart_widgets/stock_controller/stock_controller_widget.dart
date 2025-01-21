import 'package:distributor/src/strings.dart';
import 'package:distributor/ui/widgets/dumb_widgets/empty_content_container.dart';
import 'package:distributor/ui/widgets/smart_widgets/stock_controller/stock_controller_widget_viewmodel.dart';
import 'package:distributor/ui/widgets/smart_widgets/stock_list_widget/stock_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class StockControllerWidget extends StatelessWidget {
  final bool rebuildWidgetTree;

  const StockControllerWidget({Key key, this.rebuildWidgetTree = false})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<StockControllerWidgetViewModel>.reactive(
        builder: (context, model, child) => model.hasJourneys == false
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: EmptyContentContainer(label: kStringNoJourney),
                ),
              )
            : model.hasSelectedJourney == true
                ? StockListWidget(
                    rebuild: rebuildWidgetTree,
                  )
                : const Center(
                    child:
                        EmptyContentContainer(label: kStringNoJourneySelected)),
        viewModelBuilder: () => StockControllerWidgetViewModel());
  }

  _buildCenterContainer(String text) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Center(
          child: (Text(text)),
        ),
      ],
    );
  }
}
