import 'package:flutter/material.dart';
import '../models/wellbeing_models.dart';
import '../theme/app_theme.dart';

class MessageDeck extends StatefulWidget {
  final List<InsightItem> messages;
  const MessageDeck({required this.messages, super.key});
  @override
  State<MessageDeck> createState() => _MessageDeckState();
}

class _MessageDeckState extends State<MessageDeck> {
  int _index = 0;
  @override
  Widget build(BuildContext context) {
    if (widget.messages.isEmpty) return const SizedBox.shrink();
    final index = _index % widget.messages.length;
    final message = widget.messages[index];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
          color: const Color(0xFFEAF0DF),
          borderRadius: BorderRadius.circular(26)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.wb_sunny_outlined, color: AppTheme.forest),
          const SizedBox(width: 10),
          Expanded(
              child: Text('Un mensaje para ti · ${message.label}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: AppTheme.forest)))
        ]),
        const SizedBox(height: 18),
        AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Column(
                key: ValueKey('${message.title}$index'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message.title,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  Text(message.body, style: const TextStyle(height: 1.55)),
                ])),
        const SizedBox(height: 14),
        Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            children: [
              Text('${index + 1} / ${widget.messages.length}',
                  style: Theme.of(context).textTheme.bodySmall),
              TextButton.icon(
                  onPressed: () => setState(() => _index++),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('Otro mensaje'))
            ]),
      ]),
    );
  }
}
