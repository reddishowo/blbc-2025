import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:sppdn/app/modules/lembur/views/lembur_view.dart';
import '../../auth/controllers/auth_controller.dart';

class HomeController extends GetxController {
  // 1. Create a GlobalKey for the Scaffold
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // Manages the currently selected tab in the BottomNavigationBar
  final RxInt selectedIndex = 0.obs;

  // A list of widget options to be displayed in the body based on the selected tab
  static final List<Widget> widgetOptions = <Widget>[
    const LemburView(),
    const Center(child: Text('Presensi Page')),
    const Center(child: Text('Bukti Kegiatan Page')),
    const Center(child: Text('Ayo Olahraga Page')),
    const Center(child: Text('Lapor Prestasi Page')),
  ];

  // Function to change the page when a tab is tapped
  void onItemTapped(int index) {
    selectedIndex.value = index;
  }

  // Function to handle user logout
  void logout() {
    // 2. Use the scaffoldKey to check if the drawer is open
    if (scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Get.back(); // Close the drawer
    }
    Get.dialog(
      AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Get.back(),
          ),
          TextButton(
            child: const Text('Log Out'),
            onPressed: () {
              AuthController.instance.signOut();
            },
          ),
        ],
      ),
    );
  }

  // Placeholder for the "Delete Account" functionality
  void deleteAccount() {
    // 3. Use the scaffoldKey here as well
    if (scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Get.back(); // Close the drawer
    }
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
        content: const Text(
            'This action is irreversible and will permanently delete your account and all associated data. Are you sure you want to continue?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Get.back(),
          ),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              // Here you would call the method in AuthController
              // For example: AuthController.instance.deleteUserAccount();
              Get.back(); // Close dialog
              Get.snackbar('Success', 'Delete account request sent.',
                  snackPosition: SnackPosition.BOTTOM);
            },
          ),
        ],
      ),
    );
  }
}