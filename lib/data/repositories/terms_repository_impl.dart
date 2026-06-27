
import '../../domain/entities/terms_entity.dart';
import '../../domain/repositories/terms_repository.dart';
import '../datasources/terms_api_service.dart';
import '../models/terms_model.dart';


class TermsRepositoryImpl implements TermsRepository {
  final TermsApiService apiService;

  TermsRepositoryImpl(this.apiService);

  @override
  Future<TermsEntity> getTerms() async {
    try {
      final json = await apiService.getTerms();
      print('Terms API response: $json');
      final model = TermsModel.fromJson(json['result']);
      return model.toEntity();
    } catch (e) {
      print('Repository error: $e');
      rethrow;
    }
  }
}