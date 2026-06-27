
import '../entities/terms_entity.dart';

abstract class TermsRepository {
  Future<TermsEntity> getTerms();
}