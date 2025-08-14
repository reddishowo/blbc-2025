import 'package:get/get.dart';
import '../controllers/kegiatan_controller.dart';

class KegiatanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KegiatanController>(() => KegiatanController());
  }
}
