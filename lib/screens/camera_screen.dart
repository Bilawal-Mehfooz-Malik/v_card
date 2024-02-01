import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:v_card/screens/preview_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:v_card/routers/providers/image_provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:v_card/routers/providers/camera_des_provider.dart';

class CameraScreen extends ConsumerStatefulWidget {
  static const String routeName = 'camera';
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  double _currentZoomLevel = 1.0;
  bool _isRearCameraSelected = true;
  late List<CameraDescription> cameras;
  late CameraController _cameraController;
  FlashMode _currentFlashMode = FlashMode.off;

  Future _initCamera(CameraDescription cameraDescription) async {
    _cameraController =
        CameraController(cameraDescription, ResolutionPreset.high);
    try {
      await _cameraController.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  @override
  void initState() {
    super.initState();
    cameras = ref.read(camDesProvider.notifier).camDescrip;
    _initCamera(cameras[0]);
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            _cameraPreviewWidget(),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 120,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _flashButton(),
                    _captureButton(),
                    _cameraToggleButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //* Camera Preview Widget
  Widget _cameraPreviewWidget() {
    return GestureDetector(
      onScaleUpdate: (details) async {
        var maxZoomLevel = await _cameraController.getMaxZoomLevel();
        var newZoomLevel = _currentZoomLevel * details.scale;

        newZoomLevel = newZoomLevel.clamp(1, maxZoomLevel);

        await _cameraController.setZoomLevel(newZoomLevel);
        setState(() => _currentZoomLevel = newZoomLevel);
      },
      child: SizedBox(
        width: double.infinity,
        child: CameraPreview(_cameraController),
      ),
    );
  }

  //* Flash Button Widget
  Widget _flashButton() {
    IconData flashIcon;

    switch (_currentFlashMode) {
      case FlashMode.torch:
        flashIcon = Icons.flash_on;
        break;
      case FlashMode.auto:
        flashIcon = Icons.flash_auto;
        break;
      default:
        flashIcon = Icons.flash_off;
        break;
    }

    return IconButton(
      iconSize: 40,
      onPressed: _toggleFlash,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: Icon(flashIcon, color: Colors.white),
    );
  }

  //* Switch Camera Widget
  Widget _cameraToggleButton() {
    return IconButton(
      iconSize: 40,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: Icon(
        color: Colors.white,
        _isRearCameraSelected
            ? CupertinoIcons.switch_camera
            : CupertinoIcons.switch_camera_solid,
      ),
      onPressed: _switchCamera,
    );
  }

  //* Capture Button Widget
  Widget _captureButton() {
    return GestureDetector(
      onTap: _takePicture,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
        ),
        child: Center(
          child: Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  //* Switch Camera Method
  void _switchCamera() {
    setState(() => _isRearCameraSelected = !_isRearCameraSelected);
    _initCamera(cameras[_isRearCameraSelected ? 0 : 1]);
  }

  //* Take Picture Method
  Future _takePicture() async {
    if (!_cameraController.value.isInitialized) {
      return null;
    }
    if (_cameraController.value.isTakingPicture) {
      return null;
    }
    try {
      await _cameraController.setFlashMode(_currentFlashMode);
      final XFile picture = await _cameraController.takePicture();

      //* saving image in image provider the cropped one for later use 
      ref.read(imageProvider.notifier).getImage(picture.path);

      if (mounted) {
        context.goNamed(PreviewScreen.routeName);
      }
    } on CameraException catch (e) {
      EasyLoading.showError('Failed to capture');
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  //* Flash on off Method
  void _toggleFlash() {
    setState(() {
      switch (_currentFlashMode) {
        case FlashMode.off:
          _currentFlashMode = FlashMode.torch;
          break;
        case FlashMode.torch:
          _currentFlashMode = FlashMode.auto;
          break;
        case FlashMode.auto:
          _currentFlashMode = FlashMode.off;
          break;
        default:
          _currentFlashMode = FlashMode.off;
          break;
      }
    });

    _updateFlashMode();
  }

  void _updateFlashMode() async {
    if (_cameraController.value.isInitialized) {
      try {
        await _cameraController.setFlashMode(_currentFlashMode);
      } on CameraException catch (e) {
        debugPrint('Error setting flash mode: $e');
      }
    }
  }
}
