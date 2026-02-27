import '../../../../core/architecture/failure.dart';
import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../entities/glider_profile.dart';
import '../repositories/glider_profile_repository.dart';

class SaveGliderProfileUseCase implements UseCase<void, GliderProfile> {
  final IGliderProfileRepository _repository;

  SaveGliderProfileUseCase(this._repository);

  @override
  Future<Result<void, Failure>> call(GliderProfile profile) {
    return _repository.saveGliderProfile(profile);
  }
}
