import 'package:flutter/material.dart';

import 'profile_storage.dart';
import 'striped_background.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key, this.initialName = '', required this.onDone});

  final String initialName;
  final ValueChanged<String> onDone;

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  late final _controller = TextEditingController(text: widget.initialName);
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _continue() {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() =>
          _error = 'Napiš, jak tě máme oslovovat, nebo dej Přeskočit.');
      return;
    }
    if (!ProfileStorage.isValidName(name)) {
      setState(() => _error =
          'Použij jen písmena, mezeru, pomlčku nebo apostrof (max. 30 znaků).');
      return;
    }
    widget.onDone(name);
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.initialName.isNotEmpty;

    return StripedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Feel & Flow 🌸',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink.shade700,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Jak tě máme oslovovat?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  maxLength: 30,
                  decoration: InputDecoration(
                    labelText: 'Jméno nebo přezdívka',
                    helperText: 'Napiš tvar, jak tě máme oslovit (např. Míšo).',
                    errorText: _error,
                  ),
                  onSubmitted: (_) => _continue(),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _continue,
                  child: const Text('Pokračovat'),
                ),
                TextButton(
                  onPressed: () => widget.onDone(''),
                  child: Text(editing ? 'Smazat jméno' : 'Přeskočit'),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Jméno zůstane jen v tomto zařízení.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
