import 'package:get/get.dart';

import '../controllers/add_prestasi_controller.dart';

class AddPrestasiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddPrestasiController>(
      () => AddPrestasiController(),
    );
  }
}
