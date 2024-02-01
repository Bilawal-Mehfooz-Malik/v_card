import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:v_card/screens/scanned_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:v_card/routers/providers/image_provider.dart';
import 'package:v_card/routers/providers/scanned_data_provider.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class PreviewScreen extends ConsumerStatefulWidget {
  static const String routeName = 'preview';

  const PreviewScreen({super.key});

  @override
  ConsumerState<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends ConsumerState<PreviewScreen> {
  late String _pic;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _pic = ref.read(imageProvider.notifier).image;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: Image.file(File(_pic))),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _customButton(
                    icon: Icons.clear,
                    text: 'Cancel',
                    color: Colors.red,
                    onTap: () {
                      cancelMethod(context);
                    },
                    disabled: _processing,
                    disabledColor: Colors.red.shade300),
                _customButton(
                    icon: Icons.crop,
                    text: 'Crop',
                    color: Colors.blue,
                    onTap: () {
                      _cropImage(context);
                    },
                    disabled: _processing,
                    disabledColor: Colors.blue.shade300),
                _customButton(
                  text: 'Process',
                  onTap: _processing ? null : scanImage,
                  // Update this line
                  icon: Icons.check,
                  color: Colors.green,
                  disabledColor: Colors.green.shade300,
                  disabled: _processing,
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _customButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback? onTap,
    required bool disabled,
    required Color disabledColor,
  }) {
    // Color customDisabledColor = const Color(0xFFDAB5B5);

    return InkWell(
      onTap: disabled ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    disabled
                        ? disabledColor.withOpacity(0.5)
                        : color.withOpacity(0.5),
                    disabled ? disabledColor : color
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 5),
            Text(
              text,
              style: TextStyle(
                color: disabled ? disabledColor : color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void cancelMethod(BuildContext context) {
    context.pop();
  }

  Future<void> _cropImage(BuildContext ctx) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: _pic,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9,
      ],
      uiSettings: [
        AndroidUiSettings(
          lockAspectRatio: false,
          toolbarTitle: 'Crop Picture',
          toolbarColor: Colors.black,
          backgroundColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
        ),
        IOSUiSettings(title: 'Crop'),
        WebUiSettings(context: ctx),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        _pic = croppedFile.path;
      });
      ref.read(imageProvider.notifier).getImage(_pic);
    }
  }

  void scanImage() async {
    if (!File(_pic).existsSync()) {
      EasyLoading.showError('Image not found!');
      return;
    }
    EasyLoading.show(status: 'Processing...');
    setState(() {
      _processing = true;
    });
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final recognizedText =
        await textRecognizer.processImage(InputImage.fromFile(File(_pic)));
    EasyLoading.dismiss();

    //* Saving text to temporary list of image
    final tempList = <String>[];

    for (var block in recognizedText.blocks) {
      for (var line in block.lines) {
        tempList.add(line.text);
      }
    }

    setState(() {
      _processing = false;
    });

    //* Saving data in provider for next screen
    ref.read(scannedDataProvider.notifier).getScannedData(tempList);

    if (context.mounted) {
      context.goNamed(ScannedScreen.routeName);
    }
  }
}
