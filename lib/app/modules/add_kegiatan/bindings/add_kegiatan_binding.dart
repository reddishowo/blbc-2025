import 'package:get/get.dart';

import '../controllers/add_kegiatan_controller.dart';

class AddKegiatanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddKegiatanController>(
      () => AddKegiatanController(),
    );
  }
}
