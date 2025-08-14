import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../lembur/controllers/lembur_controller.dart';
import '../../presensi/controllers/presensi_controller.dart';
import '../../olahraga/controllers/olahraga_controller.dart';
import '../../kegiatan/controllers/kegiatan_controller.dart';
import '../../prestasi/controllers/prestasi_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    
    // Add controllers for all views used in the bottom navigation bar
    Get.lazyPut<LemburController>(() => LemburController());
    Get.lazyPut<PresensiController>(() => PresensiController());
    Get.lazyPut<KegiatanController>(() => KegiatanController());
    Get.lazyPut<OlahragaController>(() => OlahragaController());
    Get.lazyPut<PrestasiController>(() => PrestasiController());
  }
}