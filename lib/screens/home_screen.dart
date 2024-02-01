import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:v_card/shared/like_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:v_card/models/contact_model.dart';
import 'package:v_card/screens/camera_screen.dart';
import 'package:v_card/shared/elevated_button.dart';
import 'package:v_card/screens/preview_screen.dart';
import 'package:v_card/screens/details_screen.dart';
import 'package:v_card/providers/contact_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:v_card/widgets/bottom_sheet_button.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:v_card/routers/providers/image_provider.dart';
import 'package:v_card/routers/providers/camera_des_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  static const String routeName = '/';

  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _index = 0;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.read(contactProvider.notifier).getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    final contactList = ref.watch(contactProvider);
    final style = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(_index == 0 ? 'Contacts' : 'Favorites')),
      bottomNavigationBar: _bottomNavigationBar(style),
      floatingActionButton: _floatingActionButton(style),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          final pos = Tween<Offset>(
                  begin: _index == 0
                      ? const Offset(1.0, 0.0)
                      : const Offset(-1.0, 0.0),
                  end: const Offset(0.0, 0.0))
              .animate(animation);
          return SlideTransition(position: pos, child: child);
        },
        child: _isLoading
            ? _buildLoadingSpinner()
            : _buildContactList(context, style, contactList),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  //* Center content listview for displaying all contacts
  Widget _buildContactList(
    BuildContext context,
    ThemeData style,
    List<ContactModel> contactList,
  ) {
    if (contactList.isEmpty) {
      return _emptyScreenMessage();
    }
    return ListView.builder(
      itemCount: contactList.length,
      itemBuilder: (context, index) {
        final contact = contactList[index];
        return Dismissible(
          key: ValueKey('index: $index'),
          direction: DismissDirection.endToStart,
          background: Container(
            color: style.colorScheme.error,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: Icon(Icons.delete, color: style.colorScheme.onError),
          ),
          onDismissed: (direction) {
            _deleteContact(direction, contact.id);
          },
          confirmDismiss: _showConfirmationDialog,
          child: ListTile(
            onTap: () {
              context.goNamed(DetailsScreen.routeName, extra: contact.id);
            },
            title: Text(contact.name),
            trailing: SizedBox(
              width: 50,
              child: CustomLikeButton(ref: ref, contact: contact),
            ),
          ),
        );
      },
    );
  }

  Center _emptyScreenMessage() {
    return Center(
        child: Text(
      _index == 0 ? 'No contact available.' : 'No favorite contacts.',
    ));
  }

  Widget _buildLoadingSpinner() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  //* Bottom navigation bar containing all and favorite options
  BottomAppBar _bottomNavigationBar(ThemeData style) {
    return BottomAppBar(
      notchMargin: 8,
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: const CircularNotchedRectangle(),
      child: BottomNavigationBar(
        currentIndex: _index,
        backgroundColor: style.colorScheme.primaryContainer,
        items: [
          BottomNavigationBarItem(
            label: 'All',
            icon: Icon(_index == 0 ? Icons.person : Icons.person_outlined),
          ),
          BottomNavigationBarItem(
            label: 'Favorite',
            icon: Icon(_index == 1 ? Icons.favorite : Icons.favorite_border),
          ),
        ],
        onTap: (value) {
          setState(() {
            _index = value;
          });
          _fetchData();
        },
      ),
    );
  }

  //* Floating action Button for adding new contact that opens modal bottom sheet
  FloatingActionButton _floatingActionButton(ThemeData style) {
    return FloatingActionButton(
      onPressed: () {
        modalBottomSheet(style);
      },
      shape: const CircleBorder(),
      child: const Icon(Icons.add),
    );
  }

  void modalBottomSheet(ThemeData style) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return Wrap(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Choose Picture', style: style.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      BottomSheetButton(
                        text: 'Camera',
                        onTap: _pickCamera,
                        icon: Icons.camera_alt,
                      ),
                      const SizedBox(width: 16),
                      BottomSheetButton(
                        text: 'Gallery',
                        onTap: _pickGallery,
                        icon: Icons.photo_library,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  //* Method for opening camera
  void _pickCamera() async {
    EasyLoading.show(status: 'Loading...');
    await Future.delayed(const Duration(milliseconds: 500));
    final cameras = await availableCameras();

    //* saving cameras description in provider for next screen
    ref.read(camDesProvider.notifier).getCameraDescription(cameras);

    EasyLoading.dismiss();
    if (mounted) {
      context.pop();
    }
    await availableCameras().then((value) {
      context.goNamed(CameraScreen.routeName);
    });
  }

  //* Method for opening gallery
  void _pickGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      //* saving image in image provider for next screen
      ref.read(imageProvider.notifier).getImage(image.path);

      if (mounted) {
        context.pop();
        context.goNamed(PreviewScreen.routeName);
      }
    }
  }

  Future<bool?> _showConfirmationDialog(DismissDirection direction) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: const Text('Are you sure to delete this contact?'),
        actions: [
          TextButton(
            onPressed: () {
              context.pop(false);
            },
            child: const Text('No'),
          ),
          CustomElevatedButton(
            onPressed: () {
              context.pop(true);
            },
            text: 'Yes',
          )
        ],
      ),
    );
  }

  void _deleteContact(DismissDirection direction, int id) async {
    await ref.read(contactProvider.notifier).deleteContact(id);
    EasyLoading.showSuccess('Deleted',
        duration: const Duration(milliseconds: 500));
  }

  // Home screen content will be fetched based on this function
  void _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    switch (_index) {
      case 0:
        await ref.read(contactProvider.notifier).getAllContacts();
        break;
      case 1:
        await ref.read(contactProvider.notifier).getAllFavoriteContacts();
        break;
    }

    setState(() {
      _isLoading = false;
    });
  }
}
