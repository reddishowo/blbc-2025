import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../kegiatan/controllers/kegiatan_controller.dart';

class AddKegiatanController extends GetxController {
  // --- START: IMAGEKIT CONFIGURATION ---
  final String _imageKitPrivateKey = "private_B1P/hxK26SuOiV9GcgAOjYD60RI=";
  final String _imageKitUrlEndpoint = "https://upload.imagekit.io/api/v1/files/upload";
  // --- END: IMAGEKIT CONFIGURATION ---

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Text controllers
  final nameController = TextEditingController();
  final dateController = TextEditingController();

  // Activity list and selection
  final RxList<String> activityList = <String>[].obs;
  final RxString selectedActivity = ''.obs;

  // Reactive variables
  final Rxn<File> pickedFile = Rxn<File>();
  final RxString pickedFileName = ''.obs;
  final RxBool isLoading = false.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    // Pre-fill user data when the controller is initialized
    final user = AuthController.instance.firebaseUser.value;
    nameController.text = user?.displayName ?? 'User Name Not Found';
    
    // Set default date
    _updateDateDisplay();
    
    // Load activity options from Firestore
    _loadActivityOptions();
  }
  
  // Load activity options from Firestore
  Future<void> _loadActivityOptions() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('admin_config')
          .doc('kegiatan_activities')
          .get();
      
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data['items'] != null) {
          activityList.value = List<String>.from(data['items']);
          // Set default selected activity if list is not empty
          if (activityList.isNotEmpty) {
            selectedActivity.value = activityList.first;
          }
        }
      } else {
        // Fallback to default values if document doesn't exist
        activityList.value = [
          'Survei Evaluasi Budaya Organisasi',
          '[ Reskilling ] E-Learning Peningkatan Kompetensi Pemecahan Masalah dan Pengambilan Keputusan',
          '[ Reskilling II ] E-Learning Penguatan Kemampuan Analisis Pegawai dalam Menghadapi Ekosistem Kerja Baru',
          'Pelaksanaan Survei Penguatan Budaya Kementerian Keuangan',
          'Seminar PUG Kemenkeu 2023',
          'E-Learning Mandatori Penegakan Disiplin',
          'Kuesioner Piloting Presensi Melalui Aplikasi Satu Kemenkeu',
          'Pengisian Survei Forum PINTAR',
        ];
        if (activityList.isNotEmpty) {
          selectedActivity.value = activityList.first;
        }
      }
    } catch (e) {
      // Fallback to default values on error
      activityList.value = [
        'Survei Evaluasi Budaya Organisasi',
        '[ Reskilling ] E-Learning Peningkatan Kompetensi Pemecahan Masalah dan Pengambilan Keputusan',
        '[ Reskilling II ] E-Learning Penguatan Kemampuan Analisis Pegawai dalam Menghadapi Ekosistem Kerja Baru',
        'Pelaksanaan Survei Penguatan Budaya Kementerian Keuangan',
        'Seminar PUG Kemenkeu 2023',
        'E-Learning Mandatori Penegakan Disiplin',
        'Kuesioner Piloting Presensi Melalui Aplikasi Satu Kemenkeu',
        'Pengisian Survei Forum PINTAR',
      ];
      if (activityList.isNotEmpty) {
        selectedActivity.value = activityList.first;
      }
      Get.snackbar('Error', 'Failed to load activities: $e');
    }
  }

  // Update the date display
  void _updateDateDisplay() {
    dateController.text = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(selectedDate.value);
  }

  // Set selected activity
  void setSelectedActivity(String activity) {
    selectedActivity.value = activity;
  }

  // Pick date
  Future<void> pickDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030), // Changed from 2025 to 2030
    );
    
    if (pickedDate != null && pickedDate != selectedDate.value) {
      selectedDate.value = pickedDate;
      _updateDateDisplay();
    }
  }

  // Pick document file
  Future<void> pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null) {
        pickedFile.value = File(result.files.single.path!);
        pickedFileName.value = result.files.single.name;
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Gagal memilih dokumen: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Submit kegiatan data
  Future<void> submitKegiatan() async {
    if (nameController.text.isEmpty) {
      Get.snackbar('Error', 'Nama tidak boleh kosong');
      return;
    }

    if (selectedActivity.value.isEmpty) {
      Get.snackbar('Error', 'Harap pilih kegiatan');
      return;
    }

    if (pickedFile.value == null) {
      Get.snackbar('Error', 'Harap sertakan bukti kegiatan (dokumen)');
      return;
    }
    
    isLoading.value = true;
    
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        Get.snackbar('Error', 'Anda belum login');
        return;
      }

      // Upload document
      String? documentUrl = await _uploadDocument(pickedFile.value!, pickedFileName.value);
      if (documentUrl == null) {
        // If upload fails, stop the process
        isLoading.value = false;
        return;
      }

      // Create timestamp for selected date at midnight
      final dateTimestamp = Timestamp.fromDate(
        DateTime(
          selectedDate.value.year,
          selectedDate.value.month,
          selectedDate.value.day,
        ),
      );

      // Create a new document in the kegiatan collection
      await _firestore.collection('kegiatan').add({
        'userId': userId,
        'userName': nameController.text,
        'activityName': selectedActivity.value,
        'date': dateTimestamp,
        'documentUrl': documentUrl,
        'documentName': pickedFileName.value,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // First navigate back
      Get.back();
      
      // Then show success notification
      Get.snackbar(
        'Berhasil',
        'Bukti kegiatan berhasil ditambahkan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      
      // Refresh the kegiatan list
      if (Get.isRegistered<KegiatanController>()) {
        // ignore: unused_local_variable
        final KegiatanController kegiatanController = Get.find<KegiatanController>();
        // The list will automatically update through the stream
      }
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menambahkan bukti kegiatan: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Uploads the selected document to ImageKit.io using a Multipart request.
  Future<String?> _uploadDocument(File file, String fileName) async {
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
        return data['url']; // Return the hosted document URL
      } else {
        // Show a detailed error message from the server
        Get.snackbar('Error Upload', 'Gagal mengunggah dokumen: ${response.body}');
        return null;
      }
    } catch (e) {
      Get.snackbar('Error Jaringan', 'Gagal terhubung ke server upload: $e');
      return null;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    dateController.dispose();
    super.onClose();
  }
}
