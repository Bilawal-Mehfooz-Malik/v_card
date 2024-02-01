import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final camDesProvider =
    StateNotifierProvider<CamerasDescription, List<CameraDescription>>(
        (ref) => CamerasDescription());

class CamerasDescription extends StateNotifier<List<CameraDescription>> {
  CamerasDescription() : super([]);

  void getCameraDescription(List<CameraDescription> des) {
    state = des;
  }

  List<CameraDescription> get camDescrip => state;
}
