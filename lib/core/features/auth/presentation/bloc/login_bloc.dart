// lib/features/auth/presentation/bloc/login_bloc.dart
import 'package:book_drive_car/core/storage/user_local_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/login.dart';
import 'login_event.dart';
import 'login_state.dart';

@injectable
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final Login loginUseCase;
  final UserLocalStorage userLocalStorage;

  LoginBloc(this.loginUseCase, this.userLocalStorage) : super(LoginInitial()) {
    on<LoginSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    try {
      final result = await loginUseCase(event.email, event.password);

      await userLocalStorage.saveSession(
        token: result.token,
        tokenType: result.tokenType,
        user: result.user,
      );

      emit(LoginSuccess(result));
    } catch (e) {
      print(e.toString());
      emit(LoginFailure(e.toString().replaceFirst("Exception: ", "")));
    }
  }
}
