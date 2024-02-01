import 'package:flutter_riverpod/flutter_riverpod.dart';

final scannedDataProvider =
    StateNotifierProvider<ScannedData, List<String>>((ref) {
  return ScannedData();
});

class ScannedData extends StateNotifier<List<String>> {
  ScannedData() : super([]);

  void getScannedData(List<String> list) {
    state = list;
  }

  List<String> get scannedData => state;
}
