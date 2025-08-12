part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const LOGIN = _Paths.LOGIN;
  static const REGISTER = _Paths.REGISTER;
  // Tambahkan route baru
  static const LEMBUR = _Paths.LEMBUR;
  static const ADD_LEMBUR = _Paths.ADD_LEMBUR;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  // Tambahkan path baru
  static const LEMBUR = '/lembur';
  static const ADD_LEMBUR = '/add-lembur';
}