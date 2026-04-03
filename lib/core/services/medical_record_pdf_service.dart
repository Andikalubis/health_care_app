import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:health_care_app/features/health/data/models/vital_sign_model.dart';
import 'package:health_care_app/features/health/data/models/health_check_model.dart';
import 'package:health_care_app/features/patient/data/models/patient_data_model.dart';

class MedicalRecordPdfService {
  Future<void> printMedicalRecord({
    required String patientName,
    PatientDataModel? patientData,
    required List<VitalSignModel> vitalSigns,
    required List<HealthCheckModel> healthChecks,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(patientName, context),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildPatientInfo(patientName, patientData),
          pw.SizedBox(height: 20),
          _buildVitalSignsSection(vitalSigns),
          pw.SizedBox(height: 20),
          _buildHealthChecksSection(healthChecks),
        ],
      ),
    );

    // Keep name simple for filename
    final safeName = patientName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Rekam_Medis_$safeName',
    );
  }

  pw.Widget _buildHeader(String patientName, pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 16),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'LAPORAN REKAM MEDIS',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Container(
                height: 3,
                width: 100,
                decoration: pw.BoxDecoration(color: PdfColors.blue700),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'HEALTH CARE SYSTEM - DIGITAL HEALTH RECORD',
                style: pw.TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.2,
                  color: PdfColors.blue500,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                'TGL CETAK',
                style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey600,
                ),
              ),
              pw.Text(
                _formatDate(DateTime.now()).toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 16),
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.blue100, width: 1),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Kerahasiaan dokumen ini dijamin oleh standar Health Care App.',
            style: pw.TextStyle(fontSize: 7, color: PdfColors.grey500),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Text(
              'Halaman ${context.pageNumber} / ${context.pagesCount}',
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPatientInfo(String patientName, PatientDataModel? pData) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: PdfColors.blue100, width: 1.5),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Avatar
          pw.Container(
            width: 50,
            height: 50,
            decoration: pw.BoxDecoration(
              color: PdfColors.blue900,
              shape: pw.BoxShape.circle,
            ),
            child: pw.Center(
              child: pw.Text(
                patientName.isNotEmpty ? patientName[0].toUpperCase() : '?',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),
          pw.SizedBox(width: 20),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  patientName.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Kolom Kiri
                    pw.Expanded(
                      flex: 1,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _infoRow('GENDER', pData?.gender ?? '-'),
                          pw.SizedBox(height: 6),
                          _infoRow(
                            'TGL LAHIR',
                            pData?.birthDate != null &&
                                    pData!.birthDate.isNotEmpty
                                ? _formatDateOnly(pData.birthDate)
                                : '-',
                          ),
                          pw.SizedBox(height: 6),
                          _infoRow('NO. TELP', pData?.noTlp ?? '-'),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 20),
                    // Kolom Kanan
                    pw.Expanded(
                      flex: 1,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _infoRow(
                            'TINGGI',
                            pData?.height != null ? '${pData!.height} cm' : '-',
                          ),
                          pw.SizedBox(height: 6),
                          _infoRow(
                            'BERAT',
                            pData?.weight != null ? '${pData!.weight} kg' : '-',
                          ),
                          pw.SizedBox(height: 6),
                          _infoRow('GOL. DARAH', pData?.bloodType ?? '-'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _infoRow(String label, String value) {
    return pw.Row(
      children: [
        pw.SizedBox(
          width: 60,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue500,
            ),
          ),
        ),
        pw.Text(
          value.toUpperCase(),
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey900,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildVitalSignsSection(List<VitalSignModel> vitalSigns) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('RINGKASAN TANDA VITAL', PdfColors.red700),
        pw.SizedBox(height: 12),
        if (vitalSigns.isEmpty)
          _buildEmptyMessage('Tidak ada data tanda vital yang tersedia.')
        else
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 9,
              color: PdfColors.white,
            ),
            headerDecoration: pw.BoxDecoration(color: PdfColors.blue800),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellAlignment: pw.Alignment.center,
            cellPadding: const pw.EdgeInsets.symmetric(vertical: 6),
            headerPadding: const pw.EdgeInsets.symmetric(vertical: 8),
            headers: [
              'TANGGAL',
              'TEK. DARAH',
              'DETAK JANTUNG',
              'SUHU',
              'RNAPAS',
              'OKSIGEN',
            ],
            data: vitalSigns
                .map(
                  (vs) => [
                    _formatDateShort(vs.checkTime ?? vs.createdAt),
                    vs.bloodPressure ?? '-',
                    vs.heartRate != null ? '${vs.heartRate} BPM' : '-',
                    vs.bodyTemperature != null
                        ? '${vs.bodyTemperature} C'
                        : '-',
                    vs.breathingRate != null ? '${vs.breathingRate} RPM' : '-',
                    vs.oxygenLevel != null ? '${vs.oxygenLevel} %' : '-',
                  ],
                )
                .toList(),
          ),
      ],
    );
  }

  pw.Widget _buildHealthChecksSection(List<HealthCheckModel> healthChecks) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('DETAIL PEMERIKSAAN KESEHATAN', PdfColors.green800),
        pw.SizedBox(height: 12),
        if (healthChecks.isEmpty)
          _buildEmptyMessage('Tidak ada data pemeriksaan kesehatan.')
        else
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 9,
              color: PdfColors.white,
            ),
            headerDecoration: pw.BoxDecoration(color: PdfColors.blue800),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellAlignment: pw.Alignment.center,
            cellPadding: const pw.EdgeInsets.symmetric(vertical: 6),
            headerPadding: const pw.EdgeInsets.symmetric(vertical: 8),
            headers: ['TANGGAL', 'KATEGORI', 'HASIL', 'STATUS', 'CATATAN'],
            data: healthChecks
                .map(
                  (hc) => [
                    _formatDateShort(hc.checkTime ?? hc.createdAt),
                    hc.healthType?.name.toUpperCase() ?? '-',
                    hc.resultValue?.toString() ?? '-',
                    _statusLabel(hc.status).toUpperCase(),
                    hc.notes ?? '-',
                  ],
                )
                .toList(),
          ),
      ],
    );
  }

  pw.Widget _buildSectionHeader(String title, PdfColor color) {
    return pw.Row(
      children: [
        pw.Container(
          width: 4,
          height: 16,
          decoration: pw.BoxDecoration(color: color),
        ),
        pw.SizedBox(width: 8),
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildEmptyMessage(String message) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: PdfColors.blue100),
      ),
      child: pw.Text(
        message,
        textAlign: pw.TextAlign.center,
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.blue600),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}, '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateOnly(String raw) {
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
  }

  String _formatDateShort(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'danger':
        return 'Bahaya';
      case 'warning':
        return 'Peringatan';
      case 'normal':
        return 'Normal';
      default:
        return status ?? '-';
    }
  }
}
