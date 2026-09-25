part of 'quran_bloc.dart';

class QuranState extends UIState<List<Surah>> {
  const QuranState({super.status, super.message, super.data});

  List<Surah> get surahs => data ?? const [];

  @override
  QuranState copyWith({UIStatus? status, String? message, List<Surah>? data}) {
    return QuranState(
      status: status ?? this.status,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }
}
