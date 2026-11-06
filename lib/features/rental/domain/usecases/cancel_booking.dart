import 'package:injectable/injectable.dart';
import '../repositories/rental_repository.dart';

@injectable
class CancelBooking {
  final RentalRepository repository;

  CancelBooking(this.repository);

  Future<void> call(int bookingId, {String? reason}) {
    return repository.cancelBooking(bookingId, reason: reason);
  }
}

