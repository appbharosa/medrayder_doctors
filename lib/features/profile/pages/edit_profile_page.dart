import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/doctor_profile_model.dart';
import '../../../data/models/update_profile_request_model.dart';
import '../bloc/doctor_profile_bloc.dart';
import '../bloc/doctor_profile_event.dart';
import '../bloc/doctor_profile_state.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';


class EditProfilePage extends StatefulWidget {
  final DoctorProfileModel profile;
  final DoctorProfileBloc bloc;

  const EditProfilePage({super.key, required this.profile, required this.bloc});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _consultTypeController = TextEditingController();
  final TextEditingController _onlineFeeController = TextEditingController();
  final TextEditingController _offlineFeeController = TextEditingController();
  final TextEditingController _qualificationController = TextEditingController();
  final TextEditingController _openTimeController = TextEditingController();
  final TextEditingController _closeTimeController = TextEditingController();

  File? _imageFile;
  String? _existingImageUrl;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.profile.name;
    _experienceController.text = widget.profile.exp.toString();
    _descriptionController.text = widget.profile.description;
    _consultTypeController.text = widget.profile.consultType;
    _onlineFeeController.text = widget.profile.onlineFee.toString();
    _offlineFeeController.text = widget.profile.offlineFee.toString();
    _qualificationController.text = widget.profile.qualification;
    _openTimeController.text = widget.profile.openTime;
    _closeTimeController.text = widget.profile.closeTime;
    _existingImageUrl = widget.profile.image;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _experienceController.dispose();
    _descriptionController.dispose();
    _consultTypeController.dispose();
    _onlineFeeController.dispose();
    _offlineFeeController.dispose();
    _qualificationController.dispose();
    _openTimeController.dispose();
    _closeTimeController.dispose();
    super.dispose();
  }

  // ---------- IMAGE PICKING ----------
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose Profile Photo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _imagePickerOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  _imagePickerOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                  _imagePickerOption(
                    icon: Icons.close,
                    label: 'Cancel',
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey.shade200,
            child: Icon(icon, size: 28, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // ---------- BUILD ----------
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      top: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            widget.profile.id != 0 ? 'Update Profile' : 'Add Profile',
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocListener<DoctorProfileBloc, DoctorProfileState>(
          bloc: widget.bloc,
          listener: (context, state) {
            if (state is DoctorProfileUpdateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
              Navigator.pop(context, true);
            } else if (state is DoctorProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
              setState(() => _isUpdating = false);
            }
          },
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // ----- Profile Image with Camera Overlay -----
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: _imageFile != null
                                  ? FileImage(_imageFile!)
                                  : (_existingImageUrl != null && _existingImageUrl!.isNotEmpty
                                  ? NetworkImage(_existingImageUrl!)
                                  : null),
                              child: (_imageFile == null && (_existingImageUrl == null || _existingImageUrl!.isEmpty))
                                  ? const Icon(Icons.person, size: 60, color: Colors.grey)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _showImagePickerDialog,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Color(0xff1565C0),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ----- FORM FIELDS (reordered) -----

                        // 1. Full Name
                        _buildTextField(
                          controller: _nameController,
                          label: 'Full Name',
                          hint: 'Enter your full name',
                        ),
                        const SizedBox(height: 16),

                        // 2. Qualification
                        _buildTextField(
                          controller: _qualificationController,
                          label: 'Qualification',
                          hint: 'e.g., MBBS, MD',
                        ),
                        const SizedBox(height: 16),

                        // 3. Experience
                        _buildTextField(
                          controller: _experienceController,
                          label: 'Experience (Years)',
                          hint: 'Enter years of experience',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),

                        // 4. Open Time
                        _buildTextField(
                          controller: _openTimeController,
                          label: 'Open Time',
                          hint: 'e.g., 09:00 AM',
                        ),
                        const SizedBox(height: 16),

                        // 5. Close Time
                        _buildTextField(
                          controller: _closeTimeController,
                          label: 'Close Time',
                          hint: 'e.g., 06:00 PM',
                        ),
                        const SizedBox(height: 16),

                        // 6. Online Fee
                        _buildTextField(
                          controller: _onlineFeeController,
                          label: 'Online Fee',
                          hint: 'Enter online consultation fee',
                          keyboardType: TextInputType.number,
                          prefixText: '₹ ',
                        ),
                        const SizedBox(height: 16),

                        // 7. Offline Fee
                        _buildTextField(
                          controller: _offlineFeeController,
                          label: 'Offline Fee',
                          hint: 'Enter offline consultation fee',
                          keyboardType: TextInputType.number,
                          prefixText: '₹ ',
                        ),
                        const SizedBox(height: 16),

                        // 8. Consultation Type (Dropdown)
                        DropdownButtonFormField<String>(
                          value: _consultTypeController.text.isNotEmpty
                              ? _consultTypeController.text
                              : null,
                          decoration: const InputDecoration(
                            labelText: 'Consultation Type',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'online', child: Text('Online')),
                            DropdownMenuItem(value: 'offline', child: Text('Offline')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _consultTypeController.text = value!;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select consultation type';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // 9. Description (moved below consultation type)
                        _buildTextField(
                          controller: _descriptionController,
                          label: 'Description',
                          hint: 'About yourself',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 30),

                        // ----- Submit Button -----
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isUpdating ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff1565C0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isUpdating
                                ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : Text(
                              widget.profile.id != 0 ? 'Update Profile' : 'Save',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Full-screen loading overlay
              if (_isUpdating)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- FORM SUBMISSION ----------
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUpdating = true);

    final request = UpdateProfileRequestModel(
      name: _nameController.text.trim(),
      exp: int.tryParse(_experienceController.text.trim()) ?? 0,
      qualification: _qualificationController.text.trim(),
      description: _descriptionController.text.trim(),
      consultType: _consultTypeController.text.trim(),
      onlineFee: int.tryParse(_onlineFeeController.text.trim()) ?? 0,
      offlineFee: int.tryParse(_offlineFeeController.text.trim()) ?? 0,
      openTime: _openTimeController.text.trim(),
      closeTime: _closeTimeController.text.trim(),
      image: _imageFile,
    );

    widget.bloc.add(UpdateDoctorProfile(request));
  }

  // ---------- HELPER WIDGETS ----------
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String prefixText = '',
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        prefixText: prefixText,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }
}