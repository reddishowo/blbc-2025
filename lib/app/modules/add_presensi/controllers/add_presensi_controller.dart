import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:geolocator/geolocator.dart'; // Import for location
import 'package:geocoding/geocoding.dart'; // Import for geocoding
import '../../auth/controllers/auth_controller.dart';
import '../../presensi/controllers/presensi_controller.dart';

class AddPresensiController extends GetxController {
  // --- START: IMAGEKIT CONFIGURATION ---
  final String _imageKitPrivateKey = "private_B1P/hxK26SuOiV9GcgAOjYD60RI=";
  final String _imageKitUrlEndpoint = "https://upload.imagekit.io/api/v1/files/upload";
  // --- END: IMAGEKIT CONFIGURATION ---

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  // Text controllers
  final namaController = TextEditingController();
  final keteranganController = TextEditingController();
  final timeController = TextEditingController(); // New controller for time
  final locationController = TextEditingController(); // New controller for location display

  // Reactive variables
  final RxString selectedKehadiran = ''.obs;
  final RxString selectedStatus = 'SEHAT'.obs;
  final Rxn<XFile> pickedImage = Rxn<XFile>();
  final RxBool isLoading = false.obs;
  final Rx<DateTime> selectedTime = DateTime.now().obs; // Store the selected time
  final RxString currentLocation = ''.obs; // Store the current location

  // Options for dropdowns
  final RxList<String> kehadiranOptions = <String>[].obs;
  final List<String> statusOptions = ['SEHAT', 'SAKIT', 'TIDAK YAKIN'];

  @override
  void onInit() {
    super.onInit();
    requestLocationPermission();
    // Pre-fill user data when the controller is initialized
    _loadUserData();
    
    // Set current time
    updateCurrentTime();
    
    // Get current location
    _getCurrentLocation();
    
    // Load kehadiran options from Firestore
    _loadKehadiranOptions();
  }

  // Load user data from Firestore
  Future<void> _loadUserData() async {
    try {
      final user = AuthController.instance.firebaseUser.value;
      if (user != null) {
        // Try to get name from Firestore first, then fallback to displayName
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          namaController.text = userData['name'] ?? user.displayName ?? 'User Name Not Found';
        } else {
          namaController.text = user.displayName ?? 'User Name Not Found';
        }
      } else {
        namaController.text = 'User Name Not Found';
      }
    } catch (e) {
      // Fallback to displayName if Firestore fails
      final user = AuthController.instance.firebaseUser.value;
      namaController.text = user?.displayName ?? 'User Name Not Found';
    }
  }
  
  // Load kehadiran options from Firestore
  Future<void> _loadKehadiranOptions() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('admin_config')
          .doc('presensi_kehadiran')
          .get();
      
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data['items'] != null && data['items'] is List) {
          final items = List<String>.from(data['items']);
          if (items.isNotEmpty) {
            kehadiranOptions.value = items;
            selectedKehadiran.value = items.first;
            return;
          }
        }
      }
      
      // Fallback to default values
      kehadiranOptions.value = ['WFH', 'WFO', 'WFHB', 'CUTI', 'ST'];
      selectedKehadiran.value = 'WFH';
    } catch (e) {
      print('Error loading kehadiran options: $e');
      // Fallback to default values on error
      kehadiranOptions.value = ['WFH', 'WFO', 'WFHB', 'CUTI', 'ST'];
      selectedKehadiran.value = 'WFH';
      // Don't show error to user, just use defaults
    }
  }

  // Request location permission
  Future<void> requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      Get.snackbar('Error', 'Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied
        Get.snackbar('Error', 'Location permissions are denied');
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied
      Get.snackbar('Error', 'Location permissions are permanently denied, please enable them in app settings.');
      return;
    }

    // When we reach here, permissions are granted
    refreshLocation();
  }

  // Update current time method - will be called when form loads and when submitting
  void updateCurrentTime() {
    final now = DateTime.now();
    selectedTime.value = now;
    timeController.text = DateFormat('HH:mm, dd MMM yyyy').format(now);
  }

  // Get current location
  Future<void> _getCurrentLocation() async {
    try {
      // Set a fallback location in case we can't get the real one
      locationController.text = "Location unavailable - check app permissions";
      
      // Check location permission
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            Get.snackbar('Error', 'Location permissions are denied');
            return;
          }
        }
        
        if (permission == LocationPermission.deniedForever) {
          Get.snackbar('Error', 'Location permissions are permanently denied');
          return;
        }
        
        // Get current position
        isLoading.value = true;
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high
        );
        
        // Get address from coordinates
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, 
          position.longitude
        );
        
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          currentLocation.value = '${place.street}, ${place.subLocality}, ${place.locality}';
          locationController.text = currentLocation.value;
        }
      } catch (e) {
        // Log the error but continue
        print('Location error: $e');
        Get.snackbar('Location Issue', 
                    'Unable to access location. You can still submit attendance.');
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Allow manual refresh of location
  Future<void> refreshLocation() async {
    await _getCurrentLocation();
  }

  Future<void> submitPresensi() async {
    if (namaController.text.isEmpty) {
      Get.snackbar('Error', 'Nama tidak boleh kosong');
      return;
    }

    // Update time to current time at submission
    updateCurrentTime();
    
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
        'location': locationController.text, // Keep existing location code
        'time': selectedTime.value, // Use the current time
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
    timeController.dispose();
    locationController.dispose();
    super.onClose();
  }
}