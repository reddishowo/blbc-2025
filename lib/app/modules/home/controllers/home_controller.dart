import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:sppdn/app/modules/lembur/views/lembur_view.dart';
import 'package:sppdn/app/modules/presensi/views/presensi_view.dart'; // Add this import
import '../../auth/controllers/auth_controller.dart';

class HomeController extends GetxController {
  // 1. Create a GlobalKey for the Scaffold
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // Manages the currently selected tab in the BottomNavigationBar
  final RxInt selectedIndex = 0.obs;

  // A list of widget options to be displayed in the body based on the selected tab
  static final List<Widget> widgetOptions = <Widget>[
    const LemburView(),
    const PresensiView(), // Replace the placeholder with the actual PresensiView
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
}