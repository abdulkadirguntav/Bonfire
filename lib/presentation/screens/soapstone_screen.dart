import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bonfire/domain/services/soapstone_service.dart';
import 'package:bonfire/presentation/providers/soapstone_provider.dart';
import 'package:bonfire/presentation/providers/user_provider.dart';

class SoapstoneScreen extends ConsumerStatefulWidget {
  const SoapstoneScreen({super.key});

  @override
  ConsumerState<SoapstoneScreen> createState() => _SoapstoneScreenState();
}

class _SoapstoneScreenState extends ConsumerState<SoapstoneScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userControllerProvider);
    final today = DateTime.now();
    final soapstone = ref.watch(soapstonesProvider).where((item) {
      return item.date.year == today.year &&
          item.date.month == today.month &&
          item.date.day == today.day;
    }).firstOrNull;

    final unlocked = user != null && SoapstoneService.isUnlocked(user);
    final items = ref.watch(soapstonesProvider);

    if (!unlocked) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D0B09),
        body: Center(
          child: Text(
            'The soapstone is still silent.',
            style: TextStyle(
              color: Color(0xFFB2BAC7),
              fontSize: 18,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0B09),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 12),
              const Text(
                'Soapstone',
                style: TextStyle(
                  color: Color(0xFFD7BE7D),
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              if (soapstone == null &&
                  SoapstoneService.canCreateToday(items, today))
                Column(
                  children: [
                    TextField(
                      controller: _controller,
                      maxLines: 5,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.6,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Leave a message for the next wanderer...',
                        hintStyle: TextStyle(
                          color: Color(0xFF8E8E90),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFB89B5B)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () async {
                          final message = _controller.text.trim();
                          if (message.isEmpty) return;

                          final soap = SoapstoneService.createSoapstone(
                            message: message,
                            date: today,
                          );

                          await ref
                              .read(soapstonesProvider.notifier)
                              .addSoapstone(soap);
                          _controller.clear();
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFB89B5B),
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Leave the stone'),
                      ),
                    ),
                  ],
                )
              else if (soapstone != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFB89B5B)),
                    color: const Color(0xFF17130F),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Message',
                        style: TextStyle(
                          color: Color(0xFFB89B5B),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        soapstone.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (SoapstoneService.canEditToday(soapstone, today))
                        TextButton(
                          onPressed: () async {
                            final edited = _controller.text.trim();
                            if (edited.isEmpty) return;

                            final updated = soapstone.copyWith(
                              message: edited,
                              isEdited: true,
                            );

                            await ref
                                .read(soapstonesProvider.notifier)
                                .updateSoapstone(updated);
                          },
                          child: const Text('Edit message'),
                        )
                      else
                        const Text(
                          'Edited once and sealed.',
                          style: TextStyle(color: Color(0xFFB2BAC7)),
                        ),
                    ],
                  ),
                )
              else
                const Text(
                  'A note is already waiting here for today.',
                  style: TextStyle(color: Color(0xFFB2BAC7)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
