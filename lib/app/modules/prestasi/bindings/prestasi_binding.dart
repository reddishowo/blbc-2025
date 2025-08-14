import 'package:get/get.dart';

import '../controllers/prestasi_controller.dart';

class PrestasiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PrestasiController>(
      () => PrestasiController(),
    );
  }
}
