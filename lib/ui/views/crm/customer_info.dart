import 'package:distributor/conf/dds_brand_guide.dart';
import 'package:distributor/conf/style/lib/colors.dart';
import 'package:distributor/ui/views/crm/dashboard_viewmodel.dart';
// import 'package:distributor/ui/views/dashboard/dashboard_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class CustomerInfoView extends StatefulWidget {
  @override
  State<CustomerInfoView> createState() => _CustomerInfoViewState();
}

class _CustomerInfoViewState extends State<CustomerInfoView> {
  GoogleMapController _mapController;
  // LatLng _customerLocation;
  final LatLng _customerLocation = LatLng(-4.0435, 39.6682); // Mombasa, Kenya

  // @override
  // void initState() {
  //   super.initState();
  //   _getCustomerLocation();
  // }

  // Future<void> _getCustomerLocation() async {
  //   try {
  //     LocationPermission permission = await Geolocator.checkPermission();
  //     if (permission == LocationPermission.denied) {
  //       permission = await Geolocator.requestPermission();
  //       if (permission == LocationPermission.denied) {
  //         print("Location permission denied");
  //         return;
  //       }
  //     }

  //     Position position = await Geolocator.getCurrentPosition(
  //         desiredAccuracy: LocationAccuracy.high);
  //     print("Fetched location: ${position.latitude}, ${position.longitude}");
  //     setState(() {
  //       _customerLocation = LatLng(position.latitude, position.longitude);
  //     });
  //   } catch (e) {
  //     print("Error fetching location: $e");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CRMDashboardViewModel>.reactive(
      onModelReady: (model) async {
        await model.init();
      },
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Customer Information',
              style: TextStyle(fontSize: 20),
            ),
            backgroundColor: kColDDSPrimaryDark,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Center align content
              children: [
                const SizedBox(height: 10),

                // General Information Section
                const Text(
                  'General Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // Center the card
                Center(
                  child: _buildGeneralInfoCard(model),
                ),

                const SizedBox(height: 20),

                // Location Section
                const Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // Center the map
                Center(
                  child: _buildLiveMap(),
                ),
              ],
            ),
          ),
        );
      },
      viewModelBuilder: () => CRMDashboardViewModel(),
    );
  }

  // General Information Card
  Widget _buildGeneralInfoCard(CRMDashboardViewModel model) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          // children: [
          //   _buildInfoRow('Customer Type', model.customerType ?? 'N/A'),
          //   const SizedBox(height: 15),
          //   _buildInfoRow('Customer Group', model.customerGroup ?? 'N/A'),
          //   const SizedBox(height: 15),
          //   _buildInfoRow('Telephone', model.telephone ?? 'N/A'),
          // ],
        ),
      ),
    );
  }

  // Info Row Widget
  Widget _buildInfoRow(String label, String value) {
    return Center(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.center, // Center align text within the column
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Live Map Widget
  // Widget _buildLiveMap() {
  //   if (_customerLocation == null) {
  //     return const Center(child: CircularProgressIndicator());
  //   }

  //   return Container(
  //     width: MediaQuery.of(context).size.width * 0.9,
  //     height: 200,
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(12.0),
  //     ),
  //     child: GoogleMap(
  //       initialCameraPosition: CameraPos ition(
  //         target: _customerLocation,
  //         zoom: 14.0,
  //       ),
  //       markers: {
  //         Marker(
  //           markerId: const MarkerId('customerLocation'),
  //           position: _customerLocation,
  //           infoWindow: const InfoWindow(title: 'Customer Location'),
  //         ),
  //       },
  //       onMapCreated: (controller) {
  //         _mapController = controller;
  //         _mapController.animateCamera(
  //           CameraUpdate.newLatLng(_customerLocation),
  //         );
  //       },
  //     ),
  //   );
  // }

  // Live Map Widget with Placeholder Image
  Widget _buildLiveMap() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: _mapController == null
          ? Image.asset(
              'assets/images/placeholder_map.jpeg', // Placeholder image path
              fit: BoxFit.cover,
            )
          : GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(-4.0435, 39.6682), // Hardcoded Mombasa location
                zoom: 14.0,
              ),
              markers: {
                Marker(
                  markerId: MarkerId('customerLocation'),
                  position: _customerLocation,
                  infoWindow: const InfoWindow(title: 'Customer Location'),
                ),
              },
              onMapCreated: (controller) {
                setState(() {
                  _mapController = controller;
                });
              },
            ),
    );
  }
}
