import 'package:hive_flutter/hive_flutter.dart';
import 'certificate_model.dart';
import 'dart:io';

class CertificateRepository {
  static const String _boxName = 'certificates';

  Future<void> init() async {
    // Adapter registration handled centrally in hive_init.dart
    await Hive.openBox<CertificateModel>(_boxName);
  }

  Box<CertificateModel> get _box => Hive.box<CertificateModel>(_boxName);

  List<CertificateModel> getAllCertificates() {
    return _box.values.toList()
      ..sort((a, b) => b.issuedAt.compareTo(a.issuedAt));
  }

  CertificateModel? getCertificate(String level) {
    try {
      return _box.values.firstWhere((c) => c.level == level);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveCertificate(CertificateModel certificate) async {
    await _box.put(certificate.id, certificate);
  }

  Future<void> deleteCertificate(String id) async {
    final cert = _box.get(id);
    if (cert != null) {
      final file = File(cert.filePath);
      if (await file.exists()) {
        await file.delete();
      }
      await _box.delete(id);
    }
  }

  Future<void> clearAll() async {
    final certs = _box.values.toList();
    for (final cert in certs) {
      final path = cert.filePath;
      if (path.isEmpty) continue;
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
    await _box.clear();
  }
}
