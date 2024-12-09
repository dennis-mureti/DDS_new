import 'package:stacked/stacked.dart';

class PendingVisitsViewModel extends BaseViewModel {
  List<PendingVisit> pendingVisitsList = [];
  bool isBusy = false;

  Future<void> init() async {
    isBusy = true;
    notifyListeners();
    // Simulate fetching data
    await Future.delayed(const Duration(seconds: 2));
    pendingVisitsList = [
      PendingVisit(date: '2024-12-05', visitsMade: 5, status: 'Pending'),
      PendingVisit(date: '2024-12-04', visitsMade: 3, status: 'Pending'),
    ];
    isBusy = false;
    notifyListeners();
  }
}

class PendingVisit {
  final String date;
  final int visitsMade;
  final String status;

  PendingVisit({this.date, this.visitsMade, this.status});
}
