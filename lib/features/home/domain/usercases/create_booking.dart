import 'package:injectable/injectable.dart';
import '../entities/booking_entity.dart';
import '../entities/booking_request_entity.dart';
import '../repositories/booking_repository.dart';

@injectable
class CreateBooking {
  final BookingRepository repository;
  CreateBooking(this.repository);

  Future<BookingEntity> call(BookingRequestEntity request) async {
    return await repository.createBooking(request);
  }
}