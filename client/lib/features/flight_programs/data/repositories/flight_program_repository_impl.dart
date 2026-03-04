import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/architecture/failure.dart';
import '../../../../core/architecture/result.dart';
import '../../domain/entities/flight_program.dart';
import '../../domain/repositories/flight_program_repository.dart';
import '../mappers/flight_program_mapper.dart';
import '../models/flight_program_dto.dart';

part 'flight_program_repository_impl.g.dart';

/// Провайдер реализации репозитория полетных программ.
@riverpod
IFlightProgramRepository flightProgramRepository(Ref ref) {
  return LocalFileFlightProgramRepository();
}

/// Реализация репозитория, хранящая программы в локальных JSON-файлах.
class LocalFileFlightProgramRepository implements IFlightProgramRepository {
  Future<File> _getFile(String profileId) async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/flight_programs_$profileId.json');
  }

  @override
  Future<Result<List<FlightProgram>, Failure>> getPrograms(
    String profileId,
  ) async {
    try {
      final file = await _getFile(profileId);
      if (!await file.exists()) {
        return const Success([]);
      }

      final contents = await file.readAsString();
      final List<dynamic> jsonData = json.decode(contents);

      final programs = jsonData
          .map(
            (item) => FlightProgramDto.fromJson(item as Map<String, dynamic>),
          )
          .map((dto) => FlightProgramMapper.toEntity(dto))
          .toList();

      return Success(programs);
    } catch (e) {
      return Error(StorageFailure('Ошибка чтения программ: $e'));
    }
  }

  Future<Result<void, Failure>> _writePrograms(
    String profileId,
    List<FlightProgram> programs,
  ) async {
    try {
      final file = await _getFile(profileId);
      final jsonData = programs
          .map((p) => FlightProgramMapper.fromEntity(p).toJson())
          .toList();

      await file.writeAsString(json.encode(jsonData));
      return const Success(null);
    } catch (e) {
      return Error(StorageFailure('Ошибка записи программ: $e'));
    }
  }

  @override
  Future<Result<void, Failure>> saveProgram(
    String profileId,
    FlightProgram program,
  ) async {
    final result = await getPrograms(profileId);

    return result.fold((programs) async {
      final list = List<FlightProgram>.from(programs);
      final index = list.indexWhere((p) => p.id == program.id);

      if (index != -1) {
        list[index] = program;
      } else {
        list.add(program);
      }

      return _writePrograms(profileId, list);
    }, (failure) => Error(failure));
  }

  @override
  Future<Result<void, Failure>> deleteProgram(
    String profileId,
    String programId,
  ) async {
    final result = await getPrograms(profileId);

    return result.fold((programs) async {
      final list = List<FlightProgram>.from(programs);
      list.removeWhere((p) => p.id == programId);
      return _writePrograms(profileId, list);
    }, (failure) => Error(failure));
  }
}
