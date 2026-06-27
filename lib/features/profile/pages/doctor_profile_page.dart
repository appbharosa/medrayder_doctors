import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart' as di;
import '../../../data/models/doctor_profile_model.dart';
import '../bloc/doctor_profile_bloc.dart';
import '../bloc/doctor_profile_event.dart';
import '../bloc/doctor_profile_state.dart';
import 'edit_profile_page.dart';

class DoctorProfilePage extends StatefulWidget {
  const DoctorProfilePage({super.key});

  @override
  State<DoctorProfilePage> createState() =>
      _DoctorProfilePageState();
}

class _DoctorProfilePageState
    extends State<DoctorProfilePage> {

  late final DoctorProfileBloc _bloc;

  @override
  void initState() {
    super.initState();

    _bloc = di.sl<DoctorProfileBloc>()
      ..add(FetchDoctorProfile());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FB),

        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,

          title: const Text(
            "Doctor Profile",
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black87,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            BlocBuilder<DoctorProfileBloc, DoctorProfileState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Color(0xFF0A8FDC),),
                  onPressed:
                  state is DoctorProfileLoaded ? () {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) =>
                            EditProfilePage(profile: state.profile,bloc: context.read<DoctorProfileBloc>()),
                      ),
                    ).then((_) {
                      context.read<DoctorProfileBloc>().add(
                        FetchDoctorProfile(),
                      );
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
                SnackBar(content:
                  Text(state.message), backgroundColor: Colors.green,),
              );
            }
            if (state is DoctorProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.error), backgroundColor: Colors.red,
                ),
              );
            }
          },

          builder: (context, state) {
            if (state
            is DoctorProfileLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is DoctorProfileLoaded) {
              return _buildProfileContent(
                state.profile,
              );
            }
            if (state is DoctorProfileError) {
              return Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),

                    const SizedBox(height: 15),

                    Text(state.error),

                    const SizedBox(height: 15),

                    ElevatedButton(
                      onPressed: () { context.read<DoctorProfileBloc>().add(
                          FetchDoctorProfile(),
                        );
                      },

                      child: const Text(
                        "Retry",
                      ),
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

  Widget _buildProfileContent(
      DoctorProfileModel profile,
      ) {

    return RefreshIndicator(

      onRefresh: () async {
        context.read<DoctorProfileBloc>().add(FetchDoctorProfile());
      },

      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0A8FDC),
                    Color(0xFF086AA7),
                  ],
                ),
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0A8FDC).withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Column(
                children: [
                  CircleAvatar(radius: 45, backgroundColor: Colors.white,

                    backgroundImage: profile.image.isNotEmpty ? NetworkImage(profile.image,) : null,

                    child: profile.image.isEmpty
                        ? const Icon(
                      Icons.person,
                      size: 45,
                      color: Color(
                        0xFF0A8FDC,
                      ),
                    )
                        : null,
                  ),

                  const SizedBox(height: 15),

                  /// NAME
                  Text(
                    profile.name,

                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// QUALIFICATION
                  Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white
                          .withOpacity(0.18),

                      borderRadius:
                      BorderRadius.circular(20),
                    ),

                    child: Text(
                      profile.qualification,

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,

                    children: [

                      _topStat(
                        Icons.work_outline,
                        "${profile.exp} yrs",
                        "Experience",
                      ),

                      _topStat(
                        Icons.currency_rupee,
                        "₹${profile.onlineFee}",
                        "Fee",
                      ),

                      _topStat(
                        Icons.star_outline,
                        profile.status == 1
                            ? "Active"
                            : "Inactive",
                        "Status",
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// DETAILS SECTION
            _profileTile(
              Icons.phone,
              "Mobile Number",
              profile.mobile,
            ),

            _profileTile(
              Icons.badge_outlined,
              "Registration Number",
              profile.uniqueId,
            ),

            _profileTile(
              Icons.access_time,
              "Open Time",
              profile.openTime.isNotEmpty
                  ? profile.openTime
                  : "Not Set",
            ),

            _profileTile(
              Icons.lock_clock,
              "Close Time",
              profile.closeTime.isNotEmpty
                  ? profile.closeTime
                  : "Not Set",
            ),

            _profileTile(
              Icons.calendar_today_outlined,
              "Created On",
              profile.createdOn,
            ),

            _profileTile(
              Icons.type_specimen,
              "Consultation Type",
              profile.consultType,
            ),
            _profileTile(
              Icons.info_outline,
              "About Doctor",
              profile.description.isNotEmpty
                  ? profile.description
                  : "No description available",
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// PROFILE TILE
  Widget _profileTile(
      IconData icon,
      String title,
      String value,
      ) {

    return Container(

      margin:
      const EdgeInsets.only(bottom: 14),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(18),

        boxShadow: [

          BoxShadow(
            color:
            Colors.grey.withOpacity(0.08),

            blurRadius: 10,

            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Container(
            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: const Color(0xFF0A8FDC)
                  .withOpacity(0.1),

              borderRadius:
              BorderRadius.circular(14),
            ),

            child: Icon(
              icon,
              color: const Color(0xFF0A8FDC),
              size: 22,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  title,

                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight:
                    FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  value,

                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight:
                    FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// TOP STATUS CARD
  Widget _topStat(
      IconData icon,
      String value,
      String label,
      ) {

    return Column(
      children: [

        Icon(
          icon,
          color: Colors.white,
          size: 22,
        ),

        const SizedBox(height: 6),

        Text(
          value,

          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          label,

          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}