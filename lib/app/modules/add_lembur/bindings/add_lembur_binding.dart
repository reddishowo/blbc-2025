import 'package:get/get.dart';
import '../controllers/add_lembur_controller.dart';

class AddLemburBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddLemburController>(() => AddLemburController());
  }
}