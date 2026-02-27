import '../../../../core/architecture/failure.dart';
import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../entities/glider_profile.dart';
import '../repositories/glider_profile_repository.dart';

class GetGliderProfilesUseCase
    implements UseCase<List<GliderProfile>, NoParams> {
  final IGliderProfileRepository _repository;

  GetGliderProfilesUseCase(this._repository);

  @override
  Future<Result<List<GliderProfile>, Failure>> call(NoParams params) {
    return _repository.getGliderProfiles();
  }
}
