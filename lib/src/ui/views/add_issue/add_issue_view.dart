import 'package:distributor/ui/widgets/dumb_widgets/app_bar_column_title.dart';
import 'package:distributor/ui/widgets/dumb_widgets/misc_widgets.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import './add_issue_view_model.dart';
import 'package:tripletriocore/tripletriocore.dart';

class AddIssueView extends StatelessWidget {
  final Customer customer;

  const AddIssueView({Key key, this.customer}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AddIssueViewModel>.reactive(
      viewModelBuilder: () => AddIssueViewModel(customer),
      builder: (
        BuildContext context,
        AddIssueViewModel model,
        Widget child,
      ) {
        return Scaffold(
          appBar: AppBar(
            title: AppBarColumnTitle(
              mainTitle: 'Add Issue',
              subTitle: customer.name,
            ),
          ),
          resizeToAvoidBottomInset: true,
          body: Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView(
              children: [
                DropdownButton(
                    dropdownColor: Colors.white,
                    isExpanded: true,
                    hint: Text('Select an Issue Type'),
                    value: model.issueType,
                    items: model.issues
                        .map(
                          (e) => DropdownMenuItem(
                            child: Text(e),
                            value: e,
                          ),
                        )
                        .toList(),
                    onChanged: (String val) {
                      model.setIssueType(val);
                    }),
                // TextField(
                //   onChanged: model.updateSubject,
                //   decoration: InputDecoration(
                //       hintText: 'Ticket Subject',
                //       labelText: 'Give your issue a subject'),
                // ),
                SizedBox(
                  height: 8,
                ),
                TextField(
                  onChanged: model.updateDesc,
                  keyboardType: TextInputType.multiline,
                  minLines: 3, //Normal textInputField will be displayed
                  maxLines: 5, // when user presses enter it will adapt to it
                  decoration: InputDecoration(
                      hintText: 'Ticket Description',
                      labelText: 'Give us more information about the issue'),
                ),
                const SizedBox(
                  height: 8,
                ),
                const SizedBox(
                  height: 24,
                ),
                model.isBusy
                    ? BusyWidget()
                    : Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            await model.addIssue();
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'ADD ISSUE',
                            style: TextStyle(
                                color: Colors.white, fontFamily: 'NerisBlack'),
                          ),
                        ),
                      )
              ],
            ),
          ),
        );
      },
    );
  }
}
