import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../../domain/entities/prescription_medicine.dart';
import '../../../../domain/entities/prescription_test.dart';
import '../../../../domain/entities/prescription_request.dart';
import '../../../core/app_colors/app_colors.dart';
import '../../../domain/repositories/prescription_repository.dart';
import '../bloc/prescripption_bloc.dart';
import '../bloc/prescription_event.dart';
import '../bloc/prescription_state.dart';


class PrescriptionScreen extends StatefulWidget {

  final String bookingId;
  final String doctorType;

  const PrescriptionScreen({
    super.key,
    required this.bookingId,
    required this.doctorType,
  });

  @override
  State<PrescriptionScreen> createState() =>
      _PrescriptionScreenState();
}

class _PrescriptionScreenState
    extends State<PrescriptionScreen> {

  final List<MedicineField> medicines = [];
  final List<TestField> tests = [];

  final TextEditingController notesController =
  TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    medicines.add(MedicineField());
    tests.add(TestField());
  }

  void _addMedicine() {
    setState(() {
      medicines.add(MedicineField());
    });
  }

  void _removeMedicine(int index) {
    setState(() {
      medicines.removeAt(index);
    });
  }

  void _addTest() {
    setState(() {
      tests.add(TestField());
    });
  }

  void _removeTest(int index) {
    setState(() {
      tests.removeAt(index);
    });
  }

  void _submit(BuildContext context) {

    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    final meds = medicines
        .where(
          (m) =>
      m.medicineController.text
          .isNotEmpty &&
          m.timeController.text
              .isNotEmpty,
    )
        .map(
          (m) => PrescriptionMedicine(
        medicine:
        m.medicineController.text
            .trim(),

        medicineTime:
        m.timeController.text
            .trim(),
      ),
    )
        .toList();

    final testList = tests
        .where(
          (t) =>
      t.testController.text
          .isNotEmpty &&
          t.instructionController.text
              .isNotEmpty,
    )
        .map(
          (t) => PrescriptionTest(
        test:
        t.testController.text
            .trim(),

        testInstruction:
        t.instructionController.text
            .trim(),
      ),
    )
        .toList();

    final request = PrescriptionRequest(

      bookingId:
      widget.bookingId,

      doctorType:
      widget.doctorType,

      viewType: "insert",

      medicines: meds,

      tests: testList,

      notes:
      notesController.text.trim(),
    );

    context.read<PrescriptionBloc>()
        .add(
      AddPrescriptionEvent(
        request,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return BlocProvider(

      create: (_) => PrescriptionBloc(
        repository:
        di.sl<PrescriptionRepository>(),
      ),

      child: Scaffold(

        backgroundColor:
        const Color(0xFFF5F7FB),

        appBar: AppBar(

          elevation: 0,

          backgroundColor:
          Colors.white,

          centerTitle: true,

          title: const Text(
            "Add Prescription",

            style: TextStyle(
              color: Colors.black,
              fontWeight:
              FontWeight.bold,
              fontSize: 18,
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
        BlocConsumer<
            PrescriptionBloc,
            PrescriptionState>(

          listener: (context, state) {

            if (state
            is PrescriptionSuccess) {

              ScaffoldMessenger.of(context)
                  .showSnackBar(

                const SnackBar(
                  content: Text(
                    "Prescription Added Successfully",
                  ),

                  backgroundColor:
                  Colors.green,
                ),
              );

              Navigator.pop(context, true);
            }

            if (state
            is PrescriptionError) {

              ScaffoldMessenger.of(context)
                  .showSnackBar(

                SnackBar(
                  content:
                  Text(state.message),

                  backgroundColor:
                  Colors.red,
                ),
              );
            }
          },

          builder: (context, state) {

            return Stack(
              children: [

                Form(

                  key: _formKey,

                  child:
                  SingleChildScrollView(

                    padding:
                    const EdgeInsets.all(
                      16,
                    ),

                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                      children: [

                        /// MEDICINES HEADER

                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,

                          children: [

                            const Text(
                              "Medicines",

                              style: TextStyle(
                                fontSize: 18,
                                fontWeight:
                                FontWeight
                                    .bold,
                              ),
                            ),

                            GestureDetector(

                              onTap:
                              _addMedicine,

                              child: Container(

                                padding:
                                const EdgeInsets
                                    .symmetric(
                                  horizontal:
                                  14,
                                  vertical:
                                  8,
                                ),

                                decoration:
                                BoxDecoration(

                                  color:
                                  const Color(
                                    0xFF0A8FDC,
                                  ),

                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                    12,
                                  ),
                                ),

                                child: const Row(
                                  children: [

                                    Icon(
                                      Icons.add,
                                      color:
                                      Colors.white,
                                      size: 18,
                                    ),

                                    SizedBox(
                                      width: 5,
                                    ),

                                    Text(
                                      "Add",

                                      style:
                                      TextStyle(
                                        color:
                                        Colors.white,
                                        fontWeight:
                                        FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        /// MEDICINES LIST

                        ...medicines
                            .asMap()
                            .entries
                            .map(
                              (entry) {

                            int idx =
                                entry.key;

                            MedicineField
                            field =
                                entry.value;

                            return Container(

                              margin:
                              const EdgeInsets
                                  .only(
                                bottom: 16,
                              ),

                              padding:
                              const EdgeInsets
                                  .all(16),

                              decoration:
                              BoxDecoration(

                                color:
                                Colors.white,

                                borderRadius:
                                BorderRadius
                                    .circular(
                                  18,
                                ),

                                boxShadow: [

                                  BoxShadow(
                                    color: Colors
                                        .grey
                                        .withOpacity(
                                      0.08,
                                    ),

                                    blurRadius:
                                    10,

                                    offset:
                                    const Offset(
                                      0,
                                      4,
                                    ),
                                  ),
                                ],
                              ),

                              child: Column(
                                children: [

                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,

                                    children: [

                                      Text(
                                        "Medicine ${idx + 1}",

                                        style:
                                        const TextStyle(
                                          fontWeight:
                                          FontWeight.bold,
                                          fontSize:
                                          15,
                                        ),
                                      ),

                                      if (medicines
                                          .length >
                                          1)

                                        GestureDetector(

                                          onTap: () {

                                            _removeMedicine(
                                              idx,
                                            );
                                          },

                                          child:
                                          const CircleAvatar(
                                            radius:
                                            14,

                                            backgroundColor:
                                            Colors.red,

                                            child:
                                            Icon(
                                              Icons
                                                  .close,
                                              color:
                                              Colors.white,
                                              size:
                                              16,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),

                                  const SizedBox(
                                    height: 16,
                                  ),

                                  _field(
                                    controller:
                                    field
                                        .medicineController,

                                    hint:
                                    "Medicine Name",
                                  ),

                                  const SizedBox(
                                    height: 14,
                                  ),

                                  _field(
                                    controller:
                                    field
                                        .timeController,

                                    hint:
                                    "Morning / Afternoon / Night",
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 28),

                        /// TESTS HEADER

                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,

                          children: [

                            const Text(
                              "Tests",

                              style: TextStyle(
                                fontSize: 18,
                                fontWeight:
                                FontWeight
                                    .bold,
                              ),
                            ),

                            GestureDetector(

                              onTap: _addTest,

                              child: Container(

                                padding:
                                const EdgeInsets
                                    .symmetric(
                                  horizontal:
                                  14,
                                  vertical:
                                  8,
                                ),

                                decoration:
                                BoxDecoration(

                                  color:
                                  const Color(
                                    0xFF0A8FDC,
                                  ),

                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                    12,
                                  ),
                                ),

                                child: const Row(
                                  children: [

                                    Icon(
                                      Icons.add,
                                      color:
                                      Colors.white,
                                      size: 18,
                                    ),

                                    SizedBox(
                                      width: 5,
                                    ),

                                    Text(
                                      "Add",

                                      style:
                                      TextStyle(
                                        color:
                                        Colors.white,
                                        fontWeight:
                                        FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        /// TESTS LIST

                        ...tests
                            .asMap()
                            .entries
                            .map(
                              (entry) {

                            int idx =
                                entry.key;

                            TestField
                            field =
                                entry.value;

                            return Container(

                              margin:
                              const EdgeInsets
                                  .only(
                                bottom: 16,
                              ),

                              padding:
                              const EdgeInsets
                                  .all(16),

                              decoration:
                              BoxDecoration(

                                color:
                                Colors.white,

                                borderRadius:
                                BorderRadius
                                    .circular(
                                  18,
                                ),

                                boxShadow: [

                                  BoxShadow(
                                    color: Colors
                                        .grey
                                        .withOpacity(
                                      0.08,
                                    ),

                                    blurRadius:
                                    10,

                                    offset:
                                    const Offset(
                                      0,
                                      4,
                                    ),
                                  ),
                                ],
                              ),

                              child: Column(
                                children: [

                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,

                                    children: [

                                      Text(
                                        "Test ${idx + 1}",

                                        style:
                                        const TextStyle(
                                          fontWeight:
                                          FontWeight.bold,
                                          fontSize:
                                          15,
                                        ),
                                      ),

                                      if (tests
                                          .length >
                                          1)

                                        GestureDetector(

                                          onTap: () {

                                            _removeTest(
                                              idx,
                                            );
                                          },

                                          child:
                                          const CircleAvatar(
                                            radius:
                                            14,

                                            backgroundColor:
                                            Colors.red,

                                            child:
                                            Icon(
                                              Icons
                                                  .close,
                                              color:
                                              Colors.white,
                                              size:
                                              16,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),

                                  const SizedBox(
                                    height: 16,
                                  ),

                                  _field(
                                    controller:
                                    field
                                        .testController,

                                    hint:
                                    "Test Name",
                                  ),

                                  const SizedBox(
                                    height: 14,
                                  ),

                                  _field(
                                    controller:
                                    field
                                        .instructionController,

                                    hint:
                                    "Instructions",
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 28),

                        /// NOTES

                        const Text(
                          "Additional Notes",

                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 14),

                        _field(
                          controller:
                          notesController,

                          hint:
                          "Write Notes Here...",

                          maxLines: 5,

                          isRequired: false,
                        ),

                        const SizedBox(height: 35),

                        /// SUBMIT BUTTON

                        SizedBox(

                          width:
                          double.infinity,

                          height: 55,

                          child:
                          ElevatedButton(

                            onPressed:
                            state
                            is PrescriptionLoading
                                ? null
                                : () => _submit(
                              context,
                            ),

                            style:
                            ElevatedButton
                                .styleFrom(

                              elevation: 0,

                              backgroundColor:
                              const Color(
                                0xFF0A8FDC,
                              ),

                              shape:
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius
                                    .circular(
                                  16,
                                ),
                              ),
                            ),

                            child:
                            state
                            is PrescriptionLoading
                                ? const SizedBox(
                              height:
                              22,
                              width:
                              22,

                              child:
                              CircularProgressIndicator(
                                color:
                                Colors.white,
                                strokeWidth:
                                2,
                              ),
                            )
                                : const Text(
                              "Submit Prescription",

                              style:
                              TextStyle(
                                color:
                                Colors.white,
                                fontSize:
                                16,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 40,
                        ),
                      ],
                    ),
                  ),
                ),

                if (state
                is PrescriptionLoading)

                  Container(
                    color: Colors.black12,

                    child: const Center(
                      child:
                      CircularProgressIndicator(),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _field({

    required TextEditingController
    controller,

    required String hint,

    int maxLines = 1,

    bool isRequired = true,
  }) {

    return TextFormField(

      controller: controller,

      maxLines: maxLines,

      style: const TextStyle(
        fontSize: 15,
      ),

      decoration: InputDecoration(

        hintText: hint,

        hintStyle: TextStyle(
          color: Colors.grey.shade500,
        ),

        filled: true,

        fillColor: const Color(
          0xFFF8FAFC,
        ),

        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),

        border:
        OutlineInputBorder(

          borderRadius:
          BorderRadius.circular(14),

          borderSide:
          BorderSide.none,
        ),

        enabledBorder:
        OutlineInputBorder(

          borderRadius:
          BorderRadius.circular(14),

          borderSide:
          BorderSide.none,
        ),

        focusedBorder:
        OutlineInputBorder(

          borderRadius:
          BorderRadius.circular(14),

          borderSide:
          const BorderSide(
            color:
            Color(0xFF0A8FDC),
          ),
        ),
      ),

      validator: (value) {

        if (isRequired &&
            (value == null ||
                value.isEmpty)) {

          return "Required";
        }

        return null;
      },
    );
  }
}

class MedicineField {

  final TextEditingController
  medicineController =
  TextEditingController();

  final TextEditingController
  timeController =
  TextEditingController();
}

class TestField {

  final TextEditingController
  testController =
  TextEditingController();

  final TextEditingController
  instructionController =
  TextEditingController();
}