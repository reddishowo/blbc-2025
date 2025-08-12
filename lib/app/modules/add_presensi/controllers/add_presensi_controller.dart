import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../auth/controllers/auth_controller.dart';
import '../../presensi/controllers/presensi_controller.dart';

class AddPresensiController extends GetxController {
  // --- START: IMAGEKIT CONFIGURATION ---
  // Using the same credentials as the lembur controller
  final String _imageKitPrivateKey = "private_nzy2ayDdr+hBnvuWhE2+KcTSmOk=";
  final String _imageKitUrlEndpoint = "https://upload.imagekit.io/api/v1/files/upload";
  // --- END: IMAGEKIT CONFIGURATION ---

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  final namaController = TextEditingController();
  final keteranganController = TextEditingController();
  
  final RxString selectedKehadiran = 'WFH'.obs;
  final RxString selectedStatus = 'SEHAT'.obs;
  final Rxn<XFile> pickedImage = Rxn<XFile>();
  final RxBool isLoading = false.obs;

  final List<String> kehadiranOptions = ['WFH', 'WFO', 'WFHB', 'CUTI', 'ST'];
  final List<String> statusOptions = ['SEHAT', 'SAKIT', 'TIDAK YAKIN'];

  @override
  void onInit() {
    super.onInit();
    // Pre-fill user data when the controller is initialized
    final user = AuthController.instance.firebaseUser.value;
    namaController.text = user?.displayName ?? 'User Name Not Found';
  }

  Future<void> submitPresensi() async {
    if (namaController.text.isEmpty) {
      Get.snackbar('Error', 'Nama tidak boleh kosong');
      return;
    }

    isLoading.value = true;
    
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        Get.snackbar('Error', 'Anda belum login');
        return;
      }

      String? imageUrl;
      if (pickedImage.value != null) {
        imageUrl = await _uploadImage(pickedImage.value!);
        if (imageUrl == null) {
          // If upload fails, stop the process
          isLoading.value = false;
          return;
        }
      }

      // Store in the top-level "presensi" collection
      await _firestore.collection('presensi').add({
        'userId': userId,
        'nama': namaController.text,
        'kehadiran': selectedKehadiran.value,
        'status': selectedStatus.value,
        'keterangan': keteranganController.text,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // First navigate back
      Get.back();
      
      // Then show success notification
      Get.snackbar(
        'Berhasil',
        'Presensi berhasil ditambahkan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      
      // Refresh the presensi list
      if (Get.isRegistered<PresensiController>()) {
        final PresensiController presensiController = Get.find<PresensiController>();
        presensiController.fetchPresensiData();
      }
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menambahkan presensi: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Shows a dialog for the user to choose between camera and gallery.
  Future<void> pickImage() async {
    Get.defaultDialog(
      title: "Pilih Sumber Gambar",
      middleText: "Silakan pilih sumber gambar dari Kamera atau Galeri.",
      actions: [
        ElevatedButton.icon(
          onPressed: () {
            Get.back(); // Close dialog
            _pickImageFromSource(ImageSource.camera);
          },
          icon: const Icon(Icons.camera_alt),
          label: const Text("Kamera"),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Get.back(); // Close dialog
            _pickImageFromSource(ImageSource.gallery);
          },
          icon: const Icon(Icons.photo_library),
          label: const Text("Galeri"),
        ),
      ],
    );
  }

  /// Helper method to launch the image picker with the selected source.
  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        pickedImage.value = image;
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Gagal mengambil gambar: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Uploads the selected image to ImageKit.io using a Multipart request.
  Future<String?> _uploadImage(XFile image) async {
    // Use Basic Authentication with the private key as the username and an empty password
    String basicAuth = 'Basic ${base64Encode(utf8.encode('$_imageKitPrivateKey:'))}';

    // Create the multipart request
    var request = http.MultipartRequest('POST', Uri.parse(_imageKitUrlEndpoint));

    // Add the authentication header
    request.headers['Authorization'] = basicAuth;

    // Add the image file to the request
    request.files.add(
      await http.MultipartFile.fromPath(
        'file', // Field name expected by the ImageKit API
        image.path,
        filename: image.name,
      ),
    );

    // Add other required fields
    request.fields['fileName'] = image.name;

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['url']; // Return the hosted image URL
      } else {
        // Show a detailed error message from the server
        Get.snackbar('Error Upload', 'Gagal mengunggah gambar: ${response.body}');
        return null;
      }
    } catch (e) {
      Get.snackbar('Error Jaringan', 'Gagal terhubung ke server upload: $e');
      return null;
    }
  }

  @override
  void onClose() {
    namaController.dispose();
    keteranganController.dispose();
    super.onClose();
  }
}