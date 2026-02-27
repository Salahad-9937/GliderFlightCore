/// Общие системные строки (кнопки, ошибки, подтверждения).
class CoreStrings {
  final String error;
  final String cancel;
  final String save;
  final String retry;
  final String ok;
  final String delete;
  final String confirmation;

  const CoreStrings({
    required this.error,
    required this.cancel,
    required this.save,
    required this.retry,
    required this.ok,
    required this.delete,
    required this.confirmation,
  });

  static const ru = CoreStrings(
    error: 'Ошибка',
    cancel: 'Отмена',
    save: 'Сохранить',
    retry: 'Попробовать снова',
    ok: 'ОК',
    delete: 'Удалить',
    confirmation: 'Подтверждение',
  );
}
