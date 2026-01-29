import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'certificate_service.dart';

class CertificateScreen extends StatelessWidget {
  final String userName;
  final String userId;
  final DateTime date;
  final String certificateId;

  const CertificateScreen({
    super.key,
    required this.userName,
    required this.userId,
    required this.date,
    required this.certificateId,
  });

  @override
  Widget build(BuildContext context) {
    final service = CertificateService();

    return Scaffold(
      appBar: AppBar(title: const Text('Course Certificate')),
      body: PdfPreview(
        build: (format) => service.createPdfBytes(
          id: certificateId,
          userName: userName,
          date: date,
        ),
        canDebug: false,
        canChangeOrientation: false,
        canChangePageFormat: false,
        allowPrinting: true,
        allowSharing: true,
        pdfFileName: 'LietuCoach_Certificate_A1.pdf',
        actions: [], // Default actions are good
      ),
    );
  }
}
