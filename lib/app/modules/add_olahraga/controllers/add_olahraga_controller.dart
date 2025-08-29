import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../olahraga/controllers/olahraga_controller.dart';

class AddOlahragaController extends GetxController {
  // --- START: IMAGEKIT CONFIGURATION ---
  final String _imageKitPrivateKey = "private_B1P/hxK26SuOiV9GcgAOjYD60RI=";
  final String _imageKitUrlEndpoint = "https://upload.imagekit.io/api/v1/files/upload";
  // --- END: IMAGEKIT CONFIGURATION ---

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  // Text controllers
  final nameController = TextEditingController();
  final activityTypeController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateController = TextEditingController();
  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();

  // Reactive variables
  final Rxn<XFile> pickedImage = Rxn<XFile>();
  final RxBool isLoading = false.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<TimeOfDay> selectedStartTime = TimeOfDay.now().obs;
  final Rx<TimeOfDay> selectedEndTime = TimeOfDay.now().obs;

  @override
  void onInit() {
    super.onInit();
    // Pre-fill user data when the controller is initialized
    final user = AuthController.instance.firebaseUser.value;
    nameController.text = user?.displayName ?? 'User Name Not Found';
    
    // Set default date
    _updateDateDisplay();
    
    // Set default times
    _updateStartTimeDisplay();
    _updateEndTimeDisplay();
  }

  // Update the date display
  void _updateDateDisplay() {
    dateController.text = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(selectedDate.value);
  }

  // Update the start time display
  void _updateStartTimeDisplay() {
    startTimeController.text = _formatTimeOfDay(selectedStartTime.value);
  }

  // Update the end time display
  void _updateEndTimeDisplay() {
    endTimeController.text = _formatTimeOfDay(selectedEndTime.value);
  }

  // Format TimeOfDay to string
  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hour.toString().padLeft(2, '0');
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Pick date
  Future<void> pickDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2023),
      lastDate: DateTime(2050),
    );
    
    if (pickedDate != null && pickedDate != selectedDate.value) {
      selectedDate.value = pickedDate;
      _updateDateDisplay();
    }
  }

  // Pick start time
  Future<void> pickStartTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedStartTime.value,
    );
    
    if (pickedTime != null) {
      selectedStartTime.value = pickedTime;
      _updateStartTimeDisplay();
    }
  }

  // Pick end time
  Future<void> pickEndTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedEndTime.value,
    );
    
    if (pickedTime != null) {
      selectedEndTime.value = pickedTime;
      _updateEndTimeDisplay();
    }
  }

  // Submit olahraga data
  Future<void> submitOlahraga() async {
    if (nameController.text.isEmpty) {
      Get.snackbar('Error', 'Nama tidak boleh kosong');
      return;
    }

    if (activityTypeController.text.isEmpty) {
      Get.snackbar('Error', 'Jenis aktivitas tidak boleh kosong');
      return;
    }

    if (pickedImage.value == null) {
      Get.snackbar('Error', 'Harap sertakan foto kegiatan');
      return;
    }
    
    isLoading.value = true;
    
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        Get.snackbar('Error', 'Anda belum login');
        return;
      }

      // Upload image
      String? imageUrl = await _uploadImage(pickedImage.value!);
      if (imageUrl == null) {
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

      // Create a new document in the olahraga collection
      await _firestore.collection('olahraga').add({
        'userId': userId,
        'userName': nameController.text,
        'activityType': activityTypeController.text,
        'description': descriptionController.text,
        'photoUrl': imageUrl,
        'startTime': startTimeController.text,
        'endTime': endTimeController.text,
        'date': dateTimestamp,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // First navigate back
      Get.back();
      
      // Then show success notification
      Get.snackbar(
        'Berhasil',
        'Kegiatan olahraga berhasil ditambahkan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      
      // Refresh the olahraga list
      if (Get.isRegistered<OlahragaController>()) {
        // ignore: unused_local_variable
        final OlahragaController olahragaController = Get.find<OlahragaController>();
        // The list will automatically update through the stream
      }
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menambahkan kegiatan olahraga: $e',
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
    nameController.dispose();
    activityTypeController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    super.onClose();
  }
}
