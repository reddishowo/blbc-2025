import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Text editing controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // Reactive variables
  final RxBool isLoading = false.obs;
  final RxBool isEditing = false.obs;
  final RxString currentUserName = ''.obs;
  final RxString currentUserEmail = ''.obs;
  final RxString currentUserRole = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    super.onClose();
  }

  void loadUserProfile() async {
    try {
      isLoading.value = true;
      
      final user = _auth.currentUser;
      if (user != null) {
        // Get user data from Firestore
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          
          // Set current user data - prioritize 'name' field, fallback to 'nama' if exists
          currentUserName.value = userData['name'] ?? userData['nama'] ?? user.displayName ?? '';
          currentUserEmail.value = userData['email'] ?? user.email ?? '';
          currentUserRole.value = userData['role'] ?? 'user';
          
          // Set text controllers
          nameController.text = currentUserName.value;
          emailController.text = currentUserEmail.value;
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load profile: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void toggleEditMode() {
    isEditing.value = !isEditing.value;
    if (!isEditing.value) {
      // Reset name controller to original value if cancelled
      nameController.text = currentUserName.value;
    }
  }

  Future<void> updateProfile() async {
    try {
      // Validate input
      if (nameController.text.trim().isEmpty) {
        Get.snackbar(
          'Error',
          'Name cannot be empty',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      isLoading.value = true;
      
      final user = _auth.currentUser;
      if (user != null) {
        // Update Firestore document - use 'name' field and remove 'nama' if it exists
        await _firestore.collection('users').doc(user.uid).update({
          'name': nameController.text.trim(),
          'nama': FieldValue.delete(), // Remove old 'nama' field if it exists
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Update Firebase Auth display name
        await user.updateDisplayName(nameController.text.trim());

        // Update local data
        currentUserName.value = nameController.text.trim();
        
        isEditing.value = false;

        Get.snackbar(
          'Success',
          'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void cancelEdit() {
    nameController.text = currentUserName.value;
    isEditing.value = false;
  }

  String getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrator';
      case 'user':
        return 'Laboratory Staff';
      default:
        return 'User';
    }
  }
}
