import 'package:flutter_test/flutter_test.dart';
import 'package:hifdh_hero/core/model/ui_state.dart';
import 'package:hifdh_hero/domain/auth/repositories/auth_repository.dart';
import 'package:hifdh_hero/presentation/auth/bloc/login_bloc/login_bloc.dart';

class _FakeAuthRepository implements AuthRepository {
  final bool fail;
  bool _loggedIn = false;
  _FakeAuthRepository({this.fail = false});

  @override
  Future<void> login(String email, String password) async {
    if (fail) throw Exception('bad credentials');
    _loggedIn = true;
  }

  @override
  Future<void> register(Map<String, dynamic> userInfo) async {}
  @override
  Future<void> forgotPassword(String email) async {}
  @override
  Future<void> logout() async => _loggedIn = false;
  @override
  bool get isLoggedIn => _loggedIn;
}

void main() {
  test('LoginBloc: loading → success on valid login', () async {
    final bloc = LoginBloc(authRepository: _FakeAuthRepository());
    final statuses = <UIStatus>[];
    final sub = bloc.stream.listen((s) => statuses.add(s.status));

    bloc.add(const LoginSubmitted(email: 'a@b.com', password: 'password1'));
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(statuses, [UIStatus.loading, UIStatus.success]);
    await sub.cancel();
    await bloc.close();
  });

  test('LoginBloc: loading → error when repository throws', () async {
    final bloc = LoginBloc(authRepository: _FakeAuthRepository(fail: true));
    final statuses = <UIStatus>[];
    final sub = bloc.stream.listen((s) => statuses.add(s.status));

    bloc.add(const LoginSubmitted(email: 'a@b.com', password: 'x'));
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(statuses, [UIStatus.loading, UIStatus.error]);
    await sub.cancel();
    await bloc.close();
  });
}
