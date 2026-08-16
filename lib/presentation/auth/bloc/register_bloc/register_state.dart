part of 'register_bloc.dart';

class RegisterState extends UIState<void> {
  const RegisterState({super.status = UIStatus.initial, super.message});

  @override
  RegisterState copyWith({UIStatus? status, String? message, void data}) {
    return RegisterState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }
}
