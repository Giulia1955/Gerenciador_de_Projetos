import 'package:flutter/material.dart';

import '../utils/validators.dart';

class AppDateField extends StatelessWidget {
  const AppDateField({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      initialValue: value,
      enabled: enabled,
      validator: Validators.validateProjectDueDate,
      builder: (field) {
        final text = value == null
            ? 'Selecione o prazo'
            : '${value!.day.toString().padLeft(2, '0')}/${value!.month.toString().padLeft(2, '0')}/${value!.year}';

        return InkWell(
          onTap: enabled
              ? () async {
                  final now = DateTime.now();
                  final selected = await showDatePicker(
                    context: context,
                    initialDate: value ?? now,
                    firstDate: DateTime(now.year, now.month, now.day),
                    lastDate: DateTime(now.year + 20),
                  );
                  if (selected != null) {
                    onChanged(selected);
                    field.didChange(selected);
                  }
                }
              : null,
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Prazo',
              errorText: field.errorText,
              suffixIcon: const Icon(Icons.calendar_month_outlined),
            ),
            child: Text(text),
          ),
        );
      },
    );
  }
}
