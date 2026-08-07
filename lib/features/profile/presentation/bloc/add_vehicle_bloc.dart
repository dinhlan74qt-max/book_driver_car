import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/add_vehicle.dart';
import 'add_vehicle_event.dart';
import 'add_vehicle_state.dart';

@injectable
class AddVehicleBloc extends Bloc<AddVehicleEvent, AddVehicleState> {
  final AddVehicle addVehicleUseCase;

  AddVehicleBloc(this.addVehicleUseCase) : super(AddVehicleInitial()) {
    on<AddVehicleSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    AddVehicleSubmitted event,
    Emitter<AddVehicleState> emit,
  ) async {
    emit(AddVehicleLoading());
    try {
      final vehicle = await addVehicleUseCase(event.request);
      emit(AddVehicleSuccess(vehicle));
    } catch (e) {
      final errorMessage = e.toString().replaceFirst("Exception: ", "");
      debugPrint('AddVehicleBloc error: $errorMessage');
      emit(AddVehicleFailure(errorMessage));
    }
  }
}
