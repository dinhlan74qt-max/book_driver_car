import 'package:injectable/injectable.dart';
import '../entities/rental_list_item_entity.dart';
import '../repositories/rental_repository.dart';

@injectable
class GetRenterBookings {
  final RentalRepository repository;
  GetRenterBookings(this.repository);

  Future<List<RentalListItemEntity>> call() async {
    return await repository.getRenterBookings();
  }
}
