import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

void main() {
  runApp(const MASApp());
}

class MASApp extends StatelessWidget {
  const MASApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MAS AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF123D7A),
          primary: const Color(0xFF123D7A),
          secondary: const Color(0xFFFFB400),
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F8FC),
        useMaterial3: true,
      ),
      home: const MASHome(),
    );
  }
}

class MASHome extends StatefulWidget {
  const MASHome({super.key});

  @override
  State<MASHome> createState() => _MASHomeState();
}

class _MASHomeState extends State<MASHome> {
  int _tab = 0;

  final tabs = const [
    Icon(Icons.payments_rounded),
    Icon(Icons.smart_toy_rounded),
    Icon(Icons.settings_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      const PaymentsPage(),
      const AIChatPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('MAS AI Mobile'),
        centerTitle: true,
      ),
      body: pages[_tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(Icons.payments_rounded),
            label: 'Payments',
          ),
          NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined),
            selectedIcon: Icon(Icons.smart_toy_rounded),
            label: 'AI Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

/// ------------------- Payments (Mock) -------------------
class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  final _form = GlobalKey<FormState>();

  final _beneficiaryName = TextEditingController();
  final _iban = TextEditingController();
  final _swift = TextEditingController();
  final _amount = TextEditingController();
  String _currency = 'KWD';
  String _charges = 'SHA';
  final _purpose = TextEditingController();

  final currencies = const [
    'AED','SAR','BHD','OMR','QAR',
    'USD','EUR','GBP','KWD','INR','CHF','JPY'
  ];

  @override
  void dispose() {
    _beneficiaryName.dispose();
    _iban.dispose();
    _swift.dispose();
    _amount.dispose();
    _purpose.dispose();
    super.dispose();
  }

  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;
  String? _ibanRule(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    if (v.length < 12 || v.length > 34) return 'IBAN/Account length looks invalid';
    return null;
  }
  String? _swiftRule(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final s = v.trim().toUpperCase();
    final ok = RegExp(r'^[A-Z0-9]{8}([A-Z0-9]{3})?$').hasMatch(s);
    return ok ? null : 'SWIFT/BIC must be 8 or 11 chars';
  }
  String? _amountRule(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final d = double.tryParse(v);
    if (d == null || d <= 0) return 'Enter a valid amount';
    return null;
  }

  void _submit() {
    final valid = _form.currentState?.validate() ?? false;
    if (!valid) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Mock Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Beneficiary: ${_beneficiaryName.text}'),
            Text('IBAN/Account: ${_iban.text}'),
            Text('SWIFT: ${_swift.text}'),
            Text('Amount: ${_amount.text} $_currency'),
            Text('Charges: $_charges'),
            Text('Purpose: ${_purpose.text}'),
            const SizedBox(height: 12),
            const Text('AML & Sanctions: screened (demo) ✅'),
            const Text('MT103: generated on approval (demo) ✅'),
          ],
        ),
        actions: [
            TextButton(onPressed: ()=> Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(onPressed: (){
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment submitted (DEMO). Requires staff approval.'))
              );
            }, child: const Text('Submit')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    InputDecoration dec(String label, {String? hint}) => InputDecoration(
      labelText: label.toUpperCase(),
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _form,
        child: ListView(
          children: [
            Text('International Transfer (Demo)',
              style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextFormField(
              controller: _beneficiaryName,
              textCapitalization: TextCapitalization.characters,
              validator: _req,
              decoration: dec('Beneficiary Name'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _iban,
              textCapitalization: TextCapitalization.characters,
              validator: _ibanRule,
              decoration: dec('IBAN / Account Number', hint: 'Example: KW18BRGN... or account'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _swift,
              textCapitalization: TextCapitalization.characters,
              validator: _swiftRule,
              decoration: dec('SWIFT/BIC', hint: '8 or 11 chars (e.g., BRGNKWKW)'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _amount,
                    validator: _amountRule,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: dec('Amount'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _currency,
                    items: currencies.map((c)=>DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v)=> setState(()=> _currency = v ?? _currency),
                    decoration: dec('Currency'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _charges,
              items: const [
                DropdownMenuItem(value: 'OUR', child: Text('OUR')),
                DropdownMenuItem(value: 'SHA', child: Text('SHA')),
              ],
              onChanged: (v)=> setState(()=> _charges = v ?? _charges),
              decoration: dec('Charges'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _purpose,
              maxLines: 2,
              validator: _req,
              decoration: dec('Purpose of Payment (Field 70)'),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text('Submit (Demo)'),
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

/// ------------------- AI Chat (OpenAI) -------------------
class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _messages = [];
  bool _busy = false;

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<String?> _loadKey() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString('openai_api_key');
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _busy) return;

    final key = await _loadKey();
    if (key == null || key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Set OpenAI API Key in Settings first.')),
      );
      return;
    }

    setState(() {
      _messages.add(_Msg(role: 'user', content: text));
      _busy = true;
      _ctrl.clear();
    });

    try {
      final reply = await _callOpenAI(key, _messages);
      setState(() => _messages.add(_Msg(role: 'assistant', content: reply ?? '')));
      await Future.delayed(const Duration(milliseconds: 100));
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OpenAI error: $e')),
      );
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<String?> _callOpenAI(String apiKey, List<_Msg> messages) async {
    final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
    final body = {
      'model': 'gpt-4o-mini', // خفيف وسريع للتجربة
      'messages': messages.map((m) => {'role': m.role, 'content': m.content}).toList(),
      'temperature': 0.3,
    };
    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(body),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final choices = json['choices'] as List<dynamic>?;
      if (choices != null && choices.isNotEmpty) {
        final msg = choices.first['message'];
        return msg['content'] as String?;
      }
      return 'No response.';
    } else {
      throw 'HTTP ${res.statusCode}: ${res.body}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.all(12),
            itemCount: _messages.length,
            itemBuilder: (ctx, i) {
              final m = _messages[i];
              final isUser = m.role == 'user';
              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(12),
                  constraints: const BoxConstraints(maxWidth: 640),
                  decoration: BoxDecoration(
                    color: isUser ? const Color(0xFF123D7A) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8, spreadRadius: 1, offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: isUser
                      ? Text(m.content, style: const TextStyle(color: Colors.white))
                      : MarkdownBody(data: m.content),
                ),
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    minLines: 1,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Ask MAS AI…',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _busy ? null : _send,
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Send'),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class _Msg {
  final String role; // 'user' or 'assistant'
  final String content;
  _Msg({required this.role, required this.content});
}

/// ------------------- Settings (API Key) -------------------
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _keyCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    _keyCtrl.text = sp.getString('openai_api_key') ?? '';
    setState(() {});
  }

  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('openai_api_key', _keyCtrl.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved OpenAI API Key')),
    );
  }

  @override
  void dispose() {
    _keyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Configuration', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        TextField(
          controller: _keyCtrl,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'OpenAI API Key',
            hintText: 'sk-...',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save),
          label: const Text('Save'),
        ),
        const SizedBox(height: 24),
        const Text(
          'Note: Payments are DEMO only (no real money). AML/Sanctions & MT103 are simulated.',
          style: TextStyle(color: Colors.black54),
        ),
      ],
    );
  }
}
