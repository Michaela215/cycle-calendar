import 'package:flutter/material.dart';

import 'striped_background.dart';

const _textColor = Color(0xFF4A3B2A);

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.userName,
    required this.onOpenCalendar,
    this.onEditName,
  });

  final String userName;
  final VoidCallback onOpenCalendar;
  final VoidCallback? onEditName;

  @override
  Widget build(BuildContext context) {
    return StripedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.person_outline),
              tooltip: 'Změnit oslovení',
              onPressed: onEditName,
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Text(
                  'Feel & Flow 🌸',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  userName.isEmpty ? 'Vítej' : 'Vítej, $userName',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, color: _textColor),
                ),
                const SizedBox(height: 40),
                Center(
                  child: Tooltip(
                    message: 'Otevřít kalendář',
                    child: InkWell(
                      onTap: onOpenCalendar,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_month,
                              size: 56,
                              color: Colors.pink.shade700,
                              semanticLabel: 'Otevřít kalendář',
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Kalendář',
                              style: TextStyle(fontSize: 18, color: _textColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                const Text(
                  'Feel & Flow není zdravotnický prostředek ani antikoncepce. '
                  'Odhady jsou pouze orientační.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: _textColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
