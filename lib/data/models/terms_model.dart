import '../../domain/entities/terms_entity.dart';

class TermsModel {
  final int id;
  final String name;

  TermsModel({required this.id, required this.name});

  factory TermsModel.fromJson(Map<String, dynamic> json) {
    return TermsModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  TermsEntity toEntity() => TermsEntity(id: id, name: name);
}