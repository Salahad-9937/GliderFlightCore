/*
 * Публичный API для фичи [glider_profiles].
 *
 * Экспортирует только те провайдеры и компоненты, которые
 * предназначены для использования другими фичами.
 */

// Экспортируем провайдер для получения профиля по ID.
export 'presentation/providers/glider_profiles_providers.dart' show profileByIdProvider;