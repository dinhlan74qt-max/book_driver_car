import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/get_my_vehicles.dart';
import 'my_vehicles_event.dart';
import 'my_vehicles_state.dart';

@injectable
class MyVehiclesBloc extends Bloc<MyVehiclesEvent, MyVehiclesState> {
  final GetMyVehicles getMyVehicles;

  MyVehiclesBloc(this.getMyVehicles) : super(MyVehiclesInitial()) {
    on<MyVehiclesRequested>(_onRequested);
  }

  Future<void> _onRequested(
    MyVehiclesRequested event,
    Emitter<MyVehiclesState> emit,
  ) async {
    emit(MyVehiclesLoading());
    try {
      final vehicles = await getMyVehicles();
      emit(MyVehiclesLoaded(vehicles));
    } catch (e) {
      emit(MyVehiclesFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
