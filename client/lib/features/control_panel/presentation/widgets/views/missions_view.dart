import 'package:flutter/material.dart';
import '../../../../flight_programs/presentation/widgets/flight_programs_list.dart';

/// Вкладка "Миссии": управление полетными программами.
class MissionsView extends StatelessWidget {
  final String profileId;
  const MissionsView({super.key, required this.profileId});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      children: [FlightProgramsList(profileId: profileId)],
    );
  }
}
