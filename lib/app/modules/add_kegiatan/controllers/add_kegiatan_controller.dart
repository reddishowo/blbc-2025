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

  // Dropdown list for activities
  final List<String> activityOptions = [
    'Survei Evaluasi Budaya Organisasi',
    '[ Reskilling ] E-Learning Peningkatan Kompetensi Pemecahan Masalah dan Pengambilan Keputusan',
    '[ Reskilling II ] E-Learning Penguatan Kemampuan Analisis Pegawai dalam Menghadapi Ekosistem Kerja Baru',
    'Pelaksanaan Survei Penguatan Budaya Kementerian Keuangan',
    'Seminar PUG Kemenkeu 2023',
    'E-Learning Mandatori Penegakan Disiplin',
    'Kuesioner Piloting Presensi Melalui Aplikasi Satu Kemenkeu',
    'Pengisian Survei Forum PINTAR'
  ];
  
  // Selected activity
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
    
    // Set default selected activity (first option)
    if (activityOptions.isNotEmpty) {
      selectedActivity.value = activityOptions[0];
    }
  }

  // Update the date display
  void _updateDateDisplay() {
    dateController.text = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(selectedDate.value);
  }

  // Update selected activity
  void setSelectedActivity(String activity) {
    selectedActivity.value = activity;
  }

  // Pick date
  Future<void> pickDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2023),
      lastDate: DateTime(2025),
    );
    
    if (pickedDate != null && pickedDate != selectedDate.value) {
      selectedDate.value = pickedDate;
      _updateDateDisplay();
    }
  }

  // Pick document file
  Future<void> pickDocument() async {
    try {
      // For demo purposes, show a dialog instead of using file_picker
      Get.dialog(
        AlertDialog(
          title: const Text("Pilih Jenis Dokumen"),
          content: const Text("Silakan pilih jenis dokumen yang ingin Anda unggah."),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                // Simulate document selection (for testing)
                pickedFileName.value = "bukti_kegiatan.pdf";
                // Just for demo purposes
                Get.snackbar(
                  "Info", 
                  "Dokumen PDF telah dipilih (simulasi)",
                  duration: const Duration(seconds: 2),
                );
              },
              child: const Text("PDF"),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                // Simulate document selection (for testing)
                pickedFileName.value = "bukti_kegiatan.docx";
                // Just for demo purposes
                Get.snackbar(
                  "Info", 
                  "Dokumen Word telah dipilih (simulasi)",
                  duration: const Duration(seconds: 2),
                );
              },
              child: const Text("Word"),
            ),
          ],
        ),
      );
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
      Get.snackbar('Error', 'Pilih jenis kegiatan terlebih dahulu');
      return;
    }

    if (pickedFileName.value.isEmpty) {
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

      // For demo purposes, use a placeholder URL
      String documentUrl = "https://example.com/documents/" + pickedFileName.value;

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

  @override
  void onClose() {
    nameController.dispose();
    dateController.dispose();
    super.onClose();
  }
}
