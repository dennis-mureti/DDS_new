import 'package:distributor/conf/dds_brand_guide.dart';
import 'package:distributor/ui/views/crm/outofRoute/out_of_request_view_model.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class OutOfRouteView extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  OutOfRouteView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<OutOfRouteViewModel>.reactive(
      onModelReady: (model) async {
        model.setBusy(true);
        await model.fetchCustomers();
        model.setBusy(false);
      },
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Out of Route',
              style: TextStyle(fontSize: 20),
            ),
            backgroundColor: kColDDSPrimaryDark,
            elevation: 0,
          ),
          body: model.isBusy
              ? Center(child: BusyWidget())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SearchableDropdown(
                          label: 'Customer Name',
                          icon: Icons.person,
                          items: model.listOfCustomers
                              .map((customer) => customer.name)
                              .toList(),
                          controller: model.customerNameController,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please select a customer'
                              : null,
                        ),
                        const SizedBox(height: 20),
                        _buildDatePickerField(
                          label: 'Planned Visit Date',
                          icon: Icons.calendar_today,
                          controller: model.requestedDateController,
                          context: context,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please select a date'
                              : null,
                        ),
                        const SizedBox(height: 20),
                        _buildTimePickerField(
                          label: 'Planned Visit Time',
                          icon: Icons.access_time,
                          controller: model.visitTimeController,
                          context: context,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please select a time'
                              : null,
                        ),
                        const SizedBox(height: 30),
                        _buildReasonField(
                          label: 'Reason for Request',
                          icon: Icons.info_outline,
                          controller: model.reasonController,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please provide a reason'
                              : null,
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: model.isBusy
                              ? null
                              : () {
                                  if (_formKey.currentState.validate()) {
                                    model.handleRequest(context);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            primary: kColDDSPrimaryDark,
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: model.isBusy
                              ? CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.send, color: Colors.white),
                                    SizedBox(width: 10),
                                    Text(
                                      'Request',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                        )
                      ],
                    ),
                  ),
                ),
        );
      },
      viewModelBuilder: () => OutOfRouteViewModel(),
    );
  }

  Widget _buildTimePickerField({
    String label,
    IconData icon,
    TextEditingController controller,
    BuildContext context,
    String Function(String) validator,
  }) {
    return GestureDetector(
      onTap: () async {
        TimeOfDay selectedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (selectedTime != null) {
          controller.text = selectedTime.format(context);
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          decoration: _buildInputDecoration(label, icon),
          validator: validator,
        ),
      ),
    );
  }

  Widget _buildReasonField({
    String label,
    IconData icon,
    TextEditingController controller,
    String Function(String) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: _buildInputDecoration(label, icon),
      validator: validator,
      maxLines: 3,
      keyboardType: TextInputType.text,
    );
  }

  Widget _buildDropdownField({
    String label,
    IconData icon,
    List<String> items,
    TextEditingController controller,
    String Function(String) validator,
  }) {
    return DropdownButtonFormField<String>(
      value: controller.text.isEmpty ? null : controller.text,
      decoration: _buildInputDecoration(label, icon),
      dropdownColor: Colors.grey.shade200,
      isExpanded: true,
      items: items
          .map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ))
          .toList(),
      onChanged: (value) {
        controller.text = value ?? '';
      },
      validator: validator,
    );
  }

  Widget _buildDatePickerField({
    String label,
    IconData icon,
    TextEditingController controller,
    BuildContext context,
    String Function(String) validator,
  }) {
    return GestureDetector(
      onTap: () async {
        DateTime selectedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now(),
        );
        if (selectedDate != null) {
          controller.text = "${selectedDate.toLocal()}".split(' ')[0];
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          decoration: _buildInputDecoration(label, icon),
          validator: validator,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.blue.shade900),
      labelText: label,
      fillColor: Colors.grey.shade300,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
    );
  }
}

class SearchableDropdown extends StatefulWidget {
  final String label;
  final IconData icon;
  final List<String> items;
  final TextEditingController controller;
  final String Function(String) validator;

  const SearchableDropdown({
    Key key,
    this.label,
    this.icon,
    this.items,
    this.controller,
    this.validator,
  }) : super(key: key);

  @override
  _SearchableDropdownState createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  TextEditingController searchController = TextEditingController();
  List<String> filteredItems;

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;
    searchController.addListener(() {
      _filterItems();
    });
  }

  void _filterItems() {
    setState(() {
      filteredItems = widget.items
          .where((item) =>
              item.toLowerCase().contains(searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Show the dropdown inside a modal dialog
        await showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(filteredItems[index]),
                        onTap: () {
                          widget.controller.text = filteredItems[index];
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: widget.controller,
          decoration: _buildInputDecoration(widget.label, widget.icon),
          validator: widget.validator,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.blue.shade900),
      labelText: label,
      fillColor: Colors.grey.shade300,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
    );
  }
}
