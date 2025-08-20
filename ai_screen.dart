import 'package:flutter/material.dart';

class AIScreen extends StatefulWidget {
  const AIScreen({super.key});
  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  final _ctrl = TextEditingController();
  final List<Map<String,String>> _messages = [
    {'role':'assistant', 'text':'Hi! I'm MAS AI. Ask me about payments, SWIFT, charges, or OCR.'}
  ];

  void _send() {
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _messages.add({'role':'user','text': t});
      _messages.add({'role':'assistant','text': 'Demo: I can explain fees, SWIFT (BIC), and validate IBAN formats.'});
      _ctrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _messages.length,
            itemBuilder: (c, i) {
              final m = _messages[i];
              final isUser = m['role']=='user';
              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser ? const Color(0xFF123D7A) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    m['text'] ?? '',
                    style: TextStyle(color: isUser ? Colors.white : Colors.black87),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8,0,8,12),
          child: Row(
            children: [
              Expanded(child: TextField(controller: _ctrl, decoration: const InputDecoration(hintText: 'Ask about payments…'))),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: _send, child: const Text('Send'))
            ],
          ),
        )
      ],
    );
  }
}
