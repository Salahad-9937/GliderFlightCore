import 'parts/core_strings.dart';
import 'parts/comm_strings.dart';
import 'parts/prog_strings.dart';
import 'parts/panel_strings.dart';

/// Главный контейнер локализации.
///
/// Группирует строки по фичам для предотвращения разрастания файла.
class AppStrings {
  final String appTitle;

  final CoreStrings core;
  final CommStrings comm;
  final ProgStrings prog;
  final PanelStrings panel;

  const AppStrings({
    required this.appTitle,
    required this.core,
    required this.comm,
    required this.prog,
    required this.panel,
  });

  /// Русская локализация.
  static const ru = AppStrings(
    appTitle: 'Glider Flight Core',
    core: CoreStrings.ru,
    comm: CommStrings.ru,
    prog: ProgStrings.ru,
    panel: PanelStrings.ru,
  );
}
