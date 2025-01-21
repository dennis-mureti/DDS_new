import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stacked/stacked.dart';
import 'package:intl/intl.dart';
import 'package:distributor/ui/views/crm/checkin/checkin_view_model.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';
import 'package:distributor/conf/dds_brand_guide.dart';

class CheckInView extends StatelessWidget {
  final int visitId;
  final String customerName;
  final ImagePicker _picker = ImagePicker();

  String _photoPath;

  CheckInView({
    Key key,
    this.visitId,
    this.customerName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CheckInViewModel>.reactive(
      onModelReady: (model) async {
        model.setBusy(true);
        await model.fetchCheckInState();
        await model.fetchProducts();
        model.setBusy(false);
      },
      builder: (context, model, child) {
        return Scaffold(
          appBar: _buildAppBar(),
          body: model.isBusy
              ? const Center(child: BusyWidget())
              : _buildBody(context, model),
        );
      },
      viewModelBuilder: () => CheckInViewModel(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Check-In', style: TextStyle(fontSize: 20)),
      backgroundColor: kColDDSPrimaryDark,
      elevation: 0,
    );
  }

  Widget _buildBody(BuildContext context, CheckInViewModel model) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCheckInDetails(model),
          const SizedBox(height: 16),
          _buildCheckInButton(context, model),
          const SizedBox(height: 16),
          if (customerName.isNotEmpty) _buildCustomerName(),
          _buildSelectProductSection(model),
          const SizedBox(height: 16),
          if (model.selectedProducts.isNotEmpty) _buildAddedProductsList(model),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Share of Shelf',
            hintText: 'Enter percentage or description',
            onChanged: model.isCheckedIn ? model.setShareOfShelf : null,
            icon: Icons.percent_outlined,
          ),
          const SizedBox(height: 16),
          ..._buildDropdownSections(model),
          if (model.priceCompliance == 'No') const SizedBox(height: 16),
          if (model.priceCompliance == 'No')
            _buildTextField(
              label: 'Retail Price',
              hintText: 'Enter retail price',
              onChanged: model.isCheckedIn ? model.setRetailPrice : null,
              icon: Icons.price_change_outlined,
            ),
          const SizedBox(height: 20),
          _buildTakePhotoButton(context),
          if (_photoPath != null) ...[
            Image.file(
              File(_photoPath),
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 10),
            Text('Photo path: $_photoPath'),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCheckInButton(BuildContext context, CheckInViewModel model) {
    // Ensure the shelfPhotoUrl is not null and update the validation logic
    final isCheckoutFormValid = model.isCheckedIn &&
        (model.selectedProducts?.isNotEmpty ?? false) &&
        model.selectedProduct != null &&
        (model.shareOfShelf?.isNotEmpty ?? false) &&
        model.shelfAvailability != null;
    // model.shelfPhotoUrl != null; // Check if photo exists

    // Debug print to check the value of shelfPhotoUrl
    debugPrint('Shelf Photo URL: ${model.shelfPhotoUrl}');

    return ElevatedButton.icon(
      onPressed: model.isCheckedIn
          ? (isCheckoutFormValid
              ? () {
                  model.toggleCheckin(context, visitId);
                }
              : () {
                  // Show validation error if the form is not valid
                  _showValidationError(context);
                })
          : () {
              model.toggleCheckin(context, visitId);
            },
      icon: Icon(
        model.isCheckedIn ? Icons.logout : Icons.login,
        color: Colors.black,
      ),
      label: Text(
        model.isCheckedIn ? 'Check Out' : 'Check In',
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        primary: model.isCheckedIn ? Colors.red : Colors.green,
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  // Widget _buildCheckInButton(BuildContext context, CheckInViewModel model) {
  //   final isCheckoutFormValid = model.isCheckedIn &&
  //       (model.selectedProducts?.isNotEmpty ?? false) &&
  //       model.selectedProduct != null &&
  //       (model.shareOfShelf?.isNotEmpty ?? false) &&
  //       model.shelfAvailability != null;

  //   return ElevatedButton.icon(
  //     onPressed: model.isCheckedIn
  //         ? (isCheckoutFormValid
  //             ? () {
  //                 model.toggleCheckin(context, visitId);
  //                 model.checkOutTime = DateTime.now(); // Update check-out time
  //               }
  //             : () => _showValidationError(context))
  //         : () => model.toggleCheckin(context, visitId),
  //     icon: Icon(
  //       model.isCheckedIn ? Icons.logout : Icons.login,
  //       color: Colors.black,
  //     ),
  //     label: Text(
  //       model.isCheckedIn ? 'Check Out' : 'Check In',
  //       style: const TextStyle(
  //         color: Colors.black,
  //       ),
  //     ),
  //     style: ElevatedButton.styleFrom(
  //       primary: model.isCheckedIn ? Colors.red : Colors.green,
  //       padding: const EdgeInsets.symmetric(vertical: 15.0),
  //       minimumSize: const Size(double.infinity, 50),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(10.0),
  //       ),
  //     ),
  //   );
  // }

  void _showValidationError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Please fill in all required fields to check out.',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildCustomerName() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        '$customerName - MT',
        style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }

  Widget _buildSelectProductSection(CheckInViewModel model) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _buildDropdown(
            label: 'Select Product',
            value: model.selectedProduct?.itemName,
            items: model.listOfProducts
                .map((product) => product.itemName)
                .toList(),
            onChanged: model.isCheckedIn
                ? (value) => model.setSelectedSku(
                      model.listOfProducts
                          .firstWhere((product) => product.itemName == value),
                    )
                : null,
            icon: Icons.line_style_rounded,
          ),
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: const Icon(Icons.add_circle_outline_outlined),
          onPressed: model.isCheckedIn ? model.addProductToList : null,
        ),
      ],
    );
  }

  Widget _buildAddedProductsList(CheckInViewModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProductsHeader(),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: model.selectedProducts.length,
          itemBuilder: (context, index) {
            final product = model.selectedProducts[index];
            return _buildProductItem(context, model, product);
          },
        ),
      ],
    );
  }

  Padding _buildProductsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text('Product Name',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          Text('Shelf Availability',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          SizedBox(width: 20),
        ],
      ),
    );
  }

  Padding _buildProductItem(
      BuildContext context, CheckInViewModel model, dynamic product) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(product.itemName),
          Container(
            width: 120,
            child: DropdownButtonFormField<String>(
              onChanged: model.isCheckedIn ? model.setShelfAvailability : null,
              items: const ['Yes', 'No']
                  .map((String item) =>
                      DropdownMenuItem<String>(value: item, child: Text(item)))
                  .toList(),
              decoration: _dropdownDecoration(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: model.isCheckedIn
                ? () => model.removeProductFromList(product)
                : null,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDropdownSections(CheckInViewModel model) {
    return [
      _buildTextField(
        label: 'Marketing Request',
        hintText: 'Enter Details on Marketing request',
        onChanged: model.isCheckedIn ? model.setMarketingRequest : null,
        icon: Icons.shuffle_on_outlined,
      ),
      const SizedBox(height: 16),
      _buildTextField(
        label: 'Branding Request',
        hintText: 'Enter Details on Branding request',
        onChanged: model.isCheckedIn ? model.setBrandingRequest : null,
        icon: Icons.request_page,
      ),
      const SizedBox(height: 16),
      _buildTextField(
        label: 'Activations',
        hintText: 'Enter Details on Activations',
        onChanged: model.isCheckedIn ? model.setActivations : null,
        icon: Icons.local_activity_outlined,
      ),
      const SizedBox(height: 16),
      _buildBrandAvailabilityDropdown(model),
      // _buildTextField(
      //   label: 'Brand Availability',
      //   hintText: 'Enter Details on Brand Availability',
      //   onChanged: model.isCheckedIn ? model.setShelfAvailability : null,
      //   icon: Icons.branding_watermark_outlined,
      // ),
      const SizedBox(height: 16),
    ];
  }

  Widget _buildBrandAvailabilityDropdown(CheckInViewModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Brand Availability',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: model
              .brandAvailability, // Assuming model.shelfAvailability holds this value
          onChanged: model.isCheckedIn ? model.setBrandAvailability : null,
          items: const ['Super Loaf', 'Butter Toast', 'Super Nutri']
              .map((String item) =>
                  DropdownMenuItem<String>(value: item, child: Text(item)))
              .toList(),
          decoration: _dropdownDecoration(),
        ),
      ],
    );
  }

  Widget _buildTextField({
    String label,
    String hintText,
    ValueChanged<String> onChanged,
    int maxLines = 1,
    IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          onChanged: onChanged,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.grey.shade300,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    String label,
    String value,
    List<String> items,
    ValueChanged<String> onChanged,
    IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          isExpanded: true,
          items: items
              .map((String item) =>
                  DropdownMenuItem<String>(value: item, child: Text(item)))
              .toList(),
          decoration: _dropdownDecoration(),
        ),
      ],
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade300,
      prefixIcon: Icon(Icons.line_style_rounded),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }

  // Widget _buildCheckInDetails(CheckInViewModel model) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 20.0),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         _buildDetailColumn(
  //             'Check In',
  //             model.isCheckedIn && model.checkInTime != null
  //                 ? DateFormat('hh:mm a').format(model.checkInTime)
  //                 : 'Start'),
  //         _buildDetailColumn('Duration', model.duration),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildCheckInDetails(CheckInViewModel model) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildDetailColumn(
              'Check In',
              model.isCheckedIn
                  ? 'Check-In in Progress'
                  : (model.checkInTime != null
                      ? DateFormat('hh:mm a').format(model.checkInTime)
                      : 'Start')),
          _buildDetailColumn(
            'Duration',
            model.isCheckedIn
                ? 'Check-In in Progress'
                : model.duration ?? '0 min',
          ),
        ],
      ),
    );
  }

  Column _buildDetailColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black, fontSize: 16)),
        const SizedBox(height: 5),
        Text(value,
            style: const TextStyle(
                color: Colors.grey, fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTakePhotoButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final PickedFile photo =
            await _picker.getImage(source: ImageSource.camera);
        if (photo != null) {
          // Update the photo path when a photo is taken
          _photoPath = photo.path;
          // Refresh the UI to show the photo
          (context as Element).reassemble();
        } else {
          // Handle case where the user cancels the photo
          print('No photo taken');
        }
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        primary: Colors.blue,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.camera, color: Colors.white),
          SizedBox(width: 10),
          Text('Take Photo',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
