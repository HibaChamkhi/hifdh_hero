import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/error_utils.dart';
import '../../../../core/model/ui_state.dart';
import '../../../../domain/auth/repositories/auth_repository.dart';

part 'forgot_password_event.dart';
part 'forgot_password_state.dart';

/// Screen 06 — request a password-reset link.
@injectable
class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final AuthRepository authRepository;

  ForgotPasswordBloc(this.authRepository) : super(const ForgotPasswordState()) {
    on<ForgotPasswordSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(state.copyWith(status: UIStatus.loading, message: ''));
    try {
      await authRepository.forgotPassword(event.email);
      emit(state.copyWith(status: UIStatus.success));
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: UIStatus.error,
          message: mapExceptionToMessage(e),
        ),
      );
    }
  }
}
