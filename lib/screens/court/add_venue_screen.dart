import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/venue_provider.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/loading.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_textfield.dart';

class AddVenueScreen extends StatefulWidget {
  const AddVenueScreen({super.key});

  @override
  State<AddVenueScreen> createState() => _AddVenueScreenState();
}

class _AddVenueScreenState extends State<AddVenueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Court Data
  final _courtNameController = TextEditingController(text: 'Court A');
  final _courtPriceController = TextEditingController();
  String _courtSize = '5v5';
  
  // Image Data
  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  String _selectedCity = 'Kathmandu';
  final List<String> _cities = ['Kathmandu', 'Lalitpur', 'Bhaktapur'];
  final List<String> _courtSizes = ['5v5', '7v7', '6v6'];

  final List<String> _availableAmenities = [
    'Parking',
    'Changing Room',
    'Showers',
    'Canteen',
    'WiFi',
    'Lockers',
    'First Aid',
    'Seating Area'
  ];
  final List<String> _selectedAmenities = [];

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    _courtNameController.dispose();
    _courtPriceController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images.map((img) => File(img.path)));
        });
      }
    } catch (e) {
      Helpers.showSnackbar(context, 'Failed to pick images', isError: true);
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _toggleAmenity(String amenity) {
    setState(() {
      if (_selectedAmenities.contains(amenity)) {
        _selectedAmenities.remove(amenity);
      } else {
        _selectedAmenities.add(amenity);
      }
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedAmenities.isEmpty) {
      Helpers.showSnackbar(context, 'Please select at least one amenity', isError: true);
      return;
    }
    
    if (_selectedImages.isEmpty) {
      Helpers.showSnackbar(context, 'Please select at least one venue image', isError: true);
      return;
    }

    final success = await context.read<VenueProvider>().createVenue(
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      city: _selectedCity,
      phoneNumber: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      description: _descriptionController.text.trim(),
      amenities: _selectedAmenities,
      imageFiles: _selectedImages,
      courtName: _courtNameController.text.trim(),
      courtPrice: double.parse(_courtPriceController.text.trim()),
      courtSize: _courtSize,
    );

    if (success && mounted) {
      Helpers.showSnackbar(context, 'Venue added successfully!');
      context.pop();
    } else if (mounted) {
      final error = context.read<VenueProvider>().errorMessage;
      Helpers.showSnackbar(context, error ?? 'Failed to add venue', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Venue'),
      ),
      body: Consumer<VenueProvider>(
        builder: (context, provider, _) {
          return LoadingOverlay(
            isLoading: provider.isLoading,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.paddingM),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                   // Image Picker
                    GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: _selectedImages.isEmpty
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text('Tap to add venue images', style: TextStyle(color: Colors.grey)),
                                ],
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.all(8),
                                scrollDirection: Axis.horizontal,
                                itemCount: _selectedImages.length + 1,
                                separatorBuilder: (_, __) => const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  if (index == _selectedImages.length) {
                                    return GestureDetector(
                                      onTap: _pickImages,
                                      child: Container(
                                        width: 150,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.grey[300]!),
                                        ),
                                        child: const Icon(Icons.add_a_photo, color: Colors.grey),
                                      ),
                                    );
                                  }
                                  
                                  return Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          _selectedImages[index],
                                          width: 200,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () => _removeImage(index),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_selectedImages.isNotEmpty)
                      const Text(
                        'Tap + to add more images',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    const SizedBox(height: 24),

                    AppTextField(
                      controller: _nameController,
                      label: 'Venue Name',
                      hint: 'Enter venue name',
                      validator: (value) => value?.isEmpty ?? true ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    AppTextField(
                      controller: _addressController,
                      label: 'Address',
                      hint: 'Enter detailed address',
                      validator: (value) => value?.isEmpty ?? true ? 'Address is required' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    DropdownButtonFormField<String>(
                      value: _selectedCity,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        border: OutlineInputBorder(),
                      ),
                      items: _cities.map((city) {
                        return DropdownMenuItem(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedCity = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    AppTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      hint: 'Contact number',
                      keyboardType: TextInputType.phone,
                      validator: (value) => value?.isEmpty ?? true ? 'Phone number is required' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    AppTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'Contact email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Email is required';
                        if (!value.contains('@')) return 'Invalid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    AppTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      hint: 'Describe your venue...',
                      maxLines: 3,
                      validator: (value) => value?.isEmpty ?? true ? 'Description is required' : null,
                    ),
                    const SizedBox(height: 24),
                    
                    const Text(
                      'Amenities',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _availableAmenities.map((amenity) {
                        final isSelected = _selectedAmenities.contains(amenity);
                        return FilterChip(
                          label: Text(amenity),
                          selected: isSelected,
                          onSelected: (_) => _toggleAmenity(amenity),
                          checkmarkColor: Colors.white,
                          selectedColor: AppTheme.primaryColor,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    const Divider(height: 32),
                    
                    const Text(
                      'Initial Court Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    AppTextField(
                      controller: _courtNameController,
                      label: 'Court Name',
                      hint: 'e.g. Court A',
                      validator: (value) => value?.isEmpty ?? true ? 'Court name is required' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    AppTextField(
                      controller: _courtPriceController,
                      label: 'Price per Hour (Rs.)',
                      hint: 'e.g. 1200',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                         if (value == null || value.isEmpty) return 'Price is required';
                         if (double.tryParse(value) == null) return 'Invalid price';
                         return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    DropdownButtonFormField<String>(
                      value: _courtSize,
                      decoration: const InputDecoration(
                        labelText: 'Court Size',
                        border: OutlineInputBorder(),
                      ),
                      items: _courtSizes.map((size) {
                        return DropdownMenuItem(
                          value: size,
                          child: Text(size),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _courtSize = value);
                        }
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    
                    AppButton(
                      text: 'Add Venue',
                      onPressed: _submitForm,
                      isLoading: provider.isLoading,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
