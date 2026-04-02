import 'package:flutter/material.dart';
import 'package:health_care_app/core/utils/date_format_helper.dart';
import 'package:health_care_app/features/auth/data/api_service.dart';
import 'package:health_care_app/features/health/data/models/health_check_model.dart';
import 'package:health_care_app/features/health/data/models/vital_sign_model.dart';

class MedicalRecordScreen extends StatefulWidget {
  final int patientId;
  final String patientName;

  const MedicalRecordScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<MedicalRecordScreen> createState() => _MedicalRecordScreenState();
}

class _MedicalRecordScreenState extends State<MedicalRecordScreen> {
  final _api = ApiService();
  bool _isLoading = true;
  String? _error;

  List<VitalSignModel> _vitalSigns = [];
  List<HealthCheckModel> _healthChecks = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _api.getMedicalRecord(widget.patientId);
      if (mounted) {
        setState(() {
          _vitalSigns =
              (data['vital_signs'] as List?)
                  ?.map((e) => VitalSignModel.fromJson(e))
                  .toList() ??
              [];
          _healthChecks =
              (data['health_checks'] as List?)
                  ?.map((e) => HealthCheckModel.fromJson(e))
                  .toList() ??
              [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rekam Medis: ${widget.patientName}'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _load, child: const Text('Coba Lagi')),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionHeader('Vital Signs', Icons.favorite),
          if (_vitalSigns.isEmpty)
            _buildEmpty('Tidak ada catatan tanda vital')
          else
            ..._vitalSigns.map(_buildVitalSignCard),

          const SizedBox(height: 24),

          _buildSectionHeader('Pemeriksaan Lainnya', Icons.health_and_safety),
          if (_healthChecks.isEmpty)
            _buildEmpty('Tidak ada catatan pemeriksaan')
          else
            ..._healthChecks.map(_buildHealthCheckCard),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(String msg) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(msg, style: TextStyle(color: Colors.grey.shade600)),
      ),
    );
  }

  Widget _buildVitalSignCard(VitalSignModel vs) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatDateTimeShort(vs.checkTime ?? vs.createdAt ?? ''),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Tekanan Darah: ${vs.bloodPressure ?? '-'}'),
            Text('Detak Jantung: ${vs.heartRate ?? '-'} bpm'),
            Text('Suhu Tubuh: ${vs.bodyTemperature ?? '-'} °C'),
            Text('Pernapasan: ${vs.breathingRate ?? '-'} rpm'),
            Text('Oksigen: ${vs.oxygenLevel ?? '-'} %'),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthCheckCard(HealthCheckModel hc) {
    final color = hc.status == 'danger'
        ? Colors.red
        : hc.status == 'warning'
        ? Colors.amber
        : Colors.green;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(Icons.check_circle, color: color),
        ),
        title: Text(hc.healthType?.name ?? 'Pemeriksaan #${hc.id}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Nilai: ${hc.resultValue ?? '-'}'),
            if (hc.notes != null && hc.notes!.isNotEmpty)
              Text('Catatan: ${hc.notes}'),
            const SizedBox(height: 4),
            Text(
              formatDateTimeShort(hc.checkTime ?? hc.createdAt ?? ''),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
