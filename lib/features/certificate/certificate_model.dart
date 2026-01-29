import 'package:hive/hive.dart';

part 'certificate_model.g.dart';

@HiveType(
  typeId: 4,
) // Assuming ID 3 was last usage for SRS, checking recommended ID strategy next
class CertificateModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String level;

  @HiveField(2)
  final DateTime issuedAt;

  @HiveField(3)
  final String filePath;

  @HiveField(4)
  final String learnerName;

  CertificateModel({
    required this.id,
    required this.level,
    required this.issuedAt,
    required this.filePath,
    required this.learnerName,
  });
}
