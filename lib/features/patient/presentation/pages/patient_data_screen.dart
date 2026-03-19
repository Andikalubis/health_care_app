import 'package:flutter/material.dart';
import 'package:health_care_app/core/widgets/app_list_skeleton.dart';
import 'package:health_care_app/features/auth/data/api_service.dart';
import 'package:health_care_app/features/patient/data/models/patient_data_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientDataScreen extends StatefulWidget {
  const PatientDataScreen({super.key});

  @override
  State<PatientDataScreen> createState() => _PatientDataScreenState();
}

class _PatientDataScreenState extends State<PatientDataScreen> {
  final _api = ApiService();
  List<PatientDataModel> _patients = [];
  bool _loading = true;
  String? _error;
  String _userRole = 'user';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      _userRole = prefs.getString('user_role') ?? 'user';

      final data = await _api.getPatientData();
      if (mounted) {
        setState(() {
          _patients = data;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) return const Scaffold(body: AppListSkeleton());
    if (_error != null) return _buildError();

    if (_userRole == 'admin') {
      return _buildPatientList(theme);
    }

    return _patients.isEmpty
        ? _buildAddForm(theme, null)
        : _buildAddForm(theme, _patients.first);
  }

  Widget _buildPatientList(ThemeData theme) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pasien'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _patients.isEmpty
          ? const Center(child: Text('Tidak ada data pasien'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _patients.length,
              itemBuilder: (context, index) {
                final p = _patients[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(
                      p.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${p.gender == 'male' ? 'Laki-laki' : 'Perempuan'} • ${p.birthDate}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to patient detail (to be implemented)
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _buildAddForm(ThemeData theme, PatientDataModel? existing) {
    return _PatientDataForm(existing: existing, onSaved: _load);
  }

  Widget _buildError() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 64, color: Colors.red),
        const SizedBox(height: 16),
        Text(_error!, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: _load, child: const Text('Coba Lagi')),
      ],
    ),
  );
}

class _PatientDataForm extends StatefulWidget {
  final PatientDataModel? existing;
  final VoidCallback onSaved;
  const _PatientDataForm({this.existing, required this.onSaved});

  @override
  State<_PatientDataForm> createState() => _PatientDataFormState();
}

class _PatientDataFormState extends State<_PatientDataForm> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();
  final _nameCtrl = TextEditingController();
  final _birthCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  String _gender = 'male';
  String? _bloodType;
  bool _loading = false;

  final List<String> _bloodTypes = [
    'A',
    'B',
    'AB',
    'O',
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final e = widget.existing!;
      _nameCtrl.text = e.name;
      _gender = e.gender;
      _birthCtrl.text = e.birthDate;
      _heightCtrl.text = e.height?.toString() ?? '';
      _weightCtrl.text = e.weight?.toString() ?? '';
      _bloodType = e.bloodType;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _birthCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1950),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _birthCtrl.text = picked.toIso8601String().split('T').first;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      final model = PatientDataModel(
        userId: userId,
        name: _nameCtrl.text.trim(),
        gender: _gender,
        birthDate: _birthCtrl.text.trim(),
        height: double.tryParse(_heightCtrl.text.trim()),
        weight: double.tryParse(_weightCtrl.text.trim()),
        bloodType: _bloodType,
      );
      if (widget.existing != null) {
        await _api.updatePatientData(widget.existing!.id!, model);
      } else {
        await _api.storePatientData(model);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data pasien disimpan!'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onSaved();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: 0.1,
                ),
                child: Icon(
                  Icons.person,
                  size: 56,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _gender,
              decoration: const InputDecoration(
                labelText: 'Jenis Kelamin',
                prefixIcon: Icon(Icons.transgender),
              ),
              items: const [
                DropdownMenuItem(value: 'male', child: Text('Laki-laki')),
                DropdownMenuItem(value: 'female', child: Text('Perempuan')),
              ],
              onChanged: (v) => setState(() => _gender = v!),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _birthCtrl,
              readOnly: true,
              onTap: _pickDate,
              decoration: const InputDecoration(
                labelText: 'Tanggal Lahir',
                prefixIcon: Icon(Icons.cake),
                suffixIcon: Icon(Icons.chevron_right),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Tanggal lahir wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _heightCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Tinggi (cm)',
                      prefixIcon: Icon(Icons.height),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _weightCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Berat (kg)',
                      prefixIcon: Icon(Icons.monitor_weight),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _bloodType,
              decoration: const InputDecoration(
                labelText: 'Golongan Darah',
                prefixIcon: Icon(Icons.bloodtype),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Pilih golongan darah'),
                ),
                ..._bloodTypes.map(
                  (t) => DropdownMenuItem(value: t, child: Text(t)),
                ),
              ],
              onChanged: (v) => setState(() => _bloodType = v),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : Text(
                      widget.existing != null
                          ? 'Perbarui Data Pasien'
                          : 'Simpan Data Pasien',
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
