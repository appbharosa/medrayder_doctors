import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/di/injection.dart' as di;
import '../../../data/models/doctor_profile_model.dart';
import '../bloc/doctor_profile_bloc.dart';
import '../bloc/doctor_profile_event.dart';
import '../bloc/doctor_profile_state.dart';
import 'edit_profile_page.dart';


class DoctorProfilePage extends StatefulWidget {
  const DoctorProfilePage({super.key});

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  late final DoctorProfileBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = di.sl<DoctorProfileBloc>()..add(FetchDoctorProfile());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Doctor Profile',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xff1565C0),
          elevation: 0,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            BlocBuilder<DoctorProfileBloc, DoctorProfileState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: state is DoctorProfileLoaded
                      ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfilePage(
                          profile: state.profile,
                          bloc: context.read<DoctorProfileBloc>(),
                        ),
                      ),
                    ).then((_) {
                      context.read<DoctorProfileBloc>().add(FetchDoctorProfile());
                    });
                  }
                      : null,
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<DoctorProfileBloc, DoctorProfileState>(
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
          builder: (context, state) {
            if (state is DoctorProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DoctorProfileLoaded) {
              return _buildProfileContent(context, state.profile);
            } else if (state is DoctorProfileError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.error),
                    ElevatedButton(
                      onPressed: () => context.read<DoctorProfileBloc>().add(FetchDoctorProfile()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff1565C0),
                      ),
                      child: const Text('Retry', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, DoctorProfileModel profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile Image
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[200],
            backgroundImage: profile.image.isNotEmpty ? NetworkImage(profile.image) : null,
            child: profile.image.isEmpty
                ? const Icon(Icons.person, size: 60, color: Colors.grey)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            profile.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            profile.specialization,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: profile.consultType == 'online'
                  ? Colors.blue.shade100
                  : Colors.green.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              profile.consultType.toUpperCase(),
              style: TextStyle(
                color: profile.consultType == 'online'
                    ? Colors.blue[800]
                    : Colors.green[800],
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Info Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _infoRow('Mobile', profile.mobile),
                  const Divider(height: 1, color: Colors.grey),
                  _infoRow('Offline Fee', '₹${profile.offlineFee}'),
                  const Divider(height: 1, color: Colors.grey),
                  _infoRow('Online Fee', '₹${profile.onlineFee}'),
                  const Divider(height: 1, color: Colors.grey),
                  _infoRow('Status', profile.status == 1 ? 'Active' : 'Inactive'),
                  const Divider(height: 1, color: Colors.grey),
                  _infoRow('Created On', profile.createdOn),
                  const Divider(height: 1, color: Colors.grey),
                  _infoRow('Modified On', profile.modifiedOn),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // About Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    profile.description.isNotEmpty
                        ? profile.description
                        : 'No description provided',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEdit(BuildContext context) {
    final bloc = context.read<DoctorProfileBloc>();
    final state = bloc.state;
    if (state is DoctorProfileLoaded) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EditProfilePage(profile: state.profile, bloc: bloc),
        ),
      ).then((_) {
        bloc.add(FetchDoctorProfile());
      });
    } else {
      // If not loaded, show a snackbar or loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait, profile is loading...'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}