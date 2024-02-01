import 'package:v_card/data/db_helper.dart';
import 'package:v_card/models/contact_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContactNotifier extends StateNotifier<List<ContactModel>> {
  ContactNotifier() : super([]);

  final DbHelper db = DbHelper();

  Future<int> insertContact(ContactModel contactModel) async {
    final rowId = await db.insertContact(contactModel);
    contactModel.id = rowId;
    state = [...state, contactModel];
    return rowId;
  }

  Future<void> getAllContacts() async {
    state = await db.getAllContacts();
  }

  Future<ContactModel> getContactById(int id) => db.getContactById(id);

  Future<void> getAllFavoriteContacts() async {
    state = await db.getAllFavoriteContacts();
  }

  Future<int> deleteContact(int id) async {
    final rowId = await db.deleteContact(id);
    state = state.where((contact) => contact.id != id).toList();
    return rowId;
  }

  Future<void> updateFavorite(ContactModel contactModel) async {
    final value = contactModel.isFavorite ? 0 : 1;
    await db.updateFavorite(contactModel.id, value);
    final List<ContactModel> updatedState = List.from(state);
    final index = updatedState.indexOf(contactModel);
    updatedState[index].isFavorite = !updatedState[index].isFavorite;
    state = updatedState;
  }
}

final contactProvider =
    StateNotifierProvider<ContactNotifier, List<ContactModel>>(
        (ref) => ContactNotifier());
