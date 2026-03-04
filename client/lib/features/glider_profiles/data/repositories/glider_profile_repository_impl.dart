import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/architecture/failure.dart';
import '../../../../core/architecture/result.dart';
import '../../domain/entities/glider_profile.dart';
import '../../domain/repositories/glider_profile_repository.dart';
import '../mappers/glider_profile_mapper.dart';
import '../models/glider_profile_dto.dart';

part 'glider_profile_repository_impl.g.dart';

/// Провайдер реализации репозитория профилей.
@riverpod
IGliderProfileRepository gliderProfileRepository(Ref ref) {
  return LocalFileGliderProfileRepository();
}

/// Реализация репозитория, работающая с локальным JSON-файлом.
class LocalFileGliderProfileRepository implements IGliderProfileRepository {
  static const _fileName = 'glider_profiles.json';

  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  @override
  Future<Result<List<GliderProfile>, Failure>> getGliderProfiles() async {
    try {
      final file = await _getLocalFile();
      if (!await file.exists()) {
        return const Success([]);
      }
      final contents = await file.readAsString();
      final List<dynamic> jsonData = json.decode(contents);

      final profiles = jsonData
          .map(
            (item) => GliderProfileDto.fromJson(item as Map<String, dynamic>),
          )
          .map((dto) => GliderProfileMapper.toEntity(dto))
          .toList();

      return Success(profiles);
    } catch (e) {
      return Error(StorageFailure('Ошибка чтения профилей: $e'));
    }
  }

  Future<Result<void, Failure>> _writeProfiles(
    List<GliderProfile> profiles,
  ) async {
    try {
      final file = await _getLocalFile();
      final jsonData = profiles
          .map((p) => GliderProfileMapper.fromEntity(p).toJson())
          .toList();
      await file.writeAsString(json.encode(jsonData));
      return const Success(null);
    } catch (e) {
      return Error(StorageFailure('Ошибка записи профилей: $e'));
    }
  }

  @override
  Future<Result<void, Failure>> saveGliderProfile(GliderProfile profile) async {
    final result = await getGliderProfiles();
    return result.fold((profiles) {
      final list = List<GliderProfile>.from(profiles);
      final index = list.indexWhere((p) => p.id == profile.id);
      if (index != -1) {
        list[index] = profile;
      } else {
        list.add(profile);
      }
      return _writeProfiles(list);
    }, (failure) => Error(failure));
  }

  @override
  Future<Result<void, Failure>> deleteGliderProfile(String id) async {
    final result = await getGliderProfiles();
    return result.fold((profiles) {
      final list = List<GliderProfile>.from(profiles);
      list.removeWhere((p) => p.id == id);
      return _writeProfiles(list);
    }, (failure) => Error(failure));
  }

  @override
  Future<Result<void, Failure>> updateProfileName(
    String id,
    String newName,
  ) async {
    final result = await getGliderProfiles();
    return result.fold((profiles) {
      final list = List<GliderProfile>.from(profiles);
      final index = list.indexWhere((p) => p.id == id);
      if (index != -1) {
        list[index] = GliderProfile(
          id: list[index].id,
          name: newName,
          photoPath: list[index].photoPath,
        );
        return _writeProfiles(list);
      }
      return const Error(StorageFailure('Профиль не найден'));
    }, (failure) => Error(failure));
  }
}
