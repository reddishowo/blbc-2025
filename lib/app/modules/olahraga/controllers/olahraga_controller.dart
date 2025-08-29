import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:sppdn/app/models/olahraga_data.dart';

class OlahragaController extends GetxController {
  final RxList<OlahragaModel> olahragaList = <OlahragaModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOlahraga();
  }

  @override
  void onReady() {
    super.onReady();
    // Refresh data when controller becomes ready (e.g., when returning to page)
    fetchOlahraga();
  }

  Future<void> fetchOlahraga() async {
    try {
      isLoading.value = true;
      
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        olahragaList.clear();
        return;
      }

      // Show all users' olahraga data instead of just current user
      final querySnapshot = await FirebaseFirestore.instance
          .collection('olahraga')
          .orderBy('createdAt', descending: true)
          .get();

      olahragaList.value = querySnapshot.docs
          .map((doc) => OlahragaModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching olahraga: $e');
      olahragaList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshOlahraga() async {
    await fetchOlahraga();
  }
}
