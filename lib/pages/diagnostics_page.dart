import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loc/app/app_controller.dart';
import 'package:loc/data/services/app_diagnostics.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DiagnosticsPage extends StatefulWidget {
  const DiagnosticsPage({super.key});

  @override
  State<DiagnosticsPage> createState() => _DiagnosticsPageState();
}

class _DiagnosticsPageState extends State<DiagnosticsPage> {
  String? _report;

  @override
  void initState() {
    super.initState();
    _run();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Support diagnostics')),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        const Text(
          'The report contains no coordinates, search text, reminder names, '
          'device identifiers, or automatic telemetry.',
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _report == null
                ? const Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('Running checks…'),
                    ],
                  )
                : SelectableText(
                    _report!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _report == null ? null : _copy,
          icon: const Icon(Icons.copy_rounded),
          label: const Text('Copy diagnostics'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _run,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Run checks again'),
        ),
        TextButton.icon(
          onPressed: _reportIssue,
          icon: const Icon(Icons.open_in_new_rounded),
          label: const Text('Report an issue on GitHub'),
        ),
      ],
    ),
  );

  Future<void> _run() async {
    setState(() => _report = null);
    final report = await AppDiagnostics.createReport(
      isTracking: context.read<AppController>().isTrackingLocation,
    );
    if (mounted) setState(() => _report = report);
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _report!));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Diagnostics copied.')));
    }
  }

  Future<void> _reportIssue() async {
    final opened = await launchUrl(
      Uri.parse('https://github.com/AbdeltwabMF/loc/issues/new/choose'),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open GitHub.')));
    }
  }
}
