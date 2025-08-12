import 'package:get/get.dart';

import '../controllers/add_presensi_controller.dart';

class AddPresensiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddPresensiController>(
      () => AddPresensiController(),
    );
  }
}
