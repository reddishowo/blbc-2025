import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:sppdn/app/models/olahraga_data.dart';

class OlahragaController extends GetxController {
  final RxList<OlahragaModel> olahragaList = <OlahragaModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    olahragaList.bindStream(fetchOlahragaStream());
  }

  Stream<List<OlahragaModel>> fetchOlahragaStream() {
    return FirebaseFirestore.instance
        .collection('olahraga')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((querySnapshot) {
          List<OlahragaModel> list = querySnapshot.docs
              .map((doc) => OlahragaModel.fromFirestore(doc))
              .toList();
          isLoading.value = false;
          return list;
        });
  }
}
