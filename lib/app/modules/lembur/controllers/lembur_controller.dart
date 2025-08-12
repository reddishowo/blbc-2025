import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:sppdn/app/models/lembur_data.dart';

class LemburController extends GetxController {
  final RxList<LemburModel> lemburList = <LemburModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    lemburList.bindStream(fetchLemburStream());
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
}