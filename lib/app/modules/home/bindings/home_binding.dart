import 'package:get/get.dart';
import 'package:sppdn/app/modules/lembur/controllers/lembur_controller.dart'; // Import controller
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<LemburController>(() => LemburController()); 
  }
}