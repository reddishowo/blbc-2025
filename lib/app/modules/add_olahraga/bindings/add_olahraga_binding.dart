import 'package:get/get.dart';

import '../controllers/add_olahraga_controller.dart';

class AddOlahragaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddOlahragaController>(
      () => AddOlahragaController(),
    );
  }
}
