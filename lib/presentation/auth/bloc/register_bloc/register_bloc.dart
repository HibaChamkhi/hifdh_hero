import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/error_utils.dart';
import '../../../../core/model/ui_state.dart';
import '../../../../domain/auth/repositories/auth_repository.dart';

part 'register_event.dart';
part 'register_state.dart';

/// Screen 05 — create account.
@injectable
class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRepository authRepository;

  RegisterBloc(this.authRepository) : super(const RegisterState()) {
    on<RegisterSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(state.copyWith(status: UIStatus.loading, message: ''));
    try {
      await authRepository.register({
        'name': event.name,
        'email': event.email,
        'password': event.password,
      });
      emit(state.copyWith(status: UIStatus.success));
    } on Exception catch (e) {
      emit(state.copyWith(
        status: UIStatus.error,
        message: mapExceptionToMessage(e),
      ));
    }
  }
}
