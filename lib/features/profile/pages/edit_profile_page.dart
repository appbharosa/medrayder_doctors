import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/doctor_profile_model.dart';
import '../../../data/models/update_profile_request_model.dart';
import '../bloc/doctor_profile_bloc.dart';
import '../bloc/doctor_profile_event.dart';
import '../bloc/doctor_profile_state.dart';



class EditProfilePage extends StatefulWidget {
  final DoctorProfileModel profile;
  final DoctorProfileBloc bloc;

  const EditProfilePage({
    super.key,
    required this.profile,
    required this.bloc,
  });

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

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.profile.name;
    _descriptionController.text = widget.profile.description;
    _consultTypeController.text = widget.profile.consultType;
    _onlineFeeController.text = widget.profile.onlineFee.toString();
    _offlineFeeController.text = widget.profile.offlineFee.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _experienceController.dispose();
    _descriptionController.dispose();
    _consultTypeController.dispose();
    _onlineFeeController.dispose();
    _offlineFeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DoctorProfileBloc, DoctorProfileState>(
      bloc: widget.bloc, // Use the bloc passed via constructor
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
          // Navigate back to DoctorProfilePage and refresh data
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
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Edit Profile',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xff1565C0),
          elevation: 0,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        hint: 'Enter your full name',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _experienceController,
                        label: 'Experience (Years)',
                        hint: 'Enter years of experience',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        hint: 'Enter description',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _consultTypeController.text,
                        decoration: InputDecoration(
                          labelText: 'Consultation Type',
                          labelStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'online',
                            child: Text('Online'),
                          ),
                          DropdownMenuItem(
                            value: 'offline',
                            child: Text('Offline'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _consultTypeController.text = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _onlineFeeController,
                        label: 'Online Fee',
                        hint: 'Enter online fee',
                        keyboardType: TextInputType.number,
                        prefixText: '₹ ',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _offlineFeeController,
                        label: 'Offline Fee',
                        hint: 'Enter offline fee',
                        keyboardType: TextInputType.number,
                        prefixText: '₹ ',
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            // Update Profile Button at the Bottom
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final request = UpdateProfileRequestModel(
                        name: _nameController.text.trim(),
                        exp: int.tryParse(_experienceController.text.trim()) ?? 0,
                        description: _descriptionController.text.trim(),
                        consultType: _consultTypeController.text.trim(),
                        onlineFee: int.tryParse(_onlineFeeController.text.trim()) ?? 0,
                        offlineFee: int.tryParse(_offlineFeeController.text.trim()) ?? 0,
                      );
                      widget.bloc.add(UpdateDoctorProfile(request));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff1565C0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Update Profile',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey,
        ),
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
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