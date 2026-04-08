import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/localization.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/big_button.dart';

class EnrollmentScreen extends StatefulWidget {
  const EnrollmentScreen({super.key});

  @override
  State<EnrollmentScreen> createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends State<EnrollmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _householdSizeController = TextEditingController(text: '4');
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _householdSizeController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.go('/enrollment/success');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l('enrollment_title'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: context.l('name_label')),
                  validator: (value) {
                    if (Validators.isRequired(value)) {
                      return context.l('validation_required');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(labelText: context.l('address_label')),
                  validator: (value) {
                    if (Validators.isRequired(value)) {
                      return context.l('validation_required');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _householdSizeController,
                  decoration: InputDecoration(
                    labelText: context.l('household_size_label'),
                  ),
                  validator: (value) {
                    if (!Validators.isValidHouseholdSize(value)) {
                      return context.l('validation_invalid');
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _commentController,
                  decoration: InputDecoration(labelText: context.l('comment_label')),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                BigButton(
                  label: context.l('save_and_continue_button'),
                  icon: Icons.save_outlined,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
