import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class ConfettiWidgetCustom extends StatefulWidget {
  const ConfettiWidgetCustom({super.key});

  @override
  State<ConfettiWidgetCustom> createState() => _ConfettiWidgetCustomState();
}

class _ConfettiWidgetCustomState extends State<ConfettiWidgetCustom> {
  late ConfettiController controller;

  @override
  void initState() {
    super.initState();
    controller = ConfettiController(duration: Duration(seconds: 2));
    controller.play();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConfettiWidget(
      confettiController: controller,
      blastDirectionality: BlastDirectionality.explosive,
      shouldLoop: false,
    );
  }
}