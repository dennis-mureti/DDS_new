import 'package:distributor/ui/views/journey/journey_view.dart';
import 'package:distributor/ui/views/journey/journey_view_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class JourneyListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<JourneyViewModel>.reactive(
        builder: (context, model, child) => model.isBusy
            ? CircularProgressIndicator()
            : Expanded(
                child: ListView.builder(
                  itemCount: model.userJourneyList.length,
                  itemBuilder: (context, index) =>
                      DeliveryJourneyExpansionPanel(
                    deliveryJourney: model.userJourneyList[index],
                  ),
                ),
              ),
        viewModelBuilder: () => JourneyViewModel());
  }
}
