import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const SmartLeadScoringApp());

class SmartLeadScoringApp extends StatelessWidget {
  const SmartLeadScoringApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Lead Scoring',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const LeadScoringPage(),
    );
  }
}

class LeadScoringPage extends StatefulWidget {
  const LeadScoringPage({super.key});

  @override
  State<LeadScoringPage> createState() => _LeadScoringPageState();
}

class _LeadScoringPageState extends State<LeadScoringPage> {
  final fields = <String, TextEditingController>{
    'company_size': TextEditingController(text: '250'),
    'website_visits': TextEditingController(text: '35'),
    'email_opens': TextEditingController(text: '16'),
    'form_submissions': TextEditingController(text: '3'),
    'sales_calls': TextEditingController(text: '2'),
    'days_since_first_contact': TextEditingController(text: '8'),
  };
  Map<String, dynamic>? result;
  bool loading = false;

  Future<void> scoreLead() async {
    setState(() => loading = true);
    try {
      final body = fields.map((key, value) => MapEntry(key, int.parse(value.text)));
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (response.statusCode != 200) throw Exception('API error');
      setState(() => result = jsonDecode(response.body) as Map<String, dynamic>);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to reach the scoring API.')),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Lead Scoring')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Score a Lead', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Enter CRM activity and predict conversion likelihood.'),
          const SizedBox(height: 20),
          ...fields.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  controller: entry.value,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: entry.key.replaceAll('_', ' '),
                    border: const OutlineInputBorder(),
                  ),
                ),
              )),
          FilledButton.icon(
            onPressed: loading ? null : scoreLead,
            icon: loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator()) : const Icon(Icons.analytics),
            label: Text(loading ? 'Scoring...' : 'Calculate Lead Score'),
          ),
          if (result != null) ...[
            const SizedBox(height: 28),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text('Lead Score', style: TextStyle(fontSize: 16)),
                    Text('${result!['score']}', style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold)),
                    Text('${result!['probability'] * 100}% conversion probability'),
                    const SizedBox(height: 12),
                    Chip(label: Text('${result!['priority']} Priority')),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
