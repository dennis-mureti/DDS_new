import 'package:camera/camera.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:stacked/stacked.dart';

class ScannerViewModel extends BaseViewModel {
  // final BarcodeScanner barcodeScanner = BarcodeScanner();
  CameraController _controller;
  CameraController get cameraController => _controller;
  Future<void> initializeControllerFuture;

  List _cameras = [];
  List get cameras => _cameras;

  List _items = [];
  List get items => _items;
  updateItems() async {}

  init() async {
    await getAvailableCameras();
    _controller = CameraController(cameras.first, ResolutionPreset.ultraHigh);
    // Next, initialize the controller. This returns a Future.
    initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  getAvailableCameras() async {
    setBusy(true);
    _cameras = await availableCameras();
    setBusy(false);
    print(cameras.length);
  }

  void clearItems() {
    _items.clear();
    notifyListeners();
  }
}
