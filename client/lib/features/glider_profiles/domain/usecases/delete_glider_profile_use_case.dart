import '../../../../core/architecture/failure.dart';
import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../repositories/glider_profile_repository.dart';

class DeleteGliderProfileUseCase implements UseCase<void, String> {
  final IGliderProfileRepository _repository;

  DeleteGliderProfileUseCase(this._repository);

  @override
  Future<Result<void, Failure>> call(String id) {
    return _repository.deleteGliderProfile(id);
  }
}
