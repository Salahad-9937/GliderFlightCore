import 'package:flutter/material.dart';

/// Секция для управления полетными программами.
///
/// ЗАГЛУШКА: В будущем будет заменен виджетом из фичи flight_programs.
class FlightProgramsSection extends StatelessWidget {
  const FlightProgramsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Полетные программы', style: Theme.of(context).textTheme.titleLarge),
            IconButton(
              onPressed: () {
                // TODO: Реализовать создание новой программы
              },
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Создать программу',
            )
          ],
        ),
        const SizedBox(height: 8),
        const Card(
          child: ListTile(title: Text('Нет созданных программ')),
        )
      ],
    );
  }
}