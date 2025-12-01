import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../services/owner_service.dart';
import '../../utils/theme.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_textfield.dart';

class OwnerKycScreen extends StatefulWidget {
  const OwnerKycScreen({super.key});

  @override
  State<OwnerKycScreen> createState() => _OwnerKycScreenState();
}

class _OwnerKycScreenState extends State<OwnerKycScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  // Form keys for each page
  final _page1FormKey = GlobalKey<FormState>();
  final _page2FormKey = GlobalKey<FormState>();
  final _page3FormKey = GlobalKey<FormState>();

  // Page 1 - Basic Information

  final _panNumberController = TextEditingController();
  final _addressController = TextEditingController();

  final _phoneController = TextEditingController();

  // Page 2 - Additional KYC
  final _bankAccountController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _citizenshipNumberController = TextEditingController();
  final _ownerNameController = TextEditingController();

  // Page 3 - Documents
  File? _profilePhoto;
  File? _citizenshipFront;
  File? _citizenshipBack;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _pageController.dispose();

    _panNumberController.dispose();
    _addressController.dispose();

    _phoneController.dispose();
    _bankAccountController.dispose();
    _bankNameController.dispose();
    _citizenshipNumberController.dispose();
    _ownerNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageType type) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          switch (type) {
            case ImageType.profile:
              _profilePhoto = File(image.path);
              break;
            case ImageType.citizenshipFront:
              _citizenshipFront = File(image.path);
              break;
            case ImageType.citizenshipBack:
              _citizenshipBack = File(image.path);
              break;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackbar(
          context,
          'Failed to pick image: ${e.toString()}',
          isError: true,
        );
      }
    }
  }

  void _nextPage() {
    bool isValid = false;

    switch (_currentPage) {
      case 0:
        isValid = _page1FormKey.currentState?.validate() ?? false;
        break;
      case 1:
        isValid = _page2FormKey.currentState?.validate() ?? false;
        break;
      case 2:
        isValid = _validateDocuments();
        break;
    }

    if (isValid) {
      if (_currentPage < 2) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _submitForm();
      }
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateDocuments() {
    if (_profilePhoto == null) {
      Helpers.showSnackbar(context, 'Please upload profile photo', isError: true);
      return false;
    }
    if (_citizenshipFront == null) {
      Helpers.showSnackbar(context, 'Please upload citizenship front', isError: true);
      return false;
    }
    if (_citizenshipBack == null) {
      Helpers.showSnackbar(context, 'Please upload citizenship back', isError: true);
      return false;
    }
    return true;
  }

  Future<void> _submitForm() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final ownerService = OwnerService();

      // Prepare additionalKyc data (excluding phoneNumber as it's sent separately)
      final additionalKyc = {
        'bankAccount': _bankAccountController.text.trim(),
        'bankName': _bankNameController.text.trim(),
        'citizenshipNumber': _citizenshipNumberController.text.trim(),
        'ownerName': _ownerNameController.text.trim(),
      };

      // Call API to activate owner mode
      final authResponse = await ownerService.activateOwnerMode(
        panNumber: _panNumberController.text.trim(),
        address: _addressController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        profilePhoto: _profilePhoto!,
        citizenshipFront: _citizenshipFront!,
        citizenshipBack: _citizenshipBack!,
        additionalKyc: additionalKyc,
      );

      if (!mounted) return;

      // Update user in auth provider
      await authProvider.updateUser(authResponse.user);

      // Show success message
      Helpers.showSnackbar(
        context,
        'Owner KYC submitted successfully! Status: Pending approval.',
      );

      // Navigate back
      context.pop();
    } catch (e) {
      if (mounted) {
        Helpers.showSnackbar(
          context,
          'KYC submission failed: ${e.toString()}',
          isError: true,
        );
      }
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
        title: const Text('Owner KYC Verification'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(),
          // Page Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              children: [
                _buildPage1(),
                _buildPage2(),
                _buildPage3(),
              ],
            ),
          ),
          // Navigation Buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingM),
      child: Row(
        children: [
          _buildProgressStep(0, 'Basic Info'),
          _buildProgressLine(0),
          _buildProgressStep(1, 'KYC Details'),
          _buildProgressLine(1),
          _buildProgressStep(2, 'Documents'),
        ],
      ),
    );
  }

  Widget _buildProgressStep(int step, String label) {
    final isActive = _currentPage >= step;
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive ? AppTheme.primaryColor : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${step + 1}',
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? AppTheme.primaryColor : Colors.grey[600],
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressLine(int step) {
    final isActive = _currentPage > step;
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? AppTheme.primaryColor : Colors.grey.shade300,
        margin: const EdgeInsets.only(bottom: 24),
      ),
    );
  }

  Widget _buildPage1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingL),
      child: Form(
        key: _page1FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your futsal court details',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            const SizedBox(height: 20),
            AppTextField(
              label: 'PAN Number',
              hint: 'Enter your PAN number',
              controller: _panNumberController,
              validator: (value) => Validators.required(value, 'PAN number'),
              prefixIcon: const Icon(Icons.credit_card),
            ),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Address',
              hint: 'Enter futsal address',
              controller: _addressController,
              validator: (value) => Validators.required(value, 'Address'),
              prefixIcon: const Icon(Icons.location_on),
              maxLines: 2,
            ),
            const SizedBox(height: 20),

            const SizedBox(height: 20),
            AppTextField(
              label: 'Phone Number',
              hint: 'Enter contact number',
              controller: _phoneController,
              validator: Validators.phoneNumber,
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(Icons.phone),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingL),
      child: Form(
        key: _page2FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'KYC Details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Additional verification information',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: 'Owner Full Name',
              hint: 'Enter owner name as per citizenship',
              controller: _ownerNameController,
              validator: Validators.name,
              prefixIcon: const Icon(Icons.person),
            ),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Citizenship Number',
              hint: 'Enter your citizenship number',
              controller: _citizenshipNumberController,
              validator: (value) => Validators.required(value, 'Citizenship number'),
              prefixIcon: const Icon(Icons.badge),
            ),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Bank Name',
              hint: 'Enter your bank name',
              controller: _bankNameController,
              validator: (value) => Validators.required(value, 'Bank name'),
              prefixIcon: const Icon(Icons.account_balance),
            ),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Bank Account Number',
              hint: 'Enter your account number',
              controller: _bankAccountController,
              validator: (value) => Validators.required(value, 'Account number'),
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.account_balance_wallet),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingL),
      child: Form(
        key: _page3FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload Documents',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Upload required verification documents',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            _buildImageUploadCard(
              title: 'Profile Photo',
              subtitle: 'Upload a clear photo of yourself',
              file: _profilePhoto,
              onTap: () => _pickImage(ImageType.profile),
              icon: Icons.person,
            ),
            const SizedBox(height: 16),
            _buildImageUploadCard(
              title: 'Citizenship Front',
              subtitle: 'Upload front side of citizenship',
              file: _citizenshipFront,
              onTap: () => _pickImage(ImageType.citizenshipFront),
              icon: Icons.credit_card,
            ),
            const SizedBox(height: 16),
            _buildImageUploadCard(
              title: 'Citizenship Back',
              subtitle: 'Upload back side of citizenship',
              file: _citizenshipBack,
              onTap: () => _pickImage(ImageType.citizenshipBack),
              icon: Icons.credit_card,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadCard({
    required String title,
    required String subtitle,
    required File? file,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: file != null
                      ? AppTheme.primaryColor.withValues(alpha: 0.1)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: file != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    file,
                    fit: BoxFit.cover,
                  ),
                )
                    : Icon(
                  icon,
                  size: 40,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      file != null ? 'Tap to change' : subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                file != null ? Icons.check_circle : Icons.upload,
                color: file != null ? AppTheme.successColor : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: AppButton(
                text: 'Back',
                onPressed: _previousPage,
                isOutlined: true,
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 16),
          Expanded(
            flex: _currentPage > 0 ? 1 : 2,
            child: AppButton(
              text: _currentPage == 2 ? 'Submit' : 'Next',
              onPressed: _nextPage,
              isLoading: _isLoading,
            ),
          ),
        ],
      ),
    );
  }
}

enum ImageType {
  profile,
  citizenshipFront,
  citizenshipBack,
}