import 'package:flutter/material.dart';

class StripedBackground extends StatelessWidget {
  const StripedBackground({super.key, required this.child});

  final Widget child;

 static const backgroundColor = Color(0xFFFFE680);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: backgroundColor, child: child);
  }
}
