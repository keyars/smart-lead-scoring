import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8000',
);

void main() => runApp(const SmartLeadScoringApp());

class SmartLeadScoringApp extends StatelessWidget {
  const SmartLeadScoringApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.indigo);
    return MaterialApp(
      title: 'Smart Lead Scoring',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorScheme: scheme, scaffoldBackgroundColor: const Color(0xFFF7F8FC)),
      home: const LeadScoringPage(),
    );
  }
}

class LeadField {
  const LeadField(this.key, this.label, this.help, this.initial);
  final String key;
  final String label;
  final String help;
  final String initial;
}

const leadFields = [
  LeadField('company_size', 'Company size', 'Number of employees', '250'),
  LeadField('website_visits', 'Website visits', 'Recent visits from this lead', '35'),
  LeadField('email_opens', 'Email opens', 'Marketing emails opened', '16'),
  LeadField('form_submissions', 'Form submissions', 'Forms submitted', '3'),
  LeadField('sales_calls', 'Sales calls', 'Sales conversations', '2'),
  LeadField('days_since_first_contact', 'Days since first contact', 'Age of the lead', '8'),
];

class LeadScoringPage extends StatefulWidget {
  const LeadScoringPage({super.key});

  @override
  State<LeadScoringPage> createState() => _LeadScoringPageState();
}

class _LeadScoringPageState extends State<LeadScoringPage> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> controllers = {
    for (final field in leadFields) field.key: TextEditingController(text: field.initial),
  };

  Map<String, dynamic>? result;
  bool loading = false;

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void loadDemo() {
    for (final field in leadFields) {
      controllers[field.key]!.text = field.initial;
    }
    setState(() => result = null);
  }

  void clearForm() {
    for (final controller in controllers.values) {
      controller.clear();
    }
    setState(() => result = null);
  }

  Future<void> scoreLead() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => loading = true);

    try {
      final body = {
        for (final field in leadFields) field.key: int.parse(controllers[field.key]!.text),
      };
      final response = await http
          .post(
            Uri.parse('$apiBaseUrl/predict'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('API returned ${response.statusCode}');
      }

      if (!mounted) return;
      setState(() => result = jsonDecode(response.body) as Map<String, dynamic>);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not reach the scoring API. Check that the API is running.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  String _priorityDescription(String priority) {
    switch (priority) {
      case 'High':
        return 'Strong conversion signal — prioritise follow-up.';
      case 'Medium':
        return 'Promising lead — keep engaged and qualify further.';
      default:
        return 'Low conversion signal — consider nurturing this lead.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Lead Scoring', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(onPressed: loadDemo, tooltip: 'Load demo lead', icon: const Icon(Icons.auto_awesome_outlined)),
          IconButton(onPressed: clearForm, tooltip: 'Clear form', icon: const Icon(Icons.refresh_rounded)),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              children: [
                _Header(onDemo: loadDemo),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 800;
                    if (wide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildForm()),
                          const SizedBox(width: 20),
                          Expanded(child: _buildResult()),
                        ],
                      );
                    }
                    return Column(children: [_buildForm(), const SizedBox(height: 20), _buildResult()]);
                  },
                ),
                const SizedBox(height: 18),
                const _Disclaimer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(icon: Icons.tune_rounded, title: 'Lead signals', subtitle: 'Tell us what you know about this prospect.'),
              const SizedBox(height: 20),
              ...leadFields.map((field) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextFormField(
                      controller: controllers[field.key],
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: field.label,
                        helperText: field.help,
                        prefixIcon: const Icon(Icons.numbers_rounded),
                      ),
                      validator: (value) {
                        final number = int.tryParse(value ?? '');
                        if (number == null) return 'Enter a whole number';
                        if (number < 0) return 'Value cannot be negative';
                        return null;
                      },
                    ),
                  )),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: loading ? null : scoreLead,
                  icon: loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.auto_graph_rounded),
                  label: Text(loading ? 'Analysing lead...' : 'Score this lead'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResult() {
    if (result == null) {
      return Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: const [
              Icon(Icons.insights_rounded, size: 52),
              SizedBox(height: 16),
              Text('Your score will appear here', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              SizedBox(height: 8),
              Text('Submit the lead signals to get a conversion probability and sales priority.', textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    final score = (result!['score'] as num).toInt();
    final probability = (result!['probability'] as num).toDouble();
    final priority = result!['priority'] as String;
    final pct = (probability * 100).toStringAsFixed(1);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle(icon: Icons.insights_rounded, title: 'Scoring result', subtitle: 'Model prediction based on the submitted signals.'),
            const SizedBox(height: 24),
            Center(
              child: SizedBox(
                width: 190,
                height: 190,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(value: score / 100, strokeWidth: 14),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$score', style: const TextStyle(fontSize: 58, fontWeight: FontWeight.w800, height: 1)),
                        const Text('/ 100', style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            Center(child: Chip(avatar: const Icon(Icons.flag_rounded, size: 18), label: Text('$priority priority'))),
            const SizedBox(height: 18),
            LinearProgressIndicator(value: probability, minHeight: 10, borderRadius: BorderRadius.circular(10)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Conversion probability', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('$pct%', style: const TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Theme.of(context).colorScheme.surfaceContainerHighest),
              child: Text(_priorityDescription(priority)),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => setState(() => result = null),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Score another lead'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onDemo});
  final VoidCallback onDemo;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Know which leads deserve attention.', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, height: 1.15)),
              SizedBox(height: 8),
              Text('Use a lightweight machine-learning model to estimate conversion likelihood from CRM activity.'),
            ],
          ),
        ),
        const SizedBox(width: 16),
        FilledButton.tonalIcon(onPressed: onDemo, icon: Icon(Icons.auto_awesome), label: Text('Try demo')),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w750)), const SizedBox(height: 3), Text(subtitle)])),
      ],
    );
  }
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context) => Text(
        'Demo model: the training dataset is synthetic. Validate against representative historical CRM data before using scores for operational decisions.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall,
      );
}
