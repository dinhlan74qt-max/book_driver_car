import 'package:book_drive_car/features/profile/domain/entities/owner_booking_status.dart';
import 'package:book_drive_car/features/profile/domain/repositories/owner_booking_repository.dart';
import 'package:book_drive_car/features/profile/presentation/bloc/owner_booking_state.dart';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class OwnerBookingCubit extends Cubit<OwnerBookingState> {
  final OwnerBookingRepository repository;

  OwnerBookingCubit(this.repository) : super(OwnerBookingInitial());

  Future<void> fetchBookings() async {
    emit(OwnerBookingLoading());
    try {
      final bookings = await repository.getOwnerBookings();
      emit(OwnerBookingLoaded(allBookings: bookings));
    } catch (e) {
      emit(OwnerBookingError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void filterByStatus(BookingStatus? status) {
    if (state is OwnerBookingLoaded) {
      final current = state as OwnerBookingLoaded;
      emit(current.copyWith(filterStatus: () => status));
    }
  }

  Future<bool> _updateStatus(String id, String status, {String? reason}) async {
    try {
      final updated = await repository.updateBookingStatus(
        id: id,
        status: status,
        reason: reason,
      );
      if (state is OwnerBookingLoaded) {
        final current = state as OwnerBookingLoaded;
        final updatedList = current.allBookings.map((e) => e.id == id ? updated : e).toList();
        emit(current.copyWith(allBookings: updatedList));
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> approveBooking(String id) async {
    return _updateStatus(id, 'APPROVED');
  }

  Future<bool> approveBookingWithContract({
    required String id,
    required Uint8List contractPdfBytes,
    required String contractPdfFileName,
  }) async {
    try {
      final updated = await repository.approveBookingWithContract(
        id: id,
        contractPdfBytes: contractPdfBytes,
        contractPdfFileName: contractPdfFileName,
      );
      if (state is OwnerBookingLoaded) {
        final current = state as OwnerBookingLoaded;
        final updatedList =
            current.allBookings.map((e) => e.id == id ? updated : e).toList();
        emit(current.copyWith(allBookings: updatedList));
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rejectBooking(String id, {String? reason}) async {
    return _updateStatus(id, 'REJECTED', reason: reason);
  }

  Future<bool> markCustomerReceived(String id) async {
    return _updateStatus(id, 'RENTING');
  }

  Future<bool> markCustomerReturned(String id) async {
    return _updateStatus(id, 'COMPLETED');
  }
}
