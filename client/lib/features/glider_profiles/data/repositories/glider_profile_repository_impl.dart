import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/glider_profile.dart';
import '../../domain/repositories/glider_profile_repository.dart';

/// Провайдер для репозитория профилей планеров.
final gliderProfileRepositoryProvider = Provider<GliderProfileRepository>((ref) {
  // Теперь мы используем реализацию с файловым хранилищем
  return LocalFileGliderProfileRepository();
});

/// Реализация репозитория, работающая с локальным JSON-файлом.
class LocalFileGliderProfileRepository implements GliderProfileRepository {
  static const _fileName = 'glider_profiles.json';

  /// Получает путь к файлу в директории документов приложения.
  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  @override
  Future<List<GliderProfile>> getGliderProfiles() async {
    try {
      final file = await _getLocalFile();
      if (!await file.exists()) {
        return []; // Если файла нет, возвращаем пустой список
      }
      final contents = await file.readAsString();
      final List<dynamic> jsonData = json.decode(contents);
      return jsonData.map((item) => GliderProfile.fromMap(item)).toList();
    } catch (e) {
      // В случае ошибки чтения/парсинга возвращаем пустой список
      return [];
    }
  }
  
  /// Приватный метод для записи списка профилей в файл.
  Future<void> _writeProfiles(List<GliderProfile> profiles) async {
    final file = await _getLocalFile();
    final List<Map<String, dynamic>> jsonData =
        profiles.map((p) => p.toMap()).toList();
    await file.writeAsString(json.encode(jsonData));
  }

  @override
  Future<void> saveGliderProfile(GliderProfile profile) async {
    final profiles = await getGliderProfiles();
    final index = profiles.indexWhere((p) => p.id == profile.id);
    if (index != -1) {
      // Обновляем существующий
      profiles[index] = profile;
    } else {
      // Добавляем новый
      profiles.add(profile);
    }
    await _writeProfiles(profiles);
  }

  @override
  Future<void> deleteGliderProfile(String id) async {
    final profiles = await getGliderProfiles();
    profiles.removeWhere((p) => p.id == id);
    await _writeProfiles(profiles);
  }
}