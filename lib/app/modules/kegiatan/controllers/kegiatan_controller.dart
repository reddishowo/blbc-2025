import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:sppdn/app/models/kegiatan_data.dart';

class KegiatanController extends GetxController {
  final RxList<KegiatanModel> kegiatanList = <KegiatanModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchKegiatan();
  }

  @override
  void onReady() {
    super.onReady();
    // Refresh data when controller becomes ready (e.g., when returning to page)
    fetchKegiatan();
  }

  Future<void> fetchKegiatan() async {
    try {
      isLoading.value = true;
      
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        kegiatanList.clear();
        return;
      }

      // Show all users' kegiatan data instead of just current user
      final querySnapshot = await FirebaseFirestore.instance
          .collection('kegiatan')
          .orderBy('createdAt', descending: true)
          .get();

      kegiatanList.value = querySnapshot.docs
          .map((doc) => KegiatanModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching kegiatan: $e');
      kegiatanList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshKegiatan() async {
    await fetchKegiatan();
  }
}
