import 'package:flutter_riverpod/flutter_riverpod.dart';

final imageProvider = StateNotifierProvider<CardImage, String?>((ref) {
  return CardImage();
});

class CardImage extends StateNotifier<String> {
  CardImage() : super('');

  void getImage(String image) {
    state = image;
  }

  String get image => state;
}
