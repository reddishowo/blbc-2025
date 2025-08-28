import 'package:get/get.dart';
import '../controllers/data_extraction_controller.dart';

class DataExtractionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DataExtractionController>(
      () => DataExtractionController(),
    );
  }
}
