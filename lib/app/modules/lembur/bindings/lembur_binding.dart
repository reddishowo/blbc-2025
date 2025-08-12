import 'package:get/get.dart';
import '../controllers/lembur_controller.dart';

class LemburBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LemburController>(() => LemburController());
  }
}