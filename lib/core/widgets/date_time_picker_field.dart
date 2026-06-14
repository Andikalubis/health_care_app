import 'package:flutter/material.dart';

/// A read-only [TextFormField] that opens a date picker on tap.
/// The value stored in [controller] is always 'yyyy-MM-dd'.
class DatePickerField extends StatelessWidget {
  const DatePickerField({
    super.key,
    required this.controller,
    required this.label,
    this.prefixIcon = Icons.calendar_today,
    this.firstDate,
    this.lastDate,
    this.initialDate,
    this.validator,
    this.enabled = true,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final IconData prefixIcon;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? initialDate;
  final String? Function(String?)? validator;
  final bool enabled;
  final Function(String)? onChanged;

  Future<void> _pick(BuildContext context) async {
    if (!enabled) return;
    DateTime init;
    if (controller.text.isNotEmpty) {
      init = (DateTime.tryParse(controller.text) ?? DateTime.now()).toLocal();
    } else {
      init = initialDate ?? DateTime.now();
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: firstDate ?? DateTime(1920),
      lastDate: lastDate ?? DateTime(2100),
    );
    if (picked != null) {
      final val = '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      controller.text = val;
      if (onChanged != null) onChanged!(val);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      enabled: enabled,
      onTap: () => _pick(context),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: const Icon(Icons.chevron_right),
      ),
      validator:
          validator ??
          (v) => (v == null || v.isEmpty) ? ' wajib diisi' : null,
    );
  }
}

/// A read-only [TextFormField] that opens a time picker on tap.
/// The value stored in [controller] is always 'HH:mm:00' (24-hour, suitable for API).
/// The displayed text is the same 'HH:mm' for readability.
class TimePickerField extends StatelessWidget {
  const TimePickerField({
    super.key,
    required this.controller,
    required this.label,
    this.prefixIcon = Icons.access_time,
    this.validator,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final IconData prefixIcon;
  final String? Function(String?)? validator;
  final bool enabled;

  Future<void> _pick(BuildContext context) async {
    if (!enabled) return;
    TimeOfDay init = TimeOfDay.now();
    if (controller.text.isNotEmpty) {
      final parts = controller.text.split(':');
      if (parts.length >= 2) {
        final h = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        if (h != null && m != null) {
          init = TimeOfDay(hour: h, minute: m);
        }
      }
    }
    final picked = await showTimePicker(
      context: context,
      initialTime: init,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00';
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      enabled: enabled,
      onTap: () => _pick(context),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: const Icon(Icons.chevron_right),
      ),
      validator:
          validator ??
          (v) => (v == null || v.isEmpty) ? ' wajib diisi' : null,
    );
  }
}

/// A read-only [TextFormField] that opens a combined date + time picker on tap.
/// Stored value is ISO 8601 UTC: 'yyyy-MM-ddTHH:mm:ss.000Z' (e.g. '2026-06-14T11:55:00.000Z').
/// Displayed value: 'dd/MM/yyyy HH:mm' automatically converted to device local time via toLocal().
class DateTimePickerField extends StatelessWidget {
  const DateTimePickerField({
    super.key,
    required this.controller,
    required this.label,
    this.prefixIcon = Icons.event,
    this.firstDate,
    this.lastDate,
    this.validator,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final IconData prefixIcon;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? Function(String?)? validator;
  final bool enabled;

  Future<void> _pick(BuildContext context) async {
    if (!enabled) return;
    DateTime init = DateTime.now();
    if (controller.text.isNotEmpty) {
      init = (DateTime.tryParse(controller.text) ?? DateTime.now()).toLocal();
    }
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: firstDate ?? DateTime(1920),
      lastDate: lastDate ?? DateTime(2100),
    );
    if (pickedDate == null || !context.mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(init),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (pickedTime == null) return;

    final combined = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    final offset = DateTime.now().timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final oh = offset.inHours.abs().toString().padLeft(2, '0');
    final om = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    controller.text = '${combined.toIso8601String()}$sign$oh:$om';
  }

  static String _displayText(String isoValue) {
    final dt = DateTime.tryParse(isoValue)?.toLocal();
    if (dt == null) return isoValue;
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}  '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final display = value.text.isEmpty ? '' : _displayText(value.text);
        return InkWell(
          onTap: () => _pick(context),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(prefixIcon),
              suffixIcon: const Icon(Icons.chevron_right),
              errorText: (validator != null && value.text.isEmpty)
                  ? validator!(value.text)
                  : null,
            ),
            child: Text(
              display.isEmpty ? '' : display,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        );
      },
    );
  }
}


