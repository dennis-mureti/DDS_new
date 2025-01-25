import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          _buildSelectProductSection(model, context),
          const SizedBox(height: 16),
          if (model.selectedProducts.isNotEmpty) _buildAddedProductsList(model),
          const SizedBox(height: 16),
          // _buildTextField(
          //   label: 'Share of Shelf',
          //   hintText: 'Enter percentage',
          //   onChanged: model.isCheckedIn ? model.setShareOfShelf : null,
          //   icon: Icons.percent_outlined,
          // ),
          _buildTextField(
            label: 'Share of Shelf',
            hintText: 'Enter percentage (0-100)',
            onChanged: model.isCheckedIn ? model.setShareOfShelf : null,
            keyboardType: TextInputType.number,
            icon: Icons.percent_outlined,
            enabled: model.isCheckedIn,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              FilteringTextInputFormatter.deny(RegExp(r'^100\.?0*[^%]')),
            ],
            validator: (value) {
              final doubleValue = double.tryParse(value ?? '') ?? 0;
              if (doubleValue < 0 || doubleValue > 100) {
                return 'Please enter a value between 0 and 100.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          ..._buildDropdownSections(model),
          if (model.priceCompliance == 'No') const SizedBox(height: 16),
          if (model.priceCompliance == 'No')
            _buildTextField(
              label: 'Retail Price',
              onChanged: model.isCheckedIn ? model.setRetailPrice : null,
              icon: Icons.price_change_outlined,
            ),
          const SizedBox(height: 20),
          _buildTakePhotoButton(context, model),
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
        model.shelfAvailability == null;
    // model.shelfPhotoUrl != null;

    // debugPrint('Shelf Photo URL: ${model.shelfPhotoUrl}');

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

  // Widget _buildSelectProductSection(CheckInViewModel model) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       Expanded(
  //         child: _buildDropdown(
  //           label: 'Select Product',
  //           value: model.selectedProduct?.itemName,
  //           items: model.listOfProducts
  //               .map((product) => product.itemName)
  //               .toList(),
  //           onChanged: model.isCheckedIn
  //               ? (value) => model.setSelectedSku(
  //                     model.listOfProducts
  //                         .firstWhere((product) => product.itemName == value),
  //                   )
  //               : null,
  //           icon: Icons.line_style_rounded,
  //         ),
  //       ),
  //       const SizedBox(width: 10),
  //       IconButton(
  //         icon: const Icon(Icons.add_circle_outline_outlined),
  //         onPressed: model.isCheckedIn ? model.addProductToList : null,
  //       ),
  //     ],
  //   );
  // }

  Widget _buildSelectProductSection(
      CheckInViewModel model, BuildContext context) {
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
                ? (value) {
                    // Check if the product is already added to the list
                    if (model.selectedProducts
                        .any((product) => product.itemName == value)) {
                      // Show a SnackBar if the product is already added to the list
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Product "$value" is already added.'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    } else {
                      // Add product to the selection if it's not already added
                      model.setSelectedSku(
                        model.listOfProducts.firstWhere(
                          (product) => product.itemName == value,
                        ),
                      );
                    }
                  }
                : null,
            icon: Icons.line_style_rounded,
          ),
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: const Icon(Icons.add_circle_outline_outlined),
          onPressed: model.isCheckedIn
              ? () {
                  // Ensure that the product is not already in the selected list before adding it
                  if (model.selectedProducts.any((product) =>
                      product.itemName == model.selectedProduct?.itemName)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Product "${model.selectedProduct?.itemName}" is already added.'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } else {
                    // Add the product to the list
                    model.addProductToList();
                  }
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildAddedProductsList(CheckInViewModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Headers for the columns
        Row(
          children: [
            Expanded(
              flex: 3,
              child: const Text(
                'Product',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 2,
              child: const Text(
                'Shelf Availability',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),

            const Icon(
              Icons.delete,
              color: Colors.transparent,
            ), // Placeholder to align with remove button
          ],
        ),
        const SizedBox(height: 8),
        // The existing ListView
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: model.selectedProducts.length,
          itemBuilder: (context, index) {
            final product = model.selectedProducts[index];
            // final priceCompliance = model.getPriceCompliance(product.id);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Flexible(
                    flex: 3,
                    child: Text(
                      product.itemName,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    flex: 2,
                    child: Container(
                      width: double.infinity,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (availability) {
                          model.setShelfAvailabilityForProductById(
                              product.id, availability);
                        },
                        decoration: InputDecoration(
                          hintText: 'Levels',
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: model.isCheckedIn
                        ? () {
                            model.removeProductFromList(product);
                          }
                        : null,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // Widget _buildAddedProductsList(CheckInViewModel model) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       _buildProductsHeader(),
  //       ListView.builder(
  //         shrinkWrap: true,
  //         physics: const NeverScrollableScrollPhysics(),
  //         itemCount: model.selectedProducts.length,
  //         itemBuilder: (context, index) {
  //           final product = model.selectedProducts[index];
  //           return _buildProductItem(context, model, product);
  //         },
  //       ),
  //     ],
  //   );
  // }

  // Padding _buildProductsHeader() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 8.0),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: const [
  //         Expanded(
  //           child: Text(
  //             'Product Name',
  //             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
  //           ),
  //         ),
  //         SizedBox(width: 5),
  //         Expanded(
  //           child: Text(
  //             'Shelf Availability',
  //             textAlign: TextAlign.start,
  //             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
  //           ),
  //         ),
  //         // SizedBox(width: 5),
  //         // Expanded(
  //         //   child: Text(
  //         //     'Brand Availability',
  //         //     textAlign: TextAlign.center,
  //         //     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
  //         //   ),
  //         // ),
  //       ],
  //     ),
  //   );
  // }

  Padding _buildProductItem(
      BuildContext context, CheckInViewModel model, dynamic product) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(product.itemName),
          ),

          Flexible(
            flex: 2,
            child: Container(
              width: double.infinity,
              child: TextField(
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly
                ], // Only allow digits
                // onChanged: (availability) {
                //   // Passing the availability value as a string
                //   model.setShelfAvailability(availability);
                // },
                onChanged: (availability) {
                  model.setShelfAvailabilityForProductById(
                      product.id, availability);
                },
                decoration: InputDecoration(
                  hintText: 'Levels',
                  filled: true,
                  fillColor: Colors.grey.shade300,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          // SizedBox(width: 5),
          // Expanded(
          //   child: _buildBrandAvailabilityDropdown(
          //     isEnabled: model.isCheckedIn,
          //     onChanged: model.setBrandAvailability,
          //   ),
          // ),

          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: model.isCheckedIn
                ? () {
                    model.removeProductFromList(product);
                  }
                : null,
          ),
        ],
      ),
    );
  }

  // List<Widget> _buildDropdownSections(CheckInViewModel model) {
  //   return [
  //     _buildTextField(
  //         label: 'Marketing Request',
  //         hintText: 'Enter Details on Marketing request',
  //         onChanged: model.isCheckedIn ? model.setMarketingRequest : null,
  //         icon: Icons.shuffle_on_outlined,
  //         keyboardType: TextInputType.text),
  //     const SizedBox(height: 16),
  //     _buildTextField(
  //         label: 'Branding Request',
  //         hintText: 'Enter Details on Branding request',
  //         onChanged: model.isCheckedIn ? model.setBrandingRequest : null,
  //         icon: Icons.request_page,
  //         keyboardType: TextInputType.text),
  //     const SizedBox(height: 16),
  //     _buildTextField(
  //         label: 'Activations',
  //         hintText: 'Enter Details on Activations',
  //         onChanged: model.isCheckedIn ? model.setActivations : null,
  //         icon: Icons.local_activity_outlined,
  //         keyboardType: TextInputType.text),
  //     const SizedBox(height: 16),
  //     _buildTextField(
  //       label: 'Feedback',
  //       hintText: 'Enter feedback here',
  //       onChanged: model.isCheckedIn ? model.setGeneralFeedback : null,
  //       icon: Icons.feed_rounded,
  //       maxLines: 3,
  //     ),
  //     const SizedBox(height: 16),
  //     _buildBrandAvailabilityCheckboxes(model),
  //     // _buildBrandAvailabilityDropdown(model),
  //     // // _buildTextField(
  //     // //   label: 'Brand Availability',
  //     // //   hintText: 'Enter Details on Brand Availability',
  //     // //   onChanged: model.isCheckedIn ? model.setShelfAvailability : null,
  //     // //   icon: Icons.branding_watermark_outlined,
  //     // // ),
  //     // const SizedBox(height: 16),
  //   ];
  // }

  List<Widget> _buildDropdownSections(CheckInViewModel model) {
    return [
      _buildTextField(
          label: 'Marketing Request',
          hintText: 'Enter Details on Marketing request',
          onChanged: model.isCheckedIn ? model.setMarketingRequest : null,
          icon: Icons.shuffle_on_outlined,
          keyboardType: TextInputType.text,
          enabled: model.isCheckedIn),
      const SizedBox(height: 16),
      _buildTextField(
        label: 'Branding Request',
        hintText: 'Enter Details on Branding request',
        onChanged: model.isCheckedIn ? model.setBrandingRequest : null,
        icon: Icons.request_page,
        keyboardType: TextInputType.text,
        enabled: model.isCheckedIn,
      ),
      const SizedBox(height: 16),
      _buildTextField(
          label: 'Activations',
          hintText: 'Enter Details on Activations',
          onChanged: model.isCheckedIn ? model.setActivations : null,
          icon: Icons.local_activity_outlined,
          keyboardType: TextInputType.text,
          enabled: model.isCheckedIn),
      const SizedBox(height: 16),
      _buildTextField(
        label: 'Feedback',
        hintText: 'Enter feedback here',
        onChanged: model.isCheckedIn ? model.setGeneralFeedback : null,
        icon: Icons.feed_rounded,
        maxLines: 3,
        enabled: model.isCheckedIn,
      ),
      const SizedBox(height: 16),
      _buildBrandAvailabilityCheckboxes(model),
      // _buildBrandAvailabilityDropdown(model),
      // // _buildTextField(
      // //   label: 'Brand Availability',
      // //   hintText: 'Enter Details on Brand Availability',
      // //   onChanged: model.isCheckedIn ? model.setShelfAvailability : null,
      // //   icon: Icons.branding_watermark_outlined,
      // // ),
      // const SizedBox(height: 16),
    ];
  }

  // Widget _buildBrandAvailabilityDropdown(CheckInViewModel model) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text(
  //         'Brand Availability',
  //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //       ),
  //       const SizedBox(height: 8),
  //       DropdownButtonFormField<String>(
  //         value: model
  //             .brandAvailability, // Assuming model.shelfAvailability holds this value
  //         onChanged: model.isCheckedIn ? model.setBrandAvailability : null,
  //         items: const ['Super Loaf', 'Butter Toast', 'Super Nutri']
  //             .map((String item) =>
  //                 DropdownMenuItem<String>(value: item, child: Text(item)))
  //             .toList(),
  //         decoration: _dropdownDecoration(),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildTextField({
  //   String label,
  //   String hintText,
  //   ValueChanged<String> onChanged,
  //   int maxLines = 1,
  //   IconData icon,
  // }) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(label,
  //           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
  //       const SizedBox(height: 8),
  //       TextField(
  //         onChanged: onChanged,
  //         maxLines: maxLines,
  //         decoration: InputDecoration(
  //           hintText: hintText,
  //           filled: true,
  //           fillColor: Colors.grey.shade300,
  //           prefixIcon: Icon(icon),
  //           border: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(8),
  //             borderSide: BorderSide.none,
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildTextField({
  //   String label,
  //   String hintText,
  //   Function(String) onChanged,
  //   IconData icon,
  //   int maxLines = 1,
  //   List<TextInputFormatter>
  //       inputFormatters, // Added parameter for input formatters
  //   String Function(String) validator, // Added parameter for validation
  // }) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(label,
  //           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
  //       const SizedBox(height: 8),
  //       TextFormField(
  //         onChanged: onChanged,
  //         maxLines: maxLines,
  //         inputFormatters: inputFormatters,
  //         validator: validator,
  //         decoration: InputDecoration(
  //           hintText: hintText,
  //           filled: true,
  //           fillColor: Colors.grey.shade300,
  //           prefixIcon: Icon(icon),
  //           border: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(8),
  //             borderSide: BorderSide.none,
  //           ),
  //         ),
  //         keyboardType: TextInputType.numberWithOptions(
  //             decimal: true), // Restrict to number input
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildTextField({
  //   String label,
  //   String hintText,
  //   ValueChanged<String> onChanged,
  //   IconData icon,
  //   int maxLines = 1,
  //   List<TextInputFormatter> inputFormatters,
  //   String Function(String) validator,
  //   TextInputType keyboardType =
  //       TextInputType.text, // Customizable keyboard type
  // }) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         label,
  //         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //       ),
  //       const SizedBox(height: 8),
  //       TextFormField(
  //         onChanged: onChanged,
  //         maxLines: maxLines,
  //         inputFormatters: inputFormatters,
  //         validator: validator,
  //         keyboardType: keyboardType,
  //         decoration: InputDecoration(
  //           hintText: hintText,
  //           filled: true,
  //           fillColor: Colors.grey.shade300,
  //           prefixIcon: icon != null ? Icon(icon) : null,
  //           border: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(8),
  //             borderSide: BorderSide.none,
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildTextField({
    String label,
    String hintText,
    ValueChanged<String> onChanged,
    IconData icon,
    int maxLines = 1,
    List<TextInputFormatter> inputFormatters,
    String Function(String) validator,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true, // New parameter for enabling/disabling the field
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Opacity(
          opacity: enabled
              ? 1.0
              : 0.5, // Adjust opacity based on whether it's enabled
          child: AbsorbPointer(
            absorbing: !enabled, // Prevent user interaction when disabled
            child: TextFormField(
              onChanged: onChanged,
              maxLines: maxLines,
              inputFormatters: inputFormatters,
              validator: validator,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hintText,
                filled: true,
                fillColor: Colors.grey.shade300,
                prefixIcon: icon != null ? Icon(icon) : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
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

  Widget _buildShelfAvailabilityDropdown({
    bool isEnabled,
    void Function(String) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      onChanged: isEnabled ? onChanged : null,
      items: const ['Yes', 'No']
          .map((String item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              ))
          .toList(),
      decoration: _dropdownDecoration(),
    );
  }

  // Widget _buildBrandAvailabilityDropdown({
  //   bool isEnabled,
  //   void Function(String) onChanged,
  // }) {
  //   return DropdownButtonFormField<String>(
  //     onChanged: isEnabled ? onChanged : null,
  //     items: const ['Available', 'Not Available', 'Out of Stock']
  //         .map((String item) => DropdownMenuItem<String>(
  //               value: item,
  //               child: Text(
  //                 item,
  //                 overflow: TextOverflow.clip, // Avoid text overflow
  //                 maxLines: 1, // Limit to a single line
  //                 style:
  //                     TextStyle(fontSize: 14), // Adjust font size if necessary
  //               ),
  //             ))
  //         .toList(),
  //     decoration: _dropdownDecoration(),
  //   );
  // }

  // Widget _buildBrandAvailabilityDropdown({
  //   bool isEnabled,
  //   void Function(String) onChanged,
  // }) {
  //   return DropdownButtonFormField<String>(
  //     onChanged: isEnabled ? onChanged : null,
  //     items: const [
  //       'Supa Loaf',
  //       'Butter Toast',
  //       'Supa Nutri',
  //       'Supa Tam',
  //     ]
  //         .map((String item) => DropdownMenuItem<String>(
  //               value: item,
  //               child: Container(
  //                 width: double.infinity, // Ensures full-width for the dropdown
  //                 child: Text(
  //                   item,
  //                   overflow: TextOverflow.ellipsis, // Avoid text overflow
  //                   maxLines: 1, // Limit text to one line
  //                 ),
  //               ),
  //             ))
  //         .toList(),
  //     decoration: _dropdownDecoration(),
  //     isExpanded: true, // Ensures the dropdown expands to fill available space
  //   );
  // }

  Widget _buildBrandAvailabilityCheckboxes(CheckInViewModel model) {
    final List<String> brandOptions = [
      'Supa Loaf',
      'Butter Toast',
      'Supa Nutri',
      'Supa Tam',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Brand Availability',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        ...brandOptions.map((brand) {
          return CheckboxListTile(
            title: Text(brand),
            value: model.selectedBrands.contains(brand),
            onChanged: model.isCheckedIn
                ? (bool isChecked) {
                    if (isChecked == true) {
                      model.addBrand(brand);
                    } else {
                      model.removeBrand(
                          brand); // Remove brand from the selection
                    }
                    // Update brand availability after each change
                    model.setBrandAvailability(model.selectedBrands.join(', '));
                  }
                : null, // Disable if `isCheckedIn` is false
          );
        }).toList(),
      ],
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade300,
      // prefixIcon: Icon(Icons.line_style_rounded),
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

  // Widget _buildCheckInDetails(CheckInViewModel model) {
  //   // Get the persisted check-in time (if any)
  //   Future<DateTime> storedCheckInTime = model.getCheckInTime();

  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 20.0),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         FutureBuilder<DateTime>(
  //           future: storedCheckInTime,
  //           builder: (context, snapshot) {
  //             if (snapshot.hasData) {
  //               return _buildDetailColumn(
  //                 'Check In Time',
  //                 DateFormat('hh:mm a').format(snapshot.data),
  //               );
  //             } else {
  //               return _buildDetailColumn('Check In', 'Start');
  //             }
  //           },
  //         ),
  //         _buildDetailColumn('Duration', model.duration),
  //       ],
  //     ),
  //   );
  // }
  Widget _buildCheckInDetails(CheckInViewModel model) {
    // Get the persisted check-in time (if any)
    Future<DateTime> storedCheckInTime = model.getCheckInTime();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FutureBuilder<DateTime>(
            future: storedCheckInTime,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // Calculate the duration only if checkInTime is available
                Duration duration = DateTime.now().difference(snapshot.data);

                String formattedDuration = _formatDuration(duration);

                return _buildDetailColumn(
                  'Check In Time',
                  DateFormat('hh:mm a').format(snapshot.data),
                );
              } else {
                return _buildDetailColumn('Check In', 'Start');
              }
            },
          ),
          FutureBuilder<DateTime>(
            future: storedCheckInTime,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // Calculate the duration only if checkInTime is available
                Duration duration = DateTime.now().difference(snapshot.data);

                String formattedDuration = _formatDuration(duration);

                return _buildDetailColumn(
                  'Duration',
                  formattedDuration,
                );
              } else {
                return _buildDetailColumn('Duration', 'N/A');
              }
            },
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    // Format the duration as hours and minutes
    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;
    return '$hours hours $minutes minutes';
  }

  // Widget _buildCheckInDetails(CheckInViewModel model) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 20.0),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         _buildDetailColumn(
  //             'Check In',
  //             model.isCheckedIn
  //                 ? 'Check-In in Progress'
  //                 : (model.checkInTime != null
  //                     ? DateFormat('hh:mm a').format(model.checkInTime)
  //                     : 'Start')),
  //         _buildDetailColumn(
  //           'Duration',
  //           model.isCheckedIn
  //               ? 'Check-In in Progress'
  //               : model.duration ?? '0 min',
  //         ),
  //       ],
  //     ),
  //   );
  // }

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

  // Widget _buildTakePhotoButton(BuildContext context, CheckInViewModel model) {
  //   return ElevatedButton(
  //     onPressed: () async {
  //       final PickedFile photo =
  //           await _picker.getImage(source: ImageSource.camera);
  //       if (photo != null) {
  //         // Update the photo path when a photo is taken
  //         _photoPath = photo.path;
  //         // Refresh the UI to show the photo
  //         (context as Element).reassemble();
  //       } else {
  //         // Handle case where the user cancels the photo
  //         print('No photo taken');
  //       }
  //     },
  //     style: ElevatedButton.styleFrom(
  //       padding: const EdgeInsets.symmetric(vertical: 15.0),
  //       primary: Colors.blue,
  //       minimumSize: const Size(double.infinity, 50),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(10.0),
  //       ),
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: const [
  //         Icon(Icons.camera, color: Colors.white),
  //         SizedBox(width: 10),
  //         Text('Take Photo',
  //             style:
  //                 TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildTakePhotoButton(BuildContext context, CheckInViewModel model) {
    return ElevatedButton(
      onPressed: model.isCheckedIn
          ? () async {
              final PickedFile photo =
                  await _picker.getImage(source: ImageSource.camera);
              if (photo != null) {
                // Update the photo path when a photo is taken
                _photoPath = photo.path;
                // File filemain = File(photo.path);
                // model
                //     .updateShelfPhotoUrl(filemain)
                // Refresh the UI to show the photo
                (context as Element).reassemble();
              } else {
                // Handle case where the user cancels the photo
                print('No photo taken');
              }
            }
          : null, // Disable the button if not checked in
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        primary: model.isCheckedIn
            ? Colors.blue
            : Colors.grey, // Change color when disabled
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
