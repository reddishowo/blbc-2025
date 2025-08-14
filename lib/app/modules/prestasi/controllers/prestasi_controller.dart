import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../models/prestasi_data.dart';

class PrestasiController extends GetxController {
  final RxList<PrestasiData> prestasiList = <PrestasiData>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPrestasi();
  }

  Future<void> fetchPrestasi() async {
    try {
      isLoading.value = true;
      final user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        Get.snackbar('Error', 'User not logged in');
        return;
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('prestasi')
          .where('userId', isEqualTo: user.uid)
          // Remove the orderBy to avoid index requirement
          // .orderBy('createdAt', descending: true)
          .get();

      // Sort the results in memory instead
      final docs = querySnapshot.docs.toList();
      docs.sort((a, b) {
        final aTime = a.data()['createdAt']?.toDate() ?? DateTime.now();
        final bTime = b.data()['createdAt']?.toDate() ?? DateTime.now();
        return bTime.compareTo(aTime); // Descending order
      });

      prestasiList.value = docs
          .map((doc) => PrestasiData.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch prestasi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshPrestasi() async {
    await fetchPrestasi();
  }
}
