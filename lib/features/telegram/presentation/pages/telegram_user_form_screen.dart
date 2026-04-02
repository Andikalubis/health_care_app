import 'package:flutter/material.dart';
import 'package:health_care_app/core/widgets/app_button.dart';
import 'package:health_care_app/features/auth/data/api_service.dart';
import 'package:health_care_app/features/telegram/data/models/telegram_user_model.dart';

class TelegramUserFormScreen extends StatefulWidget {
  final TelegramUserModel? existing;

  const TelegramUserFormScreen({super.key, this.existing});

  @override
  State<TelegramUserFormScreen> createState() => _TelegramUserFormScreenState();
}

class _TelegramUserFormScreenState extends State<TelegramUserFormScreen> {
  final _api = ApiService();
  final _formKey = GlobalKey<FormState>();

  final _userIdCtrl = TextEditingController();
  final _chatIdCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _userIdCtrl.text = widget.existing!.userId?.toString() ?? '';
      _chatIdCtrl.text = widget.existing!.telegramChatId ?? '';
      _usernameCtrl.text = widget.existing!.telegramUsername ?? '';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final model = TelegramUserModel(
        userId: int.tryParse(_userIdCtrl.text),
        telegramChatId: _chatIdCtrl.text,
        telegramUsername: _usernameCtrl.text.isNotEmpty
            ? _usernameCtrl.text
            : null,
      );

      if (widget.existing == null) {
        await _api.storeTelegramUser(model);
      } else {
        await _api.updateTelegramUser(widget.existing!.id!, model);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existing == null
                  ? 'Berhasil ditambahkan'
                  : 'Berhasil diperbarui',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.existing == null
        ? 'Tambah Telegram User'
        : 'Edit Telegram User';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _userIdCtrl,
                decoration: const InputDecoration(
                  labelText: 'User ID',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Isi ID User' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _chatIdCtrl,
                decoration: const InputDecoration(
                  labelText: 'Telegram Chat ID',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Isi Chat ID' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Username (Opsional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : AppButton(text: 'Simpan', onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
