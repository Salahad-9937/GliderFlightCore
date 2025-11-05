import 'package:flutter/foundation.dart';

/// Вспомогательный класс для передачи двух ID в Provider.family.
@immutable
class ProgramId {
  final String profileId;
  final String programId;

  const ProgramId({required this.profileId, required this.programId});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProgramId &&
        other.profileId == profileId &&
        other.programId == programId;
  }

  @override
  int get hashCode => profileId.hashCode ^ programId.hashCode;
}