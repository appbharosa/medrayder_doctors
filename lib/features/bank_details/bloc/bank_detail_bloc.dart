import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/bank_detail_model.dart';
import '../../../domain/repositories/bank_detail_repository.dart';
import 'bank_detail_event.dart';
import 'bank_detail_state.dart';

class BankBloc extends Bloc<BankEvent, BankState> {
  final BankRepository repository;

  BankBloc({required this.repository}) : super(BankInitial()) {
    on<FetchBankDetails>(_onFetch);
    on<AddBankDetail>(_onAdd);
    on<UpdateBankDetail>(_onUpdate);
  }

  Future<void> _onFetch(FetchBankDetails event, Emitter<BankState> emit) async {
    print('🔵 FetchBankDetails called');
    emit(BankLoading());
    try {
      final List<BankDetailModel> details = await repository.getBankDetails();
      print('✅ Fetched ${details.length} bank details');
      emit(BankLoaded(details));
    } catch (e, stack) {
      print('❌ Fetch error: $e');
      print('Stack: $stack');
      emit(BankError(e.toString()));
    }
  }

  Future<void> _onAdd(AddBankDetail event, Emitter<BankState> emit) async {
    print('🔵 AddBankDetail called');
    emit(BankLoading());
    try {
      final detail = await repository.addBankDetails(event.request);
      final List<BankDetailModel> currentDetails = state is BankLoaded
          ? (state as BankLoaded).details
          : <BankDetailModel>[];
      final newList = [...currentDetails, detail];
      emit(BankLoaded(newList));
      print('✅ Added bank detail, now ${newList.length} items');
      emit(BankOperationSuccess('Bank details added successfully!'));
    } catch (e, stack) {
      print('❌ Add error: $e');
      print('Stack: $stack');
      emit(BankError(e.toString()));
    }
  }

  Future<void> _onUpdate(UpdateBankDetail event, Emitter<BankState> emit) async {
    print('🔵 UpdateBankDetail called for id ${event.id}');
    // Store current details before we change state
    final List<BankDetailModel> currentDetails = state is BankLoaded
        ? (state as BankLoaded).details
        : <BankDetailModel>[];

    emit(BankLoading());
    try {
      final updated = await repository.updateBankDetails(event.id, event.request);
      final newList = currentDetails.map((d) => d.id == event.id ? updated : d).toList();
      emit(BankLoaded(newList));
      print('✅ Updated bank detail, now ${newList.length} items');
      emit(BankOperationSuccess('Bank details updated successfully!'));
    } catch (e, stack) {
      print('❌ Update error: $e');
      print('Stack: $stack');
      emit(BankError(e.toString()));
    }
  }
}