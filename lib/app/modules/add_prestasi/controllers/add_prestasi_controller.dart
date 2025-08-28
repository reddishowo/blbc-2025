import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../auth/controllers/auth_controller.dart';
import '../../prestasi/controllers/prestasi_controller.dart';

class AddPrestasiController extends GetxController {
  // --- START: IMAGEKIT CONFIGURATION ---
  final String _imageKitPrivateKey = "private_B1P/hxK26SuOiV9GcgAOjYD60RI=";
  final String _imageKitUrlEndpoint = "https://upload.imagekit.io/api/v1/files/upload";
  // --- END: IMAGEKIT CONFIGURATION ---

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController recipientNameController = TextEditingController(); // New controller for recipient name
  final TextEditingController namaPrestasiController = TextEditingController();
  final TextEditingController namaPemberiController = TextEditingController();
  final TextEditingController nomorSertifikatController = TextEditingController();
  final TextEditingController customJabatanController = TextEditingController();
  
  final RxString selectedJabatan = ''.obs;
  final RxString selectedFileName = ''.obs;
  final Rx<File?> selectedFile = Rx<File?>(null);
  final RxBool isLoading = false.obs;
  final RxBool showCustomJabatan = false.obs;

  final RxList<String> jabatanOptions = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Pre-fill user data when the controller is initialized
    final user = AuthController.instance.firebaseUser.value;
    nameController.text = user?.displayName ?? 'User Name Not Found';
    // Also prefill the recipient name with the user's name, but this can be changed
    recipientNameController.text = user?.displayName ?? 'User Name Not Found';
    
    // Load jabatan options from Firestore
    _loadJabatanOptions();
  }
  
  // Load jabatan options from Firestore
  Future<void> _loadJabatanOptions() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('admin_config')
          .doc('prestasi_jabatan')
          .get();
      
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data['items'] != null) {
          jabatanOptions.value = List<String>.from(data['items']);
          // Set default selected jabatan if list is not empty
          if (jabatanOptions.isNotEmpty) {
            selectedJabatan.value = jabatanOptions.first;
          }
        }
      } else {
        // Fallback to default values if document doesn't exist
        jabatanOptions.value = ['MENTERI', 'ES I', 'ES II', 'ES III', 'ES IV', 'Lainnya'];
        selectedJabatan.value = 'MENTERI';
      }
    } catch (e) {
      // Fallback to default values on error
      jabatanOptions.value = ['MENTERI', 'ES I', 'ES II', 'ES III', 'ES IV', 'Lainnya'];
      selectedJabatan.value = 'MENTERI';
      Get.snackbar('Error', 'Failed to load jabatan options: $e');
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    recipientNameController.dispose(); // Dispose the new controller
    namaPrestasiController.dispose();
    namaPemberiController.dispose();
    nomorSertifikatController.dispose();
    customJabatanController.dispose();
    super.onClose();
  }

  void onJabatanChanged(String? value) {
    if (value != null) {
      selectedJabatan.value = value;
      showCustomJabatan.value = (value == 'Lainnya');
    }
  }

  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        selectedFile.value = File(result.files.single.path!);
        selectedFileName.value = result.files.single.name;
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Gagal memilih file: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> submitPrestasi() async {
    if (!_validateForm()) return;

    isLoading.value = true;
    
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        Get.snackbar('Error', 'Anda belum login');
        return;
      }

      // Upload file using ImageKit
      String? fileUrl = await _uploadFile(selectedFile.value!, selectedFileName.value);
      if (fileUrl == null) {
        // If upload fails, stop the process
        isLoading.value = false;
        return;
      }

      // Determine the jabatan value to save
      String jabatanToSave = selectedJabatan.value;
      if (selectedJabatan.value == 'Lainnya' && customJabatanController.text.isNotEmpty) {
        jabatanToSave = customJabatanController.text;
      }

      // Create a new document in the prestasi collection
      await _firestore.collection('prestasi').add({
        'userId': userId,
        'nama': nameController.text, // Account holder name
        'recipientName': recipientNameController.text, // Name of the person who received the achievement
        'namaPrestasi': namaPrestasiController.text,
        'jabatanPemberi': jabatanToSave,
        'namaPemberi': namaPemberiController.text,
        'nomorSertifikat': nomorSertifikatController.text,
        'buktiUrl': fileUrl,
        'buktiFileName': selectedFileName.value,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // First navigate back
      Get.back();
      
      // Then show success notification
      Get.snackbar(
        'Berhasil',
        'Prestasi berhasil ditambahkan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      
      // Refresh the prestasi list
      if (Get.isRegistered<PrestasiController>()) {
        final PrestasiController prestasiController = Get.find<PrestasiController>();
        prestasiController.fetchPrestasi();
      }
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menambahkan prestasi: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateForm() {
    if (nameController.text.isEmpty) {
      Get.snackbar('Error', 'Nama tidak boleh kosong');
      return false;
    }
    if (recipientNameController.text.isEmpty) {
      Get.snackbar('Error', 'Nama penerima prestasi tidak boleh kosong');
      return false;
    }
    if (namaPrestasiController.text.isEmpty) {
      Get.snackbar('Error', 'Nama prestasi harus diisi');
      return false;
    }
    if (namaPemberiController.text.isEmpty) {
      Get.snackbar('Error', 'Nama pemberi penghargaan harus diisi');
      return false;
    }
    if (selectedJabatan.value == 'Lainnya' && customJabatanController.text.isEmpty) {
      Get.snackbar('Error', 'Jabatan pemberi penghargaan harus diisi');
      return false;
    }
    // Remove validation for nomorSertifikat since it's now optional
    if (selectedFile.value == null) {
      Get.snackbar('Error', 'Bukti harus dipilih');
      return false;
    }
    return true;
  }

  /// Uploads the selected file to ImageKit.io using a Multipart request.
  Future<String?> _uploadFile(File file, String fileName) async {
    // Use Basic Authentication with the private key as the username and an empty password
    String basicAuth = 'Basic ${base64Encode(utf8.encode('$_imageKitPrivateKey:'))}';

    // Create the multipart request
    var request = http.MultipartRequest('POST', Uri.parse(_imageKitUrlEndpoint));

    // Add the authentication header
    request.headers['Authorization'] = basicAuth;

    // Add the file to the request
    request.files.add(
      await http.MultipartFile.fromPath(
        'file', // Field name expected by the ImageKit API
        file.path,
        filename: fileName,
      ),
    );

    // Add other required fields
    request.fields['fileName'] = fileName;

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['url']; // Return the hosted file URL
      } else {
        // Show a detailed error message from the server
        Get.snackbar('Error Upload', 'Gagal mengunggah file: ${response.body}');
        return null;
      }
    } catch (e) {
      Get.snackbar('Error Jaringan', 'Gagal terhubung ke server upload: $e');
      return null;
    }
  }
}
