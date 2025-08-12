import 'package:get/get.dart';
import '../../lembur/controllers/lembur_controller.dart';
import '../../presensi/controllers/presensi_controller.dart'; // Add this import
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    // Add these controllers since they are used in the bottom navigation
    Get.lazyPut<LemburController>(
      () => LemburController(),
    );
    Get.lazyPut<PresensiController>(
      () => PresensiController(),
    );
  }
}