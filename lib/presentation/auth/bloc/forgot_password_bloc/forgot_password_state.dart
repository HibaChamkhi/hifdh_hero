part of 'forgot_password_bloc.dart';

class ForgotPasswordState extends UIState<void> {
  const ForgotPasswordState({super.status = UIStatus.initial, super.message});

  @override
  ForgotPasswordState copyWith({UIStatus? status, String? message, void data}) {
    return ForgotPasswordState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }
}
