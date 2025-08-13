import 'package:get/get.dart';

import '../modules/add_lembur/bindings/add_lembur_binding.dart';
import '../modules/add_lembur/views/add_lembur_view.dart';
import '../modules/add_olahraga/bindings/add_olahraga_binding.dart';
import '../modules/add_olahraga/views/add_olahraga_view.dart';
import '../modules/add_presensi/bindings/add_presensi_binding.dart';
import '../modules/add_presensi/views/add_presensi_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/lembur/bindings/lembur_binding.dart';
import '../modules/lembur/views/lembur_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/olahraga/bindings/olahraga_binding.dart';
import '../modules/olahraga/views/olahraga_view.dart';
import '../modules/presensi/bindings/presensi_binding.dart';
import '../modules/presensi/views/presensi_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';

// ignore_for_file: constant_identifier_names

// Import all necessary bindings and views

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      bindings: [AuthBinding(), HomeBinding()],
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    // Tambahkan GetPage baru
    GetPage(
      name: _Paths.LEMBUR,
      page: () => const LemburView(),
      binding: LemburBinding(),
    ),
    GetPage(
      name: _Paths.ADD_LEMBUR,
      page: () => const AddLemburView(),
      binding: AddLemburBinding(),
    ),
    GetPage(
      name: _Paths.PRESENSI,
      page: () => const PresensiView(),
      binding: PresensiBinding(),
    ),
    GetPage(
      name: _Paths.ADD_PRESENSI,
      page: () => const AddPresensiView(),
      binding: AddPresensiBinding(),
    ),
    GetPage(
      name: _Paths.OLAHRAGA,
      page: () => const OlahragaView(),
      binding: OlahragaBinding(),
    ),
    GetPage(
      name: _Paths.ADD_OLAHRAGA,
      page: () => const AddOlahragaView(),
      binding: AddOlahragaBinding(),
    ),
  ];
}
