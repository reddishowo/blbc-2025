import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/presensi_data.dart';

class PresensiController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<PresensiData> presensiList = <PresensiData>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPresensiData();
  }

  Future<void> fetchPresensiData() async {
    isLoading.value = true;
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        // Fetch all users' presensi data
        final querySnapshot = await _firestore
            .collection('presensi')
            .orderBy('createdAt', descending: true)
            .get();

        final presensiData = querySnapshot.docs
            .map((doc) => PresensiData.fromJson({...doc.data(), 'id': doc.id}))
            .toList();

        presensiList.assignAll(presensiData);
      } else {
        presensiList.clear();
      }
    } catch (e) {
      print('Error fetching presensi: $e');
      // If no data exists, just show empty list instead of error
      presensiList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePresensi(String id) async {
    try {
      // Delete from top-level "presensi" collection
      await _firestore.collection('presensi').doc(id).delete();
      
      // Remove from the list
      presensiList.removeWhere((presensi) => presensi.id == id);
      Get.snackbar('Success', 'Presensi berhasil dihapus');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete presensi: $e');
    }
  }
}