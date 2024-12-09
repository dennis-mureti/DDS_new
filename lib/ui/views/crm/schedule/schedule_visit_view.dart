import 'package:distributor/conf/dds_brand_guide.dart';
import 'package:distributor/ui/views/crm/schedule/schedule_visit_view_model.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:intl/intl.dart';
import 'package:tripletriocore/tripletriocore.dart';

class VisitView extends StatelessWidget {
  final List<Customer> customer;

  const VisitView({this.customer, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ScheduleVisitViewModel>.reactive(
      onModelReady: (model) async {
        // await model.init();
        print('Customers: ${model.listOfCustomers}');
        print('Customers2: ${model.customerList}');
      },
      builder: (context, model, child) {
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Schedule Visit',
              style: TextStyle(fontSize: 20),
            ),
            backgroundColor: kColDDSPrimaryDark,
            elevation: 0,
          ),
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Main content of the page
              Container(
                width: double.infinity,
                height: screenHeight,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kColDDSPrimaryDark, Color(0xFF4B6CB7)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // User Details Section
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                        vertical: 10.0,
                      ),
                      child: _buildUserDetail(model),
                    ),
                    // Dropdowns and Confirmation Button
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20.0),
                            topLeft: Radius.circular(20.0),
                          ),
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Customer Dropdown
                              _buildDropdown(
                                context,
                                label: 'Select Customer',
                                value: model.selectedCustomer?.name,
                                items: model.listOfCustomers
                                    .map((customer) => customer.name)
                                    .toList(),
                                // items: model.customerNames,
                                onChanged: (value) => model.setSelectedCustomer(
                                    model.customerList.firstWhere(
                                        (customer) => customer.name == value)),
                                icon: Icons.group,
                              ),
                              const SizedBox(height: 20),

                              // Sales Rep Dropdown
                              // _buildDropdown(
                              //   context,
                              //   label: 'Select Sales Rep',
                              //   value: model.selectedSalesRep,
                              //   items: model.salesReps,
                              //   onChanged: (value) => model.setSelectedSalesRep(value),
                              //   // onChanged: model.setSelectedSalesRep,
                              //   icon: Icons.group,
                              // ),
                              // const SizedBox(height: 20),

                              // Reason for Visit Dropdown
                              _buildDropdown(
                                context,
                                label: 'Reason for Visit',
                                value: model.selectedReason,
                                items: model.visitReasons,
                                onChanged: model.setSelectedReason,
                                icon: Icons.format_align_center_outlined,
                              ),
                              const SizedBox(height: 20),

                              // Date and Time Row
                              Row(
                                children: [
                                  // Date Picker Button
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          _selectDate(context, model),
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.grey.shade300,
                                        onPrimary: Colors
                                            .black, // Set text color to white
                                        side: BorderSide(
                                            color: Colors.grey.shade300,
                                            width: 1),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12.0, horizontal: 16.0),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            model.selectedDate != null
                                                ? DateFormat('yyyy-MM-dd')
                                                    .format(model.selectedDate)
                                                : 'Start date',
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                          const Icon(Icons.calendar_today,
                                              size:
                                                  18), // Icon on the right side
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          _selectDate(context, model),
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.grey.shade300,
                                        onPrimary: Colors
                                            .black, // Set text color to white
                                        side: BorderSide(
                                            color: Colors.grey.shade300,
                                            width: 1),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12.0, horizontal: 16.0),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            model.selectedDate != null
                                                ? DateFormat('yyyy-MM-dd')
                                                    .format(model.selectedDate)
                                                : 'End date',
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                          const Icon(Icons.calendar_today,
                                              size:
                                                  18), // Icon on the right side
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Time Picker Button
                                  // Expanded(
                                  //   child: ElevatedButton(
                                  //     onPressed: () =>
                                  //         _selectTime(context, model),
                                  //     style: ElevatedButton.styleFrom(
                                  //       primary: Colors.grey
                                  //           .shade300, // Set background color to red
                                  //       onPrimary: Colors
                                  //           .black, // Set text color to white
                                  //       side: BorderSide(
                                  //           color: Colors.grey.shade300,
                                  //           width: 1),
                                  //       shape: RoundedRectangleBorder(
                                  //           borderRadius:
                                  //               BorderRadius.circular(10)),
                                  //       padding: const EdgeInsets.symmetric(
                                  //           vertical: 12.0, horizontal: 16.0),
                                  //     ),
                                  //     child: Row(
                                  //       mainAxisAlignment:
                                  //           MainAxisAlignment.spaceBetween,
                                  //       children: [
                                  //         Text(
                                  //           model.selectedTime != null
                                  //               ? model.selectedTime
                                  //                   .format(context)
                                  //               : 'Set time',
                                  //           style:
                                  //               const TextStyle(fontSize: 16),
                                  //         ),
                                  //         const Icon(Icons.access_time,
                                  //             size:
                                  //                 18), // Icon on the right side
                                  //       ],
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                              const Spacer(),

                              // Confirm Button
                              Center(
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      // Use the ViewModel to handle the visit confirmation
                                      await model.confirmVisit(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.blue.shade900,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    child: const Text(
                                      'Confirm Visit',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Overlay BusyWidget when loading
              if (model.isBusy)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(child: BusyWidget()),
                ),
            ],
          ),
        );
      },
      viewModelBuilder: () => ScheduleVisitViewModel(),
    );
  }

  Widget _buildDropdown(
    BuildContext context, {
    String label,
    String value,
    List<String> items,
    Function(String) onChanged,
    IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            isExpanded: true, // Ensures the dropdown takes up full width
            items: items
                .map((item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        overflow: TextOverflow.ellipsis, // Truncates long text
                        maxLines: 1, // Ensures text stays on a single line
                      ),
                    ))
                .toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              prefixIcon: Icon(icon),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
            ),
            dropdownColor: Colors.grey.shade200,
          ),
        ),
      ],
    );
  }

  Widget _buildUserDetail(ScheduleVisitViewModel model) {
    final String todayDate =
        DateFormat('EEEE, MMM dd, yyyy').format(DateTime.now());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          todayDate,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Welcome',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(
      BuildContext context, ScheduleVisitViewModel model) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: model.selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != model.selectedDate) {
      model.setSelectedDate(picked);
    }
  }

  Future<void> _selectTime(
      BuildContext context, ScheduleVisitViewModel model) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: model.selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != model.selectedTime) {
      model.setSelectedTime(picked);
    }
  }
}
