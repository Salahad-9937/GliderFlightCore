/// Набор универсальных правил валидации для форм.
class Validators {
  /// Проверка на пустое значение или пробелы.
  static String? notEmpty(String? value, String errorText) {
    if (value == null || value.trim().isEmpty) {
      return errorText;
    }
    return null;
  }
}
