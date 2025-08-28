part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const LOGIN = _Paths.LOGIN;
  static const REGISTER = _Paths.REGISTER;
  // Tambahkan route baru
  static const LEMBUR = _Paths.LEMBUR;
  static const ADD_LEMBUR = _Paths.ADD_LEMBUR;
  static const PRESENSI = _Paths.PRESENSI;
  static const ADD_PRESENSI = _Paths.ADD_PRESENSI;
  static const OLAHRAGA = _Paths.OLAHRAGA;
  static const ADD_OLAHRAGA = _Paths.ADD_OLAHRAGA;
  static const KEGIATAN = _Paths.KEGIATAN;
  static const ADD_KEGIATAN = _Paths.ADD_KEGIATAN;
  static const PRESTASI = _Paths.PRESTASI;
  static const ADD_PRESTASI = _Paths.ADD_PRESTASI;
  static const ADMIN = _Paths.ADMIN;
  static const DATA_EXTRACTION = _Paths.DATA_EXTRACTION;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  // Tambahkan path baru
  static const LEMBUR = '/lembur';
  static const ADD_LEMBUR = '/add-lembur';
  static const PRESENSI = '/presensi';
  static const ADD_PRESENSI = '/add-presensi';
  static const OLAHRAGA = '/olahraga';
  static const ADD_OLAHRAGA = '/add-olahraga';
  static const KEGIATAN = '/kegiatan';
  static const ADD_KEGIATAN = '/add-kegiatan';
  static const PRESTASI = '/prestasi';
  static const ADD_PRESTASI = '/add-prestasi';
  static const ADMIN = '/admin';
  static const DATA_EXTRACTION = '/data-extraction';
}
