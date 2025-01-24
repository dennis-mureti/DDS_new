import 'package:distributor/conf/dds_brand_guide.dart';
import 'package:distributor/ui/views/crm/checkin/checkin_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:intl/intl.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';

class GTCheckInView extends StatelessWidget {
  final int visitId;
  final String customerName;

  List<String> selectedProducts = [];
  Map<String, bool> productAvailability =
      {}; // Track availability for each product
  String selectedProduct; //

  GTCheckInView({
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
        final screenHeight = MediaQuery.of(context).size.height;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Check-In',
              style: TextStyle(fontSize: 20),
            ),
            backgroundColor: kColDDSPrimaryDark,
            elevation: 0,
          ),
          body: model.isBusy
              ? Center(child: BusyWidget())
              : Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: screenHeight,
                      padding: const EdgeInsets.all(20.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildCheckInDetails(model),
                            const SizedBox(height: 16),
                            _buildCheckInButton(model, context),
                            const SizedBox(height: 16),
                            if (customerName.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Text(
                                  '$customerName - GT',
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            _buildSelectProductSection(model, context),
                            const SizedBox(height: 16),
                            if (model.selectedProducts.isNotEmpty)
                              _buildAddedProductsList(model),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'Feedback',
                              hintText: 'Enter feedback here',
                              onChanged: model.isCheckedIn
                                  ? model.setGeneralFeedback
                                  : null,
                              icon: Icons.feed_rounded,
                              enabled: model.isCheckedIn,
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),
                            ..._buildDropdownSections(model),
                            // if (model.priceCompliance == 'No')
                            //   const SizedBox(height: 16),
                            // if (model.priceCompliance == 'No')
                            //   _buildTextField(
                            //     label: 'Retail Price',
                            //     hintText: 'Enter retail price',
                            //     onChanged: model.isCheckedIn
                            //         ? model.setRetailPrice
                            //         : null,
                            //     icon: Icons.price_change_outlined,
                            //   ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
      viewModelBuilder: () => CheckInViewModel(),
    );
  }

  Widget _buildCheckInButton(CheckInViewModel model, BuildContext context) {
    final isCheckoutFormValid = model.isCheckedIn &&
        (model.selectedProducts?.isNotEmpty ?? false) &&
        model.selectedProduct != null &&
        (model.generalFeedback?.isNotEmpty ?? false) &&
        model.marketingRequest != null;
    (model.brandAvailability != null || true);

    return ElevatedButton.icon(
      onPressed: model.isCheckedIn
          ? (isCheckoutFormValid
              ? () => model.toggleCheckin(context, visitId)
              : () {
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
                })
          : () => model.toggleCheckin(context, visitId),
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
  //                     model.productList.firstWhere(
  //                       (product) => product.itemName == value,
  //                     ),
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
  //                     model.listOfProducts.firstWhere(
  //                       (product) => product.itemName == value,
  //                     ),
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

  // Widget _buildSelectProductSection(CheckInViewModel model) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       Expanded(
  //         child: _buildDropdown(
  //           label: 'Select Product',
  //           value: model
  //               .selectedProductName, // Bind dropdown to selectedProductName
  //           items: model.gTproducts
  //               .map((product) => product['name']
  //                   as String) // Convert 'name' to a String list
  //               .toList(),
  //           onChanged: model.isCheckedIn
  //               ? (value) {
  //                   // Update the selected product name
  //                   model.setSelectedProductName(value);
  //                 }
  //               : null,
  //           icon: Icons.line_style_rounded,
  //         ),
  //       ),
  //       const SizedBox(width: 10),
  //       IconButton(
  //         icon: const Icon(Icons.add_circle_outline_outlined),
  //         onPressed: model.isCheckedIn && model.selectedProductName != null
  //             ? () {
  //                 model.addGtProductToList(); // Call method to add product
  //               }
  //             : null, // Disable if conditions are not met
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildSelectProductSection(CheckInViewModel model) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       Expanded(
  //         child: _buildDropdown(
  //           label: 'Select Product',
  //           value: model.selectedProduct?.itemName,
  //           items: ['Product A', 'Product B'], // Limit to these two products
  //           onChanged: model.isCheckedIn
  //               ? (value) => model.setSelectedSku(
  //                     model.listOfProducts.firstWhere(
  //                       (product) => product.itemName == value,
  //                     ),
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
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: const Text(
                'Price Compliance',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: const Text(
                'Price',
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
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Flexible(
                    flex: 3,
                    child: Text(
                      product.itemName,
                      style: const TextStyle(fontSize: 14),
                      // overflow: TextOverflow.ellipsis, // Prevent text overflow
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    flex: 2,
                    child: Container(
                      width: double.infinity,
                      child: TextField(
                        keyboardType:
                            TextInputType.number, // Use number keyboard
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ], // Only allow digits
                        onChanged: (availability) {
                          // Passing the availability value as a string
                          model.setShelfAvailability(availability);
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
                  Flexible(
                    flex: 2,
                    child: Container(
                      width: double.infinity,
                      child: DropdownButtonFormField<String>(
                        isExpanded:
                            true, // Make the dropdown expand to fill available space
                        onChanged: (value) {
                          model.setPriceCompliance(value);
                          if (value == 'Available') {
                            // Show price input when "Yes" is selected
                          }
                        },
                        items: const [
                          'Yes',
                          'No',
                        ].map((String item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                        decoration: InputDecoration(
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
                  Flexible(
                    flex: 2,
                    child: Container(
                      width: double.infinity,
                      child: TextField(
                        keyboardType: TextInputType.numberWithOptions(
                            decimal:
                                true), // Allow number input including decimal
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(
                              r'^\d*\.?\d*$')), // Allows only digits and one decimal point
                        ],
                        onChanged: (price) {
                          final parsedPrice = double.tryParse(price);
                          if (parsedPrice != null) {
                            // model.setProductPrice(product.itemName, parsedPrice);
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter price',
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

  // List<Widget> _buildDropdownSections(CheckInViewModel model) {
  //   return [
  //     _buildTextField(
  //       label: 'Marketing Request',
  //       hintText: 'Enter details on Marketing request',
  //       onChanged: model.isCheckedIn ? model.setMarketingRequest : null,
  //       icon: Icons.shuffle_on_outlined,
  //     ),
  //     const SizedBox(height: 16),
  //     _buildTextField(
  //       label: 'Branding Request',
  //       hintText: 'Enter details on Branding request',
  //       onChanged: model.isCheckedIn ? model.setBrandingRequest : null,
  //       icon: Icons.cable_outlined,
  //     ),
  //     const SizedBox(height: 16),
  //     _buildBrandAvailabilityCheckboxes(model),
  //     // IconButton(
  //     //   icon: const Icon(Icons.add_circle_outline_outlined),
  //     //   onPressed: () {
  //     //     if (selectedProduct != null &&
  //     //         !selectedProducts.contains(selectedProduct)) {
  //     //       selectedProducts.add(selectedProduct);
  //     //       productAvailability[selectedProduct] = true; // Default to available
  //     //     }
  //     //   },
  //     // ),
  //     // _buildTextField(
  //     //   label: 'Brand Availability',
  //     //   hintText: 'Enter details on Brand availability',
  //     //   onChanged: model.isCheckedIn ? model.setShelfAvailability : null,
  //     //   icon: Icons.branding_watermark_outlined,
  //     // ),
  //     const SizedBox(height: 16),
  //     ...selectedProducts.map((product) {
  //       return Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Text(product),
  //           Checkbox(
  //             value: productAvailability[product],
  //             onChanged: (bool value) {
  //               productAvailability[product] = value ?? true;
  //             },
  //           ),
  //         ],
  //       );
  //     }).toList(),
  //   ];
  // }

  List<Widget> _buildDropdownSections(CheckInViewModel model) {
    return [
      _buildTextField(
        label: 'Marketing Request',
        hintText: 'Enter details on Marketing request',
        onChanged: model.isCheckedIn ? model.setMarketingRequest : null,
        icon: Icons.shuffle_on_outlined,
        enabled: model.isCheckedIn, // Pass enabled flag
      ),
      const SizedBox(height: 16),
      _buildTextField(
        label: 'Branding Request',
        hintText: 'Enter details on Branding request',
        onChanged: model.isCheckedIn ? model.setBrandingRequest : null,
        icon: Icons.cable_outlined,
        enabled: model.isCheckedIn, // Pass enabled flag
      ),
      const SizedBox(height: 16),
      _buildBrandAvailabilityCheckboxes(
        model,
      ), // Pass enabled flag
      const SizedBox(height: 16),
      ...selectedProducts.map((product) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(product),
            Opacity(
              opacity: model.isCheckedIn ? 1.0 : 0.5, // Apply opacity
              child: AbsorbPointer(
                absorbing:
                    !model.isCheckedIn, // Prevent interaction if not checked in
                child: Checkbox(
                  value: productAvailability[product],
                  onChanged: model.isCheckedIn
                      ? (bool value) {
                          productAvailability[product] = value ?? true;
                        }
                      : null,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    ];
  }

  // Widget _buildBrandAvailabilityDropdown(CheckInViewModel model) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text(
  //         'Brand',
  //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //       ),
  //       const SizedBox(height: 8),
  //       DropdownButtonFormField<String>(
  //         value: model
  //             .brandAvailability, // Assuming model.shelfAvailability holds this value
  //         onChanged: model.isCheckedIn ? model.setBrandAvailability : null,
  //         items: const [
  //           'Supa Loaf',
  //           'Butter Toast',
  //           'Supa Nutri',
  //           'Supa Tam',
  //         ]
  //             .map((String item) =>
  //                 DropdownMenuItem<String>(value: item, child: Text(item)))
  //             .toList(),
  //         decoration: _dropdownDecoration(),
  //       ),
  //     ],
  //   );
  // }
  // Widget _buildBrandAvailabilityDropdown() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text(
  //         'Brand',
  //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //       ),
  //       const SizedBox(height: 8),
  //       DropdownButtonFormField<String>(
  //         value: selectedProduct,
  //         onChanged: (value) {
  //           selectedProduct = value;
  //         },
  //         items: const [
  //           'Supa Loaf',
  //           'Butter Toast',
  //           'Supa Nutri',
  //           'Supa Tam',
  //         ]
  //             .map((String item) =>
  //                 DropdownMenuItem<String>(value: item, child: Text(item)))
  //             .toList(),
  //         decoration: _dropdownDecoration(),
  //       ),
  //     ],
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
                      model.removeBrand(brand);
                    }
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
      prefixIcon: Icon(Icons.line_style_rounded),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildTextField({
    String label,
    String hintText,
    ValueChanged<String> onChanged,
    int maxLines = 1,
    IconData icon,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Opacity(
          opacity: enabled ? 1.0 : 0.5,
          child: AbsorbPointer(
            absorbing: !enabled,
            child: TextField(
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
          ),
        ),
      ],
    );
  }

  // Widget _buildTextField({
  //   String label,
  //   String hintText,
  //   ValueChanged<String> onChanged,
  //   int maxLines = 1,
  //   IconData icon,
  //   bool isEnabled = false, // Add a parameter to control enabled/disabled state
  // }) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         label,
  //         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //       ),
  //       const SizedBox(height: 8),
  //       TextField(
  //         onChanged:
  //             isEnabled ? onChanged : null, // Disable onChanged if not enabled
  //         maxLines: maxLines,
  //         enabled: isEnabled, // Enable or disable the TextField
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
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            );
          }).toList(),
          decoration: InputDecoration(
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

  // Widget _buildCheckInDetails(CheckInViewModel model) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 20.0),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             const Text(
  //               'Check In',
  //               style: TextStyle(color: Colors.black, fontSize: 16),
  //             ),
  //             const SizedBox(height: 5),
  //             Text(
  //               model.isCheckedIn && model.checkInTime != null
  //                   ? 'Checked in: ${DateFormat("dd/MM/yyyy HH:mm").format(model.checkInTime)}'
  //                   : 'Not yet checked in',
  //               style: TextStyle(
  //                   fontSize: 14,
  //                   fontWeight: FontWeight.bold,
  //                   color: model.isCheckedIn ? Colors.green : Colors.red),
  //             ),
  //           ],
  //         ),
  //         if (model.isCheckedIn)
  //           Icon(
  //             Icons.check_circle_outline_rounded,
  //             color: Colors.green,
  //           ),
  //       ],
  //     ),
  //   );
  // }

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
}
