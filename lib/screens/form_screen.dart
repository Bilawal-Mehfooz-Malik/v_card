import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:v_card/models/contact_model.dart';
import 'package:v_card/screens/home_screen.dart';
import 'package:v_card/shared/elevated_button.dart';
import 'package:v_card/widgets/custom_textfield.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:v_card/providers/contact_provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:v_card/routers/providers/contact_modal_provider.dart';

class FormScreen extends ConsumerStatefulWidget {
  static const String routeName = 'form';

  const FormScreen({super.key});

  @override
  ConsumerState<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends ConsumerState<FormScreen> {
  late ContactModel contactModel;
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final addressController = TextEditingController();
  final companyController = TextEditingController();
  final websiteController = TextEditingController();
  final designationController = TextEditingController();

  @override
  void initState() {
    contactModel = ref.read(contactModelProvider.notifier).contactModal;
    nameController.text = contactModel.name;
    emailController.text = contactModel.email;
    mobileController.text = contactModel.mobile;
    addressController.text = contactModel.address;
    companyController.text = contactModel.company;
    websiteController.text = contactModel.website;
    designationController.text = contactModel.designation;
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    addressController.dispose();
    companyController.dispose();
    designationController.dispose();
    websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(contactModel.name)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ListView(
                  children: [
                    CustomTextFormField(
                      labelText: 'Name',
                      controller: nameController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'This Field must not be empty';
                        }
                        return null;
                      },
                    ),
                    CustomTextFormField(
                      labelText: 'Phone number',
                      keyType: TextInputType.number,
                      controller: mobileController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'This Field must not be empty';
                        }
                        return null;
                      },
                    ),
                    CustomTextFormField(
                      labelText: 'Company name',
                      controller: companyController,
                      validator: (value) {
                        return null;
                      },
                    ),
                    CustomTextFormField(
                      labelText: 'Designation',
                      controller: designationController,
                      validator: (value) {
                        return null;
                      },
                    ),
                    CustomTextFormField(
                      labelText: 'Email address',
                      controller: emailController,
                      keyType: TextInputType.emailAddress,
                      validator: (value) {
                        return null;
                      },
                    ),
                    CustomTextFormField(
                      labelText: 'Address',
                      controller: addressController,
                      keyType: TextInputType.streetAddress,
                      validator: (value) {
                        return null;
                      },
                    ),
                    CustomTextFormField(
                      labelText: 'Website',
                      keyType: TextInputType.url,
                      controller: websiteController,
                      validator: (value) {
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: CustomElevatedButton(onPressed: saveContact, text: 'Save'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void saveContact() async {
    if (_formKey.currentState!.validate()) {
      contactModel.name = nameController.text;
      contactModel.email = emailController.text;
      contactModel.mobile = mobileController.text;
      contactModel.address = addressController.text;
      contactModel.company = companyController.text;
      contactModel.website = websiteController.text;
      contactModel.designation = designationController.text;
    }
    ref
        .read(contactProvider.notifier)
        .insertContact(contactModel)
        .then((value) async {
      if (value > 0) {
        EasyLoading.show(status: 'Saving...');
        await Future.delayed(const Duration(seconds: 1));
        EasyLoading.showSuccess('Saved');
        if (mounted) {
          context.goNamed(HomeScreen.routeName);
        }
      }
    }).catchError(
      (error) {
        debugPrint('Error saving contact: $error');
        EasyLoading.showError('Failed to save');
      },
    );
  }
}
