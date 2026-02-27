/// Строки фичи glider_profiles.
class ProfileStrings {
  final String myGliders;
  final String newGliderProfile;
  final String gliderName;
  final String nameNotEmpty;
  final String noGliders;
  final String addFirstProfile;
  final String renameGlider;
  final String deleteProfileConfirm;
  final String profileDeleted;

  const ProfileStrings({
    required this.myGliders,
    required this.newGliderProfile,
    required this.gliderName,
    required this.nameNotEmpty,
    required this.noGliders,
    required this.addFirstProfile,
    required this.renameGlider,
    required this.deleteProfileConfirm,
    required this.profileDeleted,
  });

  static const ru = ProfileStrings(
    myGliders: 'Мои планеры',
    newGliderProfile: 'Новый профиль планера',
    gliderName: 'Название планера',
    nameNotEmpty: 'Название не может быть пустым',
    noGliders: 'Нет добавленных планеров',
    addFirstProfile: 'Нажмите "+", чтобы создать первый профиль',
    renameGlider: 'Переименовать планер',
    deleteProfileConfirm: 'Вы уверены, что хотите удалить профиль',
    profileDeleted: 'Профиль удален',
  );
}
