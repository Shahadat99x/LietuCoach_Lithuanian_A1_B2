import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'certificate_model.dart';
import 'certificate_repository.dart';

class CertificateService {
  final CertificateRepository _repository = CertificateRepository();

  Future<void> init() async {
    await _repository.init();
  }

  Future<String?> generateAndSaveCertificate({
    required String userName,
    required String userId, // 'guest' or UUID
    required String score,
  }) async {
    final now = DateTime.now();
    final certId = _generateCertificateId(userId, now);

    final pdfBytes = await createPdfBytes(
      id: certId,
      userName: userName,
      date: now,
    );

    final outputDir = await getApplicationDocumentsDirectory();
    final certsDir = Directory('${outputDir.path}/certificates');
    if (!await certsDir.exists()) {
      await certsDir.create(recursive: true);
    }

    final filePath = '${certsDir.path}/$certId.pdf';
    final file = File(filePath);
    await file.writeAsBytes(pdfBytes);

    // Save metadata
    final model = CertificateModel(
      id: certId,
      level: 'A1',
      issuedAt: now,
      filePath: filePath,
      learnerName: userName,
    );
    await _repository.saveCertificate(model);

    return filePath;
  }

  List<CertificateModel> getCertificates() {
    return _repository.getAllCertificates();
  }

  String _generateCertificateId(String userId, DateTime date) {
    final dateStr = DateFormat('yyyyMMdd').format(date);
    final random = Random().nextInt(10000).toString().padLeft(4, '0');
    // LC-A1-{userIdHash}-{Date}-{Random}
    final userHash = userId.hashCode.toString().substring(
      0,
      min(6, userId.hashCode.toString().length),
    );
    return 'LC-A1-$userHash-$dateStr-$random';
  }

  Future<Uint8List> createPdfBytes({
    required String id,
    required String userName,
    required DateTime date,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.blue900, width: 4),
            ),
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Header
                pw.SizedBox(height: 20),
                pw.Text(
                  'CERTIFICATE OF COMPLETION',
                  style: pw.TextStyle(
                    fontSize: 40,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Certificate ID: $id',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                ),

                pw.SizedBox(height: 20),
                pw.Text(
                  'This certifies that',
                  style: pw.TextStyle(fontSize: 20),
                ),

                // Name
                pw.SizedBox(height: 10),
                pw.Text(
                  userName,
                  style: pw.TextStyle(
                    fontSize: 40,
                    fontWeight: pw.FontWeight.bold,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),

                // Body
                pw.SizedBox(height: 10),
                pw.Text(
                  'has successfully completed the',
                  style: pw.TextStyle(fontSize: 20),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Lithuanian A1 Course',
                  style: pw.TextStyle(
                    fontSize: 30,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),

                pw.SizedBox(height: 40),

                // Footer (Date & Sig)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          DateFormat('yyyy-MM-dd').format(date),
                          style: pw.TextStyle(fontSize: 18),
                        ),
                        pw.Container(
                          width: 150,
                          height: 1,
                          color: PdfColors.black,
                        ),
                        pw.Text('Date', style: pw.TextStyle(fontSize: 14)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'LietuCoach',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            fontStyle: pw.FontStyle.italic,
                          ),
                        ),
                        pw.Container(
                          width: 150,
                          height: 1,
                          color: PdfColors.black,
                        ),
                        pw.Text('Signature', style: pw.TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),

                pw.Spacer(),

                // Disclaimer
                pw.Text(
                  'This certificate is issued by the LietuCoach app and is for personal learning tracking. It is not an official language proficiency certificate.',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }
}
