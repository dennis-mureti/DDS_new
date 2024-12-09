import 'package:distributor/conf/dds_brand_guide.dart';
import 'package:distributor/conf/style/lib/colors.dart';
import 'package:distributor/ui/views/crm/checkin/checkin_view_model.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:intl/intl.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';
import 'package:tripletriocore/tripletriocore.dart';

class CheckInView extends StatelessWidget {
  final String visitId;

  CheckInView({Key key, this.visitId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CheckInViewModel>.reactive(
      onModelReady: (model) async {
        model.setBusy(true); // Start the loading state
        await model.fetchProducts(); // Fetch the customers
        model.setBusy(false); // End the loading state
      },
      builder: (context, model, child) {
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;

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
                          children: <Widget>[
                            // Container(
                            //   margin: EdgeInsets.symmetric(
                            //     horizontal: screenWidth * 0.05,
                            //     vertical: 10.0,
                            //   ),
                            //   color:
                            //       kColorDDSPrimaryDark, // Set the background color to red
                            //   child: _buildUserDetail(model),
                            // ),
                            // _buildCheckInDetails(model),
                            // const SizedBox(height: 8),

                            // // Divider below check-in details
                            // const Padding(
                            //   padding: EdgeInsets.symmetric(horizontal: 20.0),
                            //   child: Divider(
                            //     color: Colors.grey,
                            //     thickness: 0.5,
                            //   ),
                            // ),

                            // const SizedBox(height: 20),
                            _buildDropdown(
                                label: 'Select Product',
                                value: model.selectedProduct?.itemName,
                                items: model.listOfProducts
                                    .map((product) => product.itemName)
                                    .toList(),
                                onChanged: (value) => model.setSelectedSku(
                                    model.productList.firstWhere((product) =>
                                        product.itemName == value)),
                                icon: Icons.line_style_rounded),
                            const SizedBox(height: 16),
                            _buildDropdown(
                              label: 'Shelf Availability',
                              value: model.shelfAvailability,
                              items: const ['Yes', 'No'],
                              onChanged: model.setShelfAvailability,
                              icon: Icons.shuffle_on_outlined,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'Share of Shelf',
                              hintText: 'Enter percentage or description',
                              onChanged: model.setShareOfShelf,
                              icon: Icons.percent_outlined,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'SKU Volume',
                              hintText: 'Enter SKU volume',
                              onChanged: model.setSkuVolume,
                              icon: Icons.view_column,
                            ),
                            const SizedBox(height: 16),
                            // _buildTextField(
                            //   label: 'Competitor Info',
                            //   hintText: 'Brief description of competitors',
                            //   maxLines: 3,
                            //   onChanged: model.setCompetitorInfo,
                            //   icon: Icons.info_outline,
                            // ),
                            // const SizedBox(height: 16),
                            _buildDropdown(
                              label: 'Activations',
                              value: model.activations,
                              items: const ['Yes', 'No'],
                              onChanged: model.setActivations,
                              icon: Icons.local_activity_outlined,
                            ),
                            const SizedBox(height: 16),
                            _buildDropdown(
                              label: 'Price Compliance',
                              value: model.priceCompliance,
                              items: const ['Yes', 'No'],
                              onChanged: (value) {
                                model.setPriceCompliance(value);
                              },
                              icon: Icons.price_change,
                            ),
                            if (model.priceCompliance == 'No') ...[
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'Retail Price',
                                hintText: 'Enter retail price',
                                onChanged: model.setRetailPrice,
                                icon: Icons.price_change_outlined,
                              ),
                            ],
                            const SizedBox(height: 16),
                            // _buildDropdown(
                            //   label: 'Brand Availability',
                            //   value: model.brandAvailability,
                            //   items: const ['Yes', 'No'],
                            //   onChanged: model.setBrandAvailability,
                            //   icon: Icons.bar_chart_rounded,
                            // ),
                            // const SizedBox(height: 16),
                            // _buildDropdown(
                            //   label: 'Marketing Request',
                            //   value: model.marketingRequest,
                            //   items: const ['Yes', 'No'],
                            //   onChanged: model.setMarketingRequest,
                            //   icon: Icons.request_quote_outlined,
                            // ),
                            // const SizedBox(height: 16),
                            // _buildDropdown(
                            //   label: 'Branding Request',
                            //   value: model.brandingRequest,
                            //   items: const ['Yes', 'No'],
                            //   onChanged: model.setBrandingRequest,
                            //   icon: Icons.read_more,
                            // ),
                            // const SizedBox(height: 16),
                            // _buildTextField(
                            //   label: 'General Feedback',
                            //   hintText: 'Provide feedback',
                            //   maxLines: 4,
                            //   onChanged: model.setGeneralFeedback,
                            //   icon: Icons.feed_sharp,
                            // ),
                            // const SizedBox(height: 16),
                            // ElevatedButton.icon(
                            //   icon: const Icon(Icons.camera_alt),
                            //   label: const Text('Upload/Take Photo'),
                            //   onPressed: model.uploadPhoto,
                            //   style: ElevatedButton.styleFrom(
                            //     primary: Colors.grey.shade300,
                            //     onPrimary: Colors.black,
                            //     shape: RoundedRectangleBorder(
                            //       borderRadius: BorderRadius.circular(10),
                            //     ),
                            //   ),
                            // ),
                            // const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () async =>
                                  await model.submitCheckIn(context),
                              style: ElevatedButton.styleFrom(
                                primary: kColDDSPrimaryDark,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15.0, horizontal: 20.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.check, // Submit icon
                                    color: Colors.white,
                                    size: 20.0,
                                  ),
                                  const SizedBox(width: 10.0),
                                  const Text(
                                    'Submit', // Button label
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )
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

  Widget _buildDropdown({
    // BuildContext context,
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
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
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

  Widget _buildTextField({
    @required String label,
    String hintText,
    ValueChanged<String> onChanged,
    int maxLines = 1,
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

  Widget _buildUserDetail(CheckInViewModel model) {
    final String todayDate =
        DateFormat('EEEE, MMM dd, yyyy').format(DateTime.now());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          todayDate,
          style: TextStyle(
            color: kColDDSPrimaryDark,
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Welcome back, ${model.user.full_name}',
          style: TextStyle(
            color: kColDDSPrimaryDark,
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckInDetails(CheckInViewModel model) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Check In',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
              const SizedBox(height: 5),
              Text(
                model.isCheckedIn && model.checkInTime != null
                    ? DateFormat('hh:mm a').format(model.checkInTime)
                    : 'Start',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Duration',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
              const SizedBox(height: 5),
              Text(
                model.duration,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
