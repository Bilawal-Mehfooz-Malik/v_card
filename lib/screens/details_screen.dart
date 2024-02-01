import 'dart:io';
import 'package:flutter/material.dart';
import 'package:v_card/models/contact_model.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:v_card/providers/contact_provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class DetailsScreen extends ConsumerStatefulWidget {
  static const String routeName = 'details';
  final int id;

  const DetailsScreen({super.key, required this.id});

  @override
  ConsumerState<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends ConsumerState<DetailsScreen> {
  late int _id;

  @override
  void initState() {
    _id = widget.id;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
      ),
      body: FutureBuilder<ContactModel>(
        future: ref.read(contactProvider.notifier).getContactById(_id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final contact = snapshot.data!;
            return _mainContent(contact, theme);
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load data'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _mainContent(ContactModel contact, ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.file(File(contact.image)),
          const SizedBox(height: 12),
          ListTile(
            title: Text(
              contact.name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            subtitle: Text(
              contact.designation == '' ? 'Designation' : contact.designation,
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.secondary,
              ),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.email),
            title: Text(contact.email == '' ? 'Email' : contact.email),
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: Text(contact.mobile),
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title:
                Text(contact.company == '' ? 'Company name' : contact.company),
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: Text(contact.address == '' ? 'Location' : contact.address),
          ),
          ListTile(
            leading: const Icon(Icons.web),
            title: Text(contact.website == '' ? 'Website' : contact.website),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomCircularButton(
                icon: Icons.call,
                text: 'Call',
                onTap: () {
                  if (contact.mobile == '') return;
                  _sendCall(contact.mobile);
                },
              ),
              CustomCircularButton(
                icon: Icons.sms,
                text: 'Message',
                onTap: () {
                  if (contact.email == '') {
                    EasyLoading.showError('No mobile number.');
                    return;
                  }
                  _sendSms(contact.mobile);
                },
              ),
              CustomCircularButton(
                icon: Icons.mail,
                text: 'Mail',
                onTap: () {
                  if (contact.email == '') {
                    EasyLoading.showError('No email address.');
                    return;
                  }
                  _sendMail(contact.email);
                },
              ),
              CustomCircularButton(
                icon: Icons.web,
                text: 'website',
                onTap: () {
                  if (contact.website == '') {
                    EasyLoading.showError('Website address not found.');
                    return;
                  }
                  _goToWeb(contact.website);
                },
              ),
              CustomCircularButton(
                icon: Icons.location_on,
                text: 'Location',
                onTap: () {
                  if (contact.address == '') {
                    EasyLoading.showError('Location not found.');
                    return;
                  }
                  _goToLocation(contact.address);
                },
              )
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _sendCall(String phoneNumber) async {
    EasyLoading.show();
    final url = 'tel:$phoneNumber';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
      EasyLoading.dismiss();
    } else {
      EasyLoading.showError('Failed!');
    }
  }

  void _sendSms(String phoneNumber) async {
    EasyLoading.show();
    final url = 'sms:$phoneNumber';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
      EasyLoading.dismiss();
    } else {
      EasyLoading.showError('Failed!');
    }
  }

  void _sendMail(String email) async {
    EasyLoading.show();
    final url = 'mailto:$email';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
      EasyLoading.dismiss();
    } else {
      EasyLoading.showError('Failed!');
    }
  }

  void _goToWeb(String website) async {
    EasyLoading.show();
    final url = 'https://$website';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
      EasyLoading.dismiss();
    } else {
      EasyLoading.showError('Failed!');
    }
  }

  void _goToLocation(String address) async {
    EasyLoading.show();
    String url = '';
    if (Platform.isAndroid) {
      url = 'geo:0,0?q=$address';
    } else {
      url = 'http://maps.apple.com/?q=$address';
    }
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
      EasyLoading.dismiss();
    } else {
      EasyLoading.showError('Failed!');
    }
  }
}

class CustomCircularButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final void Function() onTap;

  const CustomCircularButton(
      {super.key, required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(icon, size: 28),
          ),
          const SizedBox(height: 8),
          Text(text),
        ],
      ),
    );
  }
}
