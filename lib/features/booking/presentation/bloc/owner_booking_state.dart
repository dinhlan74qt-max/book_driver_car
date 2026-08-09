import 'package:book_drive_car/features/booking/domain/entities/booking_status.dart';
import 'package:book_drive_car/features/booking/domain/entities/owner_booking_entity.dart';
import 'package:equatable/equatable.dart';

abstract class OwnerBookingState extends Equatable {
  const OwnerBookingState();

  @override
  List<Object?> get props => [];
}

class OwnerBookingInitial extends OwnerBookingState {}

class OwnerBookingLoading extends OwnerBookingState {}

class OwnerBookingLoaded extends OwnerBookingState {
  final List<OwnerBookingEntity> allBookings;
  final BookingStatus? filterStatus; // null = Tất cả

  const OwnerBookingLoaded({
    required this.allBookings,
    this.filterStatus,
  });

  List<OwnerBookingEntity> get filteredBookings {
    if (filterStatus == null) return allBookings;
    return allBookings.where((e) => e.status == filterStatus).toList();
  }

  int countByStatus(BookingStatus status) {
    return allBookings.where((e) => e.status == status).length;
  }

  OwnerBookingLoaded copyWith({
    List<OwnerBookingEntity>? allBookings,
    BookingStatus? Function()? filterStatus,
  }) {
    return OwnerBookingLoaded(
      allBookings: allBookings ?? this.allBookings,
      filterStatus: filterStatus != null ? filterStatus() : this.filterStatus,
    );
  }

  @override
  List<Object?> get props => [allBookings, filterStatus];
}

class OwnerBookingError extends OwnerBookingState {
  final String message;

  const OwnerBookingError(this.message);

  @override
  List<Object?> get props => [message];
}
