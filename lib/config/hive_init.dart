import 'package:hive_flutter/hive_flutter.dart';
import '../features/certificate/certificate_model.dart';
// import other adapter models here if needed in future

/// Centralized Hive Initialization
/// 
/// Ensures Hive is initialized once and adapters are registered safely.
Future<void> initHive() async {
  await Hive.initFlutter();

  // Certificate Adapter (TypeId: 4)
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(CertificateModelAdapter());
  }
}
