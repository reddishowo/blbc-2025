import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:sppdn/app/models/lembur_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class LemburController extends GetxController {
  final RxList<LemburModel> lemburList = <LemburModel>[].obs;
  final RxBool isLoading = true.obs;
  StreamSubscription? _subscription;

  @override
  void onInit() {
    super.onInit();
    fetchLembur();
  }

  @override
  void onReady() {
    super.onReady();
    // Refresh data when controller becomes ready (e.g., when returning to page)
    fetchLembur();
  }

  // Replace the stream approach with a simpler fetch method
  Future<void> fetchLembur() async {
    try {
      isLoading.value = true;
      
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        lemburList.clear();
        return;
      }

      // Show all users' lembur data instead of just current user
      final querySnapshot = await FirebaseFirestore.instance
          .collection('lembur')
          .orderBy('createdAt', descending: true)
          .get();

      lemburList.value = querySnapshot.docs
          .map((doc) => LemburModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching lembur: $e');
      // If no data exists, just show empty list instead of error
      lemburList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshLembur() async {
    await fetchLembur();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}