
import 'package:dio/dio.dart';

import '../../core/app_urls/app_urls.dart';


class TermsApiService {
  final Dio _dio;

  TermsApiService(this._dio);

  Future<Map<String, dynamic>> getTerms() async {
    final response = await _dio.get(AppUrls.terms);
    return response.data;
  }
}