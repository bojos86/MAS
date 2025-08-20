import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mas_app/services/iban.dart';
import 'package:mas_app/services/swift_bic.dart';
import 'package:mas_app/services/currency.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});
  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _debitCtrl = TextEditingController();   // BBK debit account (12 digits starting 12/22)
  final _benefNameCtrl = TextEditingController();
  final _ibanCtrl = TextEditingController();
  final _acctCtrl = TextEditingController();
  final _bicCtrl = TextEditingController();
  final _interBankCtrl = TextEditingController();
  final _interBicCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _purposeCodeCtrl = TextEditingController();
  final _field70Ctrl = TextEditingController();

  bool _useIban = true;
  bool _useIntermediary = false;
  String _currency = 'KWD';
  String _charges = 'SHA';

  @override
  void dispose() {
    _debitCtrl.dispose();
    _benefNameCtrl.dispose();
    _ibanCtrl.dispose();
    _acctCtrl.dispose();
    _bicCtrl.dispose();
    _interBankCtrl.dispose();
    _interBicCtrl.dispose();
    _amountCtrl.dispose();
    _purposeCodeCtrl.dispose();
    _field70Ctrl.dispose();
    super.dispose();
  }

  String? _validateDebit(String? v) {
    final s = (v ?? '').trim();
    if (s.length != 12) return 'Debit account must be 12 digits';
    if (!RegExp(r'^\d{12}\$').hasMatch(s)) return 'Digits only';
    if (!(s.startsWith('12') || s.startsWith('22'))) return 'Must start with 12 or 22';
    return null;
  }

  String? _validateIBAN(String? v) {
    final s = (v ?? '').replaceAll(' ', '').toUpperCase();
    if (s.isEmpty) return 'Required';
    if (_useIban) {
      if (s.length != 30) return 'Kuwait IBAN length must be 30';
      if (!s.startsWith('KW')) return 'IBAN must start with KW';
      if (!Iban.isValid(s)) return 'Invalid IBAN checksum';
    }
    return null;
  }

  String? _validateAccount(String? v) {
    if (_useIban) return null;
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Required';
    // For non-IBAN countries allow up to 34, here minimally require 6+
    if (s.length < 6) return 'Account number too short';
    return null;
  }

  String? _validateBIC(String? v) {
    final s = (v ?? '').trim().toUpperCase();
    if (s.isEmpty) return 'Required';
    if (!SwiftBic.isFormatValid(s)) return 'Invalid BIC format';
    if (!SwiftBic.isKnownOrFormat(s)) {
      return 'BIC not recognized (format ok)';
    }
    return null;
  }

  String? _validateAmount(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Required';
    if (!RegExp(r'^\d+(?:\.\d{1,3})?\$').hasMatch(s)) return 'Amount must be like 123 or 123.456';
    return null;
  }

  String? _validateCharges(String? v) {
    if (v == null || v.isEmpty) return 'Select charges';
    return null;
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Review & Approve'),
          content: const Text('All validations passed. This would submit to AML and await approval.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Submitted (Demo)')));
            }, child: const Text('Submit')),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencies = Currency.supported;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Payment Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),

            TextFormField(
              controller: _debitCtrl,
              decoration: const InputDecoration(labelText: 'Debit Account (BBK 12 digits starting 12/22)'),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(12)],
              keyboardType: TextInputType.number,
              validator: _validateDebit,
            ),

            const SizedBox(height: 10),
            TextFormField(
              controller: _benefNameCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(labelText: 'Beneficiary Name (CAPS)'),
              inputFormatters: [UpperCaseTextFormatter()],
              validator: (v) => v==null || v.trim().isEmpty ? 'Required' : null,
            ),

            const SizedBox(height: 10),
            SwitchListTile(
              value: _useIban,
              onChanged: (v) => setState(() => _useIban = v),
              title: const Text('Use IBAN (if off: Account Number)'),
            ),

            if (_useIban)
              TextFormField(
                controller: _ibanCtrl,
                decoration: const InputDecoration(labelText: 'IBAN (KW ** 30 chars)'),
                inputFormatters: [UpperCaseTextFormatter(), LengthLimitingTextInputFormatter(30)],
                validator: _validateIBAN,
              )
            else
              TextFormField(
                controller: _acctCtrl,
                decoration: const InputDecoration(labelText: 'Account Number (non-IBAN)'),
                inputFormatters: [UpperCaseTextFormatter(), LengthLimitingTextInputFormatter(34)],
                validator: _validateAccount,
              ),

            const SizedBox(height: 10),
            TextFormField(
              controller: _bicCtrl,
              decoration: const InputDecoration(labelText: 'Beneficiary Bank BIC / SWIFT'),
              inputFormatters: [UpperCaseTextFormatter(), LengthLimitingTextInputFormatter(11)],
              validator: _validateBIC,
            ),

            const SizedBox(height: 10),
            SwitchListTile(
              value: _useIntermediary,
              onChanged: (v) => setState(() => _useIntermediary = v),
              title: const Text('Use Intermediary Bank'),
            ),
            if (_useIntermediary) ...[
              TextFormField(
                controller: _interBankCtrl,
                decoration: const InputDecoration(labelText: 'Intermediary Bank Name'),
                inputFormatters: [UpperCaseTextFormatter(), LengthLimitingTextInputFormatter(64)],
              ),
              TextFormField(
                controller: _interBicCtrl,
                decoration: const InputDecoration(labelText: 'Intermediary Bank BIC'),
                inputFormatters: [UpperCaseTextFormatter(), LengthLimitingTextInputFormatter(11)],
                validator: (v) {
                  if (v==null || v.isEmpty) return 'Required when intermediary enabled';
                  if (!SwiftBic.isFormatValid(v.trim().toUpperCase())) return 'Invalid BIC';
                  return null;
                },
              ),
            ],

            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Currency'),
                    value: _currency,
                    items: currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => _currency = v ?? 'KWD'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _amountCtrl,
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: _validateAmount,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            TextFormField(
              controller: _purposeCodeCtrl,
              decoration: const InputDecoration(labelText: 'Purpose Code (optional for now)'),
              inputFormatters: [UpperCaseTextFormatter(), LengthLimitingTextInputFormatter(10)],
            ),

            const SizedBox(height: 10),
            TextFormField(
              controller: _field70Ctrl,
              decoration: const InputDecoration(labelText: 'Field 70 – Purpose of Payment (mandatory)'),
              inputFormatters: [UpperCaseTextFormatter(), LengthLimitingTextInputFormatter(140)],
              validator: (v) => v==null || v.trim().isEmpty ? 'Required' : null,
            ),

            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Charges'),
              value: _charges,
              items: const [
                DropdownMenuItem(value: 'OUR', child: Text('OUR')),
                DropdownMenuItem(value: 'SHA', child: Text('SHA')),
              ],
              onChanged: (v) => setState(() => _charges = v ?? 'SHA'),
              validator: _validateCharges,
            ),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Future: fill from OCR result via state or provider
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OCR paste (demo)')));
                    },
                    icon: const Icon(Icons.paste),
                    label: const Text('Paste OCR'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.check),
                    label: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
