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
    // Check if user is logged in before starting the stream
    if (FirebaseAuth.instance.currentUser != null) {
      _startStream();
    }

    // Listen to auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        // User is logged in, start the stream
        _startStream();
      } else {
        // User logged out, cancel the stream
        _cancelStream();
        // Clear the list
        lemburList.clear();
      }
    });
  }

  void _startStream() {
    // Cancel any existing subscription first
    _cancelStream();
    // Start a new subscription
    _subscription = fetchLemburStream().listen((data) {
      lemburList.assignAll(data);
      isLoading.value = false;
    }, onError: (error) {
      print('Firestore stream error: $error');
      isLoading.value = false;
    });
  }

  void _cancelStream() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// **[MODIFIED]**
  /// Creates a stream that listens to the entire 'lembur' collection in Firestore,
  /// ordered by the newest entries first.
  Stream<List<LemburModel>> fetchLemburStream() {
    // The query now simply gets all documents from the collection without any filters.
    return FirebaseFirestore.instance
        .collection('lembur')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((querySnapshot) {
          // Map the documents to our LemburModel
          List<LemburModel> list = querySnapshot.docs
              .map((doc) => LemburModel.fromFirestore(doc))
              .toList();
          // Update the loading state once data is loaded
          isLoading.value = false;
          return list;
        });
  }

  @override
  void onClose() {
    _cancelStream();
    super.onClose();
  }
}