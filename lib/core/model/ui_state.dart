import 'package:equatable/equatable.dart';

/// Base UI state used by every BLoC in the app.
///
/// Ported verbatim from `starterflutter-develop` (the original lived in a
/// `core/model ` folder whose trailing space produced ugly `%20` imports —
/// fixed here to `core/model`).
class UIState<T> extends Equatable {
  final UIStatus status;
  final String message;
  final T? data;

  const UIState({
    this.status = UIStatus.loading,
    this.message = "",
    this.data,
  });

  UIState<T> copyWith({
    UIStatus? status,
    String? message,
    T? data,
  }) {
    return UIState<T>(
      status: status ?? this.status,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [status, message, data];
}

enum UIStatus { initial, loading, success, error }
