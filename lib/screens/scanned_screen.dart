import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:v_card/screens/form_screen.dart';
import 'package:v_card/models/contact_model.dart';
import 'package:v_card/shared/elevated_button.dart';
import 'package:v_card/shared/error_messages.dart';
import 'package:v_card/models/contact_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:v_card/routers/providers/image_provider.dart';
import 'package:v_card/routers/providers/scanned_data_provider.dart';
import 'package:v_card/routers/providers/contact_modal_provider.dart';

class ScannedScreen extends ConsumerWidget {
  static const String routeName = 'scanned';

  const ScannedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.read(scannedDataProvider.notifier).scannedData;
    Map<String, String> contactVal = {
      'name': '',
      'mobile': '',
      'email': '',
      'address': '',
      'company': '',
      'designation': '',
      'website': '',
    };
    return Scaffold(
      appBar: AppBar(title: const Text('Scanned Text')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    _buildDragTargetItem(ContactProperties.name, contactVal),
                    _buildDragTargetItem(ContactProperties.mobile, contactVal),
                    _buildDragTargetItem(
                        ContactProperties.designation, contactVal),
                    _buildDragTargetItem(ContactProperties.company, contactVal),
                    _buildDragTargetItem(ContactProperties.email, contactVal),
                    _buildDragTargetItem(ContactProperties.address, contactVal),
                    _buildDragTargetItem(ContactProperties.website, contactVal),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: Wrap(
                  spacing: 8,
                  children: list.map((e) => LineItem(line: e)).toList(),
                ),
              ),
            ),
            CustomElevatedButton(
              text: 'Next',
              onPressed: () {
                createContact(ref, context, contactVal);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  //* Method to make dragtargetitem widget simpler
  Widget _buildDragTargetItem(
    String property,
    Map<String, String> contactValues,
  ) {
    return DragTargetItem(
      property: property,
      onDrop: (String property, String value) {
        getPropertyValue(property, value, contactValues);
      },
    );
  }

  //* Method to save contact values for contact model
  void getPropertyValue(
    String value,
    String property,
    Map<String, String> contactValues,
  ) {
    switch (property) {
      case ContactProperties.name:
        contactValues['name'] = value;
        break;
      case ContactProperties.mobile:
        contactValues['mobile'] = value;
        break;
      case ContactProperties.designation:
        contactValues['designation'] = value;
        break;
      case ContactProperties.company:
        contactValues['company'] = value;
        break;
      case ContactProperties.email:
        contactValues['email'] = value;
        break;
      case ContactProperties.address:
        contactValues['address'] = value;
        break;
      case ContactProperties.website:
        contactValues['website'] = value;
        break;
    }
  }

  //* Contact creation and form screen method
  void createContact(
    WidgetRef ref,
    BuildContext ctx,
    Map<String, String> contactValues,
  ) {
    final image = ref.read(imageProvider.notifier).image;
    if (contactValues['name'] != null &&
        contactValues['mobile'] != null &&
        contactValues['name']!.isNotEmpty &&
        contactValues['mobile']!.isNotEmpty) {
      final contact = ContactModel(
        name: contactValues['name']!,
        email: contactValues['email']!,
        mobile: contactValues['mobile']!,
        website: contactValues['website']!,
        address: contactValues['address']!,
        company: contactValues['company']!,
        image: image,
        designation: contactValues['designation']!,
      );

      //* passing contact model in provider for next screen
      ref.read(contactModelProvider.notifier).getContactModel(contact);

      ctx.goNamed(FormScreen.routeName);
    } else {
      showErrordialog(
        ctx,
        'Required Fields',
        'Name and Phone number are required fields.',
      );
    }
  }
}

//* Chip widget each containing item to be dragged
class LineItem extends StatelessWidget {
  final String line;

  const LineItem({super.key, required this.line});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context);
    return Draggable(
      data: line,
      dragAnchorStrategy: childDragAnchorStrategy,
      feedback: Chip(
        elevation: 8,
        key: GlobalKey(),
        side: BorderSide.none,
        backgroundColor: style.colorScheme.primaryContainer,
        label: Text(line, style: style.textTheme.bodyMedium),
        shadowColor: style.colorScheme.background.withOpacity(0.5),
      ),
      child: Chip(
        elevation: 8,
        backgroundColor: style.colorScheme.primaryContainer,
        label: Text(line, style: style.textTheme.bodyMedium),
        shadowColor: style.colorScheme.background.withOpacity(0.5),
      ),
    );
  }
}

//* drag target item where dragged widget need to be dropped
class DragTargetItem extends StatefulWidget {
  final String property;
  final Function(String, String) onDrop;

  const DragTargetItem({
    super.key,
    required this.onDrop,
    required this.property,
  });

  @override
  State<DragTargetItem> createState() => _DragTargetItemState();
}

class _DragTargetItemState extends State<DragTargetItem> {
  String _dragItem = '';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Text(widget.property),
        ),
        Expanded(
          flex: 2,
          child: DragTarget<String>(
            builder: (context, candidateData, rejectedData) {
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: candidateData.isNotEmpty
                      ? Border.all(color: Colors.red, width: 2)
                      : null,
                ),
                child: Text(
                  _dragItem.isEmpty ? 'Drop here' : _dragItem,
                ),
              );
            },
            onAccept: (data) {
              setState(() {
                if (_dragItem.isEmpty) {
                  _dragItem = data;
                } else {
                  if (_dragItem.length < 80) {
                    _dragItem += ' $data';
                  } else {
                    showErrorSnack(
                      context,
                      'Maximum characters reached for ${widget.property.toLowerCase()} field.',
                    );
                  }
                }
              });
              widget.onDrop(_dragItem, widget.property);
            },
          ),
        ),
        if (_dragItem.isNotEmpty)
          InkWell(
            onTap: () {
              setState(() {
                _dragItem = '';
              });
            },
            child: const Icon(Icons.clear),
          ),
      ],
    );
  }
}
