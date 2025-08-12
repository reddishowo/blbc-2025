import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sppdn/app/modules/auth/controllers/auth_controller.dart';

class AddLemburController extends GetxController {
  // --- START: IMAGEKIT CONFIGURATION ---
  // ignore: unused_field
  final String _imageKitPublicKey = "API";
  final String _imageKitPrivateKey = "API";
  final String _imageKitUrlEndpoint = "https://upload.imagekit.io/api/v1/files/upload"; 
  // --- END: IMAGEKIT CONFIGURATION ---

  // Form and text editing controllers
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final dateController = TextEditingController();
  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();
  final otherActivityController = TextEditingController();

  // Dropdown options and state management
  final List<String> activityOptions = ['Piket CPO / Lartas', 'Kegiatan Lain'];
  final RxString selectedActivity = 'Piket CPO / Lartas'.obs;

  // UI state management
  final RxBool isLoading = false.obs;
  final Rxn<XFile> pickedImage = Rxn<XFile>();
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    // Pre-fill user data when the controller is initialized
    final user = AuthController.instance.firebaseUser.value;
    nameController.text = user?.displayName ?? 'User Name Not Found';
    dateController.text = DateFormat('d MMMM yyyy').format(DateTime.now());
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

  /// Validates the form, uploads the image, and submits the data to Firestore.
  Future<void> submit() async {
    // 1. Validate the form
    if (formKey.currentState?.validate() != true) {
      return;
    }
    // 2. Check if an image has been picked
    if (pickedImage.value == null) {
      Get.snackbar('Error', 'Foto output pekerjaan wajib diisi.');
      return;
    }

    isLoading.value = true;

    try {
      // 3. Upload the image
      final imageUrl = await _uploadImage(pickedImage.value!);
      if (imageUrl == null) {
        // If upload fails, stop the process
        isLoading.value = false;
        return;
      }

      // 4. Determine the activity name
      final String activity = selectedActivity.value == 'Kegiatan Lain'
          ? otherActivityController.text.trim()
          : selectedActivity.value;

      // 5. Save the data to Firestore
      await FirebaseFirestore.instance.collection('lembur').add({
        'userId': AuthController.instance.firebaseUser.value?.uid,
        'userName': nameController.text,
        'activityType': activity,
        'date': Timestamp.now(), // Use a server timestamp for consistency
        'startTime': startTimeController.text,
        'endTime': endTimeController.text,
        'photoUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.back(); // Navigate back to the previous screen
      Get.snackbar('Berhasil', 'Kegiatan lembur berhasil ditambahkan.');

    } catch (e) {
      Get.snackbar('Error', 'Gagal menyimpan data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    // Dispose controllers to free up memory
    nameController.dispose();
    dateController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    otherActivityController.dispose();
    super.onClose();
  }
}