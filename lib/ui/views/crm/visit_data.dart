import 'package:stacked/stacked.dart';

class VisitViewModel extends BaseViewModel {
  // Sample data lists
  List<String> customers = ['Customer A', 'Customer B', 'Customer C'];
  List<String> salesReps = ['Rep 1', 'Rep 2', 'Rep 3'];
  List<String> visitReasons = ['Routine Check', 'Urgent Issue', 'Follow-Up'];

  // Selected dropdown values
  String selectedCustomer;
  String selectedSalesRep;
  String selectedReason;

  // Setters for dropdown values with notifyListeners
  void setSelectedCustomer(String value) {
    selectedCustomer = value;
    notifyListeners(); // Notify the UI to rebuild
  }

  void setSelectedSalesRep(String value) {
    selectedSalesRep = value;
    notifyListeners(); // Notify the UI to rebuild
  }

  void setSelectedReason(String value) {
    selectedReason = value;
    notifyListeners(); // Notify the UI to rebuild
  }

  init() async {
    // This is not a minishop
    // Dont fetch user journeys
    // if (!user.hasSalesChannel) {
    //   await _logisticsService.fetchJourneys();
    // }
  }

  void confirmVisit() {
    if (selectedCustomer != null &&
        selectedSalesRep != null &&
        selectedReason != null) {
      print(
          "Visit confirmed for $selectedCustomer by $selectedSalesRep for reason: $selectedReason");
      // Additional logic for confirming the visit can go here
    } else {
      print("Please fill in all fields.");
    }
  }
}
