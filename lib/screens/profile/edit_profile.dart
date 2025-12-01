import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_textfield.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final currentUser = authProvider.user;

      if (currentUser == null) {
        throw Exception('User not found');
      }

      // Create updated user
      final updatedUser = currentUser.copyWith(
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      // Update local user data
      await authProvider.updateUser(updatedUser);

      if (!mounted) return;

      Helpers.showSnackbar(context, 'Profile updated successfully');
      context.pop();
    } catch (e) {
      if (!mounted) return;
      Helpers.showSnackbar(
        context,
        'Failed to update profile: ${e.toString()}',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.paddingL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                // Avatar
                Center(
                  child: Stack(
                    children: [
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, _) {
                          return CircleAvatar(
                            radius: 60,
                            backgroundColor: AppTheme.primaryColor,
                            child: Text(
                              authProvider.user?.fullName.isNotEmpty ?? false
                                  ? authProvider.user!.fullName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Full Name
                AppTextField(
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  controller: _fullNameController,
                  validator: Validators.name,
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                const SizedBox(height: 20),
                // Phone Number
                AppTextField(
                  label: 'Phone Number',
                  hint: 'Enter your phone number',
                  controller: _phoneController,
                  validator: Validators.phoneNumber,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
                const SizedBox(height: 20),
                // Email (Read-only)
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return AppTextField(
                      label: 'Email',
                      controller: TextEditingController(
                        text: authProvider.user?.email ?? '',
                      ),
                      enabled: false,
                      prefixIcon: const Icon(Icons.email_outlined),
                    );
                  },
                ),
                const SizedBox(height: 32),
                // Save Button
                AppButton(
                  text: 'Save Changes',
                  onPressed: _handleSave,
                  isLoading: _isLoading,
                  icon: Icons.check,
                ),
                const SizedBox(height: 16),
                // Cancel Button
                AppButton(
                  text: 'Cancel',
                  onPressed: () => context.pop(),
                  isOutlined: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}