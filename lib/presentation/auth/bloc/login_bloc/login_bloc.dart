import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/error_utils.dart';
import '../../../../core/model/ui_state.dart';
import '../../../../domain/auth/repositories/auth_repository.dart';

part 'login_event.dart';
part 'login_state.dart';

/// Screen 04 — login. Pattern ported from starterflutter-develop.
@injectable
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepository;

  LoginBloc({required this.authRepository}) : super(const LoginState()) {
    on<LoginSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: UIStatus.loading, message: ''));
    try {
      await authRepository.login(event.email, event.password);
      emit(state.copyWith(status: UIStatus.success));
    } on Exception catch (e) {
      emit(state.copyWith(
        status: UIStatus.error,
        message: mapExceptionToMessage(e),
      ));
    }
  }
}
