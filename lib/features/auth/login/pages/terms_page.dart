import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../../domain/entities/terms_entity.dart';
import '../terms_bloc/terms_bloc.dart';
import '../terms_bloc/terms_event.dart';
import '../terms_bloc/terms_state.dart';


class TermsPage extends StatefulWidget {
  const TermsPage({super.key});

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  late final TermsBloc _termsBloc;

  @override
  void initState() {
    super.initState();
    _termsBloc = di.sl<TermsBloc>()..add(FetchTerms());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A8FDC), // Blue background
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Terms & Conditions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      body: BlocProvider.value(
        value: _termsBloc,
        child: BlocBuilder<TermsBloc, TermsState>(
          builder: (context, state) {
            if (state is TermsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is TermsLoaded) {
              return _buildContent(state.terms);
            }

            if (state is TermsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.red),
                    const SizedBox(height: 15),
                    Text(
                      state.message,
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        context.read<TermsBloc>().add(FetchTerms());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A8FDC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Retry',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Initial state – you can show a placeholder
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildContent(TermsEntity terms) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              terms.name,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.black87,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Optional additional info, e.g., last updated
          Text(
            'Last updated: ${DateTime.now().toString().split(' ')[0]}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }
}