import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/contact_model.dart';
import '../providers/contact_provider.dart';

class CustomLikeButton extends StatelessWidget {
  const CustomLikeButton({
    super.key,
    required this.ref,
    required this.contact,
  });

  final WidgetRef ref;
  final ContactModel contact;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).colorScheme;
    final bubbleColor = contact.isFavorite
        ? BubblesColor(
            dotPrimaryColor: Colors.red.shade800,
            dotSecondaryColor: Colors.red.shade300)
        : BubblesColor(
            dotPrimaryColor: style.background,
            dotSecondaryColor: style.background);
    return LikeButton(
      onTap: (isLiked) {
        ref.read(contactProvider.notifier).updateFavorite(contact);
        return Future.value(!isLiked);
      },
      bubblesColor: bubbleColor,
      likeBuilder: (isLiked) {
        return Icon(
          Icons.favorite,
          key: ValueKey(contact.isFavorite),
          color:
              contact.isFavorite ? Colors.red.shade600 : Colors.grey.shade400,
        );
      },
    );
  }
}
