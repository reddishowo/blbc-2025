import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:sppdn/app/models/kegiatan_data.dart';

class KegiatanController extends GetxController {
  final RxList<KegiatanModel> kegiatanList = <KegiatanModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    kegiatanList.bindStream(fetchKegiatanStream());
  }

  Stream<List<KegiatanModel>> fetchKegiatanStream() {
    return FirebaseFirestore.instance
        .collection('kegiatan')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((querySnapshot) {
          List<KegiatanModel> list = querySnapshot.docs
              .map((doc) => KegiatanModel.fromFirestore(doc))
              .toList();
          isLoading.value = false;
          return list;
        });
  }
}
