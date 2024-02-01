import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:v_card/models/contact_model.dart';

final contactModelProvider =
    StateNotifierProvider<ContactModal, ContactModel>((ref) {
  return ContactModal();
});

class ContactModal extends StateNotifier<ContactModel> {
  ContactModal() : super(ContactModel(name: '', mobile: ''));

  void getContactModel(ContactModel contactModel) {
    state = contactModel;
  }

  ContactModel get contactModal => state;
}
