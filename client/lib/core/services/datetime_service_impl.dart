import 'i_datetime_service.dart';

/// Стандартная реализация службы времени.
class DateTimeServiceImpl implements IDateTimeService {
  @override
  DateTime now() => DateTime.now();
}
