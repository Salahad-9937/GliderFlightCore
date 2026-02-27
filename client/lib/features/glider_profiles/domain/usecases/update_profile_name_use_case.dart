import '../../../../core/architecture/failure.dart';
import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../repositories/glider_profile_repository.dart';

class UpdateProfileNameParams {
  final String id;
  final String newName;

  const UpdateProfileNameParams({required this.id, required this.newName});
}

class UpdateProfileNameUseCase
    implements UseCase<void, UpdateProfileNameParams> {
  final IGliderProfileRepository _repository;

  UpdateProfileNameUseCase(this._repository);

  @override
  Future<Result<void, Failure>> call(UpdateProfileNameParams params) {
    return _repository.updateProfileName(params.id, params.newName);
  }
}
