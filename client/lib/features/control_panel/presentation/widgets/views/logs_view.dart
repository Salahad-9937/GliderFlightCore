import 'package:flutter/material.dart';
import '../flight_history_section.dart';

/// Вкладка "Логи": выгрузка данных и визуализация.
class LogsView extends StatelessWidget {
  const LogsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      children: const [FlightHistorySection()],
    );
  }
}
