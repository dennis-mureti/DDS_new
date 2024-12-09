import 'package:stacked/stacked.dart';

class CompleteVisitsViewModel extends BaseViewModel {
  List<CompleteVisit> completeVisitsList = [];
  bool isBusy = false;

  Future<void> init() async {
    isBusy = true;
    notifyListeners();
    // Simulate fetching data
    await Future.delayed(const Duration(seconds: 2));
    completeVisitsList = [
      CompleteVisit(date: '2024-12-05', visitsMade: 5, status: 'Approved'),
      CompleteVisit(date: '2024-12-04', visitsMade: 3, status: 'Approved'),
    ];
    isBusy = false;
    notifyListeners();
  }
}

class CompleteVisit {
  final String date;
  final int visitsMade;
  final String status;

  CompleteVisit({this.date, this.visitsMade, this.status});
}
