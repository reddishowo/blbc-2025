// File: /sppdn/lib/app/modules/register/controllers/register_controller.dart

// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';

class RegisterController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  
  RxBool isPasswordHidden = true.obs;
  RxBool isConfirmPasswordHidden = true.obs;
  
  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
  
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }
  
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }
  
  void register() {
    // ** TAMBAHKAN LOG DI SINI **
    print("--- Register button pressed ---");
    final isFormValid = formKey.currentState?.validate() ?? false;
    print("--- Form validation result: $isFormValid ---");
    
    if (isFormValid) {
      print("--- Form is valid. Calling AuthController.instance.register() ---");
      AuthController.instance.register(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text.trim(),
      );
    } else {
      print("--- Form is NOT valid. Registration aborted. ---");
      // Menampilkan pesan error jika form tidak valid
      Get.snackbar(
        "Validation Error",
        "Please fill all fields correctly.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  void registerWithGoogle() {
    print("--- Google sign-in button pressed in Register page ---");
    try {
      AuthController.instance.signInWithGoogle().then((_) {
        print("--- Google sign-in completed successfully ---");
      }).catchError((error) {
        print("--- Google sign-in error: $error ---");
        Get.snackbar(
          "Google Sign-In Error",
          error.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      });
    } catch (e) {
      print("--- Exception during Google sign-in: $e ---");
      Get.snackbar(
        "Error",
        "Failed to sign in with Google: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  void goToLogin() {
    Get.back();
  }
}