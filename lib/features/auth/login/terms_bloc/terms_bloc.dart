
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/repositories/terms_repository.dart';
import 'terms_event.dart';
import 'terms_state.dart';

class TermsBloc extends Bloc<TermsEvent, TermsState> {
  final TermsRepository repository;

  TermsBloc(this.repository) : super(TermsInitial()) {
    on<FetchTerms>(_onFetch);
  }

  Future<void> _onFetch(FetchTerms event, Emitter<TermsState> emit) async {
    emit(TermsLoading());
    try {
      final terms = await repository.getTerms();
      emit(TermsLoaded(terms));
    } catch (e, stacktrace) {
      print('Error in TermsBloc: $e');
      print(stacktrace);
      emit(TermsError(e.toString()));
    }
  }
}