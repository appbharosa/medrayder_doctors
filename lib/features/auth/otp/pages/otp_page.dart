import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home/home_page/home_page.dart';
import '../bloc/otp_bloc.dart';
import '../bloc/otp_event.dart';
import '../bloc/otp_state.dart';

class OtpPage extends StatefulWidget {
  final int doctorId;
  final String type;
  final String phone;

  const OtpPage({
    super.key,
    required this.doctorId,
    required this.type,
    required this.phone,
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController otpController = TextEditingController();

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  void _showCustomSnackBar(BuildContext context, String message,
      {required Color backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 20,
          ),
        ),
        title: const Text(
          "OTP Verification",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
      body: BlocConsumer<OtpBloc, OtpState>(
        listener: (context, state) {
          if (state is OtpVerificationSuccess) {
            _showCustomSnackBar(
              context,
              "OTP verified successfully! Welcome ${state.user.name}",
              backgroundColor: Colors.green,
            );
            Future.delayed(const Duration(milliseconds: 1500), () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            });
          } else if (state is OtpVerificationFailure) {
            _showCustomSnackBar(
              context,
              state.error,
              backgroundColor: Colors.red,
            );
          } else if (state is OtpResendSuccess) {
            _showCustomSnackBar(
              context,
              "OTP resent successfully. Please check your phone.",
              backgroundColor: Colors.green,
            );
          } else if (state is ResendOtpLoading) {
            // optional: show loading indicator on the button
          }
        },
        builder: (context, state) {
          final isResending = state is ResendOtpLoading;
          final isVerifying = state is OtpVerifying;

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        Container(
                          height: 110,
                          width: 110,
                          decoration: BoxDecoration(
                            color: const Color(0xff1565C0).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_outline_rounded,
                            size: 55,
                            color: Color(0xff1565C0),
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          "Verify OTP",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Enter the OTP sent to\n${widget.phone}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "OTP Code",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextField(
                                controller: otpController,
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  letterSpacing: 8,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  hintText: "------",
                                  counterText: "",
                                  filled: true,
                                  fillColor: const Color(0xffF5F7FB),
                                  contentPadding:
                                  const EdgeInsets.symmetric(vertical: 18),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: const BorderSide(
                                      color: Color(0xff1565C0),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // 👇 Resend OTP button
                              Center(
                                child: TextButton(
                                  onPressed: isResending || isVerifying
                                      ? null
                                      : () {
                                    context.read<OtpBloc>().add(
                                      ResendOtpRequested(
                                        doctorId: widget.doctorId,
                                        type: widget.type,
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: isResending || isVerifying
                                        ? Colors.grey
                                        : const Color(0xff1565C0),
                                    textStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  child: isResending
                                      ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xff1565C0),
                                    ),
                                  )
                                      : const Text("Resend OTP"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
                  color: Colors.white,
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: isVerifying
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                      onPressed: () {
                        if (otpController.text.trim().isNotEmpty) {
                          context.read<OtpBloc>().add(
                            VerifyOtpRequested(
                              doctorId: widget.doctorId,
                              otp: otpController.text.trim(),
                              type: widget.type,
                            ),
                          );
                        } else {
                          _showCustomSnackBar(
                            context,
                            "Please enter OTP",
                            backgroundColor: Colors.orange,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff1565C0),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        "Verify OTP",
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
          );
        },
      ),
    );
  }
}