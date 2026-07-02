import 'package:doctors/data/models/prescription_response_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/app_colors/app_colors.dart';
import '../../../domain/entities/booking_history.dart';


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/app_colors/app_colors.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../../domain/entities/booking_history.dart';
import '../bloc/booking_history_bloc.dart';
import '../bloc/booking_history_event.dart';
import '../bloc/booking_history_state.dart';

class BookingHistoryScreen extends StatelessWidget {

  const BookingHistoryScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return BlocProvider(

      create: (context) =>
      di.sl<BookingHistoryBloc>()
        ..add(
          FetchBookingHistory(),
        ),

      child: Scaffold(

        backgroundColor:
        const Color(0xFFF4F7FB),

        appBar: AppBar(

          backgroundColor:
          Colors.white,

          elevation: 0,

          centerTitle: true,

          title: const Text(
            "Prescription History",

            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          leading: IconButton(

            onPressed: () {
              Navigator.pop(context);
            },

            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
            ),
          ),
        ),

        body:
        BlocBuilder<
            BookingHistoryBloc,
            BookingHistoryState>(

          builder: (context, state) {

            /// LOADING

            if (state
            is BookingHistoryLoading) {

              return const Center(
                child:
                CircularProgressIndicator(),
              );
            }

            /// ERROR

            if (state
            is BookingHistoryError) {

              return Center(

                child: Padding(

                  padding:
                  const EdgeInsets.all(
                    24,
                  ),

                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment
                        .center,

                    children: [

                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 70,
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      Text(
                        state.message,

                        textAlign:
                        TextAlign.center,

                        style:
                        const TextStyle(
                          fontSize: 15,
                          fontWeight:
                          FontWeight
                              .w500,
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      ElevatedButton(

                        onPressed: () {

                          context
                              .read<
                              BookingHistoryBloc>()
                              .add(
                            FetchBookingHistory(),
                          );
                        },

                        style:
                        ElevatedButton
                            .styleFrom(

                          backgroundColor:
                          const Color(
                            0xFF0A8FDC,
                          ),

                          elevation: 0,

                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius
                                .circular(
                              14,
                            ),
                          ),
                        ),

                        child: const Text(
                          "Retry",

                          style: TextStyle(
                            color:
                            Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            /// SUCCESS

            if (state
            is BookingHistoryLoaded) {

              if (state.bookings
                  .isEmpty) {

                return const Center(

                  child: Text(
                    "No Prescription Found",

                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                );
              }

              return ListView.builder(

                padding:
                const EdgeInsets.all(
                  16,
                ),

                itemCount:
                state.bookings.length,

                itemBuilder:
                    (context, index) {

                  final booking =
                  state.bookings[index];

                  return _buildCard(
                    booking,
                  );
                },
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildCard(
      BookingHistory booking,
      ) {

    return Container(

      margin:
      const EdgeInsets.only(
        bottom: 22,
      ),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
        BorderRadius.circular(
          24,
        ),

        boxShadow: [

          BoxShadow(
            color: Colors.black
                .withOpacity(
              0.05,
            ),

            blurRadius: 14,

            offset:
            const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          /// TOP HEADER

          Container(

            width: double.infinity,

            padding:
            const EdgeInsets.all(
              20,
            ),

            decoration: const BoxDecoration(

              borderRadius:
              BorderRadius.only(

                topLeft:
                Radius.circular(
                  24,
                ),

                topRight:
                Radius.circular(
                  24,
                ),
              ),
            ),

            child: Column(
              children: [

                SvgPicture.asset(
                  "assets/med.svg",

                  height: 55,

                ),

                const SizedBox(
                  height: 14,
                ),

                Text(
                  booking.patientName,

                  style:
                  const TextStyle(

                    fontSize: 20,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 6,
                ),

                Text(
                  "Booking ID : ${booking.bookingId}",

                  style:
                  const TextStyle(

                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
      Divider(color: Colors.black87,thickness: 0.23,),
          Padding(

            padding:
            const EdgeInsets.all(
              20,
            ),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,

              children: [

                /// PATIENT DETAILS

                const Text(
                  "Patient Details",

                  style: TextStyle(
                    fontSize: 17,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                _infoRow(
                  "Doctor",
                  booking.doctorName,
                ),

                _infoRow(
                  "Gender",
                  booking.gender,
                ),

                _infoRow(
                  "DOB",
                  booking.dob,
                ),

                _infoRow(
                  "Blood Group",
                  booking.bloodGroup,
                ),

                _infoRow(
                  "Consultation",
                  booking.consultType,
                ),

                _infoRow(
                  "Date",
                  booking.date,
                ),

                _infoRow(
                  "Time",
                  booking.time,
                ),

                const SizedBox(
                  height: 24,
                ),

                /// MEDICINES

                if (booking
                    .medicines
                    .isNotEmpty) ...[

                  const Text(
                    "Medicines",

                    style: TextStyle(
                      fontSize: 17,
                      fontWeight:
                      FontWeight
                          .bold,
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  ...booking.medicines.map(

                        (medicine) {

                      return Container(

                        width:
                        double.infinity,

                        margin:
                        const EdgeInsets
                            .only(
                          bottom: 12,
                        ),

                        padding:
                        const EdgeInsets
                            .all(14),

                        decoration:
                        BoxDecoration(

                          color:
                          const Color(
                            0xFFF7FAFC,
                          ),

                          borderRadius:
                          BorderRadius
                              .circular(
                            16,
                          ),
                        ),

                        child: Row(
                          children: [

                            Container(
                              height: 10,
                              width: 10,

                              decoration:
                              const BoxDecoration(
                                color:
                                Color(
                                  0xFF0A8FDC,
                                ),
                                shape:
                                BoxShape.circle,
                              ),
                            ),

                            const SizedBox(
                              width: 12,
                            ),

                            Expanded(
                              child:
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                                children: [

                                  Text(
                                    medicine
                                        .medicine,

                                    style:
                                    const TextStyle(
                                      fontSize:
                                      15,
                                      fontWeight:
                                      FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(
                                    height:
                                    4,
                                  ),

                                  Text(
                                    medicine
                                        .medicineTime,

                                    style:
                                    TextStyle(
                                      fontSize:
                                      13,
                                      color: Colors
                                          .grey
                                          .shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(
                    height: 10,
                  ),
                ],

                /// TESTS

                if (booking
                    .tests
                    .isNotEmpty) ...[

                  const Text(
                    "Tests",

                    style: TextStyle(
                      fontSize: 17,
                      fontWeight:
                      FontWeight
                          .bold,
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  ...booking.tests.map(

                        (test) {

                      return Container(

                        width:
                        double.infinity,

                        margin:
                        const EdgeInsets
                            .only(
                          bottom: 12,
                        ),

                        padding:
                        const EdgeInsets
                            .all(14),

                        decoration:
                        BoxDecoration(

                          color:
                          const Color(
                            0xFFF7FAFC,
                          ),

                          borderRadius:
                          BorderRadius
                              .circular(
                            16,
                          ),
                        ),

                        child:
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                          children: [

                            Text(
                              test.test,

                              style:
                              const TextStyle(
                                fontSize:
                                15,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),

                            if (test
                                .testInstruction
                                .isNotEmpty) ...[

                              const SizedBox(
                                height:
                                6,
                              ),

                              Text(
                                test
                                    .testInstruction,

                                style:
                                TextStyle(
                                  fontSize:
                                  13,
                                  color: Colors
                                      .grey
                                      .shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(
                    height: 10,
                  ),
                ],

                /// NOTES

                if (booking
                    .notes
                    .isNotEmpty) ...[

                  const Text(
                    "Doctor Notes",

                    style: TextStyle(
                      fontSize: 17,
                      fontWeight:
                      FontWeight
                          .bold,
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  ...booking.notes.map(

                        (note) {

                      return Container(

                        width:
                        double.infinity,

                        margin:
                        const EdgeInsets
                            .only(
                          bottom: 12,
                        ),

                        padding:
                        const EdgeInsets
                            .all(14),

                        decoration:
                        BoxDecoration(

                          color:
                          const Color(
                            0xFFF7FAFC,
                          ),

                          borderRadius:
                          BorderRadius
                              .circular(
                            16,
                          ),
                        ),

                        child: Text(
                          note.notes,

                          style:
                          const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      );
                    },
                  ),
                ],

                const SizedBox(
                  height: 30,
                ),

                Divider(
                  color:
                  Colors.grey.shade300,
                ),

                const SizedBox(
                  height: 20,
                ),

                /// SIGNATURE

                Align(
                  alignment:
                  Alignment.centerRight,

                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .end,

                    children: [

                      Text(
                        booking.doctorName,

                        style:
                        const TextStyle(
                          fontSize: 15,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      Text(
                        "Doctor Signature",

                        style: TextStyle(
                          fontSize: 13,
                          color: Colors
                              .grey
                              .shade600,
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Container(
                        width: 120,
                        height: 1.3,
                        color:
                        Colors.black54,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
      String title,
      String value,
      ) {

    return Padding(

      padding:
      const EdgeInsets.only(
        bottom: 12,
      ),

      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          SizedBox(
            width: 120,

            child: Text(
              title,

              style: TextStyle(
                fontSize: 14,
                color:
                Colors.grey.shade600,
                fontWeight:
                FontWeight.w500,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,

              style: const TextStyle(
                fontSize: 14,
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}