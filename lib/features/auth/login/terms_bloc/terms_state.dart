
import 'package:equatable/equatable.dart';

import '../../../../domain/entities/terms_entity.dart';

abstract class TermsState extends Equatable {
  const TermsState();

  @override
  List<Object?> get props => [];
}

class TermsInitial extends TermsState {}

class TermsLoading extends TermsState {}

class TermsLoaded extends TermsState {
  final TermsEntity terms;

  const TermsLoaded(this.terms);

  @override
  List<Object?> get props => [terms];
}

class TermsError extends TermsState {
  final String message;

  const TermsError(this.message);

  @override
  List<Object?> get props => [message];
}