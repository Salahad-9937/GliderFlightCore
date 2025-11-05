import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/flight_program.dart';
import '../../domain/repositories/flight_program_repository.dart';

/// Провайдер для репозитория полетных программ.
final flightProgramRepositoryProvider = Provider<FlightProgramRepository>((ref) {
  return LocalFileFlightProgramRepository();
});

/// Реализация репозитория, хранящая программы в JSON-файлах.
///
/// Для каждого профиля планера создается свой файл `flight_programs_{profileId}.json`.
class LocalFileFlightProgramRepository implements FlightProgramRepository {
  Future<File> _getFile(String profileId) async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/flight_programs_$profileId.json');
  }

  @override
  Future<List<FlightProgram>> getPrograms(String profileId) async {
    try {
      final file = await _getFile(profileId);
      if (!await file.exists()) {
        return [];
      }
      final contents = await file.readAsString();
      final List<dynamic> jsonData = json.decode(contents);
      return jsonData.map((item) => FlightProgram.fromMap(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _writePrograms(String profileId, List<FlightProgram> programs) async {
    final file = await _getFile(profileId);
    final List<Map<String, dynamic>> jsonData = programs.map((p) => p.toMap()).toList();
    await file.writeAsString(json.encode(jsonData));
  }

  @override
  Future<void> saveProgram(String profileId, FlightProgram program) async {
    final programs = await getPrograms(profileId);
    final index = programs.indexWhere((p) => p.id == program.id);
    if (index != -1) {
      programs[index] = program;
    } else {
      programs.add(program);
    }
    await _writePrograms(profileId, programs);
  }

  @override
  Future<void> deleteProgram(String profileId, String programId) async {
    final programs = await getPrograms(profileId);
    programs.removeWhere((p) => p.id == programId);
    await _writePrograms(profileId, programs);
  }
}