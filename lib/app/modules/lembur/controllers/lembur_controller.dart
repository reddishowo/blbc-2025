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

  // Replace the stream approach with a simpler fetch method
  Future<void> fetchLembur() async {
    try {
      isLoading.value = true;
      
      final querySnapshot = await FirebaseFirestore.instance
          .collection('lembur')
          .orderBy('createdAt', descending: true)
          .get();

      lemburList.value = querySnapshot.docs
          .map((doc) => LemburModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch lembur: $e');
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