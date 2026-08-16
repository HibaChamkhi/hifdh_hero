import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/error_utils.dart';
import '../../../core/model/ui_state.dart';
import '../../../core/utils/arabic_text.dart';
import '../../../domain/quran/models/surah.dart';
import '../../../domain/quran/repositories/quran_repository.dart';

part 'quran_event.dart';
part 'quran_state.dart';

/// Loads the surah list and filters it for the "اختر السورة" screen.
@injectable
class QuranBloc extends Bloc<QuranEvent, QuranState> {
  final QuranRepository repository;
  List<Surah> _all = const [];

  QuranBloc(this.repository) : super(const QuranState()) {
    on<SurahsRequested>(_onRequested);
    on<SurahSearchChanged>(_onSearch);
  }

  Future<void> _onRequested(
    SurahsRequested event,
    Emitter<QuranState> emit,
  ) async {
    emit(state.copyWith(status: UIStatus.loading));
    try {
      _all = await repository.getSurahs();
      emit(state.copyWith(status: UIStatus.success, data: _all));
    } on Exception catch (e) {
      emit(state.copyWith(
        status: UIStatus.error,
        message: mapExceptionToMessage(e),
      ));
    }
  }

  void _onSearch(SurahSearchChanged event, Emitter<QuranState> emit) {
    final q = event.query.trim();
    if (q.isEmpty) {
      emit(state.copyWith(status: UIStatus.success, data: _all));
      return;
    }
    final ql = q.toLowerCase();
    final filtered = _all
        .where((s) =>
            ArabicText.contains(s.name, q) ||
            s.englishName.toLowerCase().contains(ql) ||
            s.number.toString() == q)
        .toList();
    emit(state.copyWith(status: UIStatus.success, data: filtered));
  }
}
