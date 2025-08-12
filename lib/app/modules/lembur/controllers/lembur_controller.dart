import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:sppdn/app/models/lembur_data.dart';
import 'package:sppdn/app/modules/auth/controllers/auth_controller.dart';

class LemburController extends GetxController {
  // A reactive list to hold the overtime data
  final RxList<LemburModel> lemburList = <LemburModel>[].obs;
  // A flag to manage the loading state
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Bind the Firestore stream to our reactive list
    lemburList.bindStream(fetchLemburStream());
  }

  /// Creates a stream that listens to the 'lembur' collection in Firestore.
  Stream<List<LemburModel>> fetchLemburStream() {
    final authController = AuthController.instance;
    final String? uid = authController.firebaseUser.value?.uid;

    // If the user is not logged in, return an empty stream
    if (uid == null) {
      isLoading.value = false;
      return Stream.value([]);
    }

    // Query Firestore for documents created by the current user, ordered by newest first.
    return FirebaseFirestore.instance
        .collection('lembur')
        .where('userId', isEqualTo: uid)
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
}