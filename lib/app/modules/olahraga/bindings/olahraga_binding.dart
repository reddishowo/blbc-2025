import 'package:get/get.dart';
import '../controllers/olahraga_controller.dart';

class OlahragaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OlahragaController>(() => OlahragaController());
  }
}
