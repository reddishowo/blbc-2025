import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart'; // Import AuthController to access user data
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Assign the key from the controller to the Scaffold
      key: controller.scaffoldKey,

      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      // The drawer is the slide-out menu
      drawer: _buildDrawer(context),
      body: Obx(
        () => Center(
          child: HomeController.widgetOptions.elementAt(controller.selectedIndex.value),
        ),
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.work_history_outlined), label: 'Lembur'),
            BottomNavigationBarItem(icon: Icon(Icons.fact_check_outlined), label: 'Presensi'),
            BottomNavigationBarItem(icon: Icon(Icons.camera_alt_outlined), label: 'Bukti Kegiatan'),
            BottomNavigationBarItem(icon: Icon(Icons.directions_run), label: 'Ayo Olahraga'),
            BottomNavigationBarItem(icon: Icon(Icons.emoji_events_outlined), label: 'Lapor Prestasi'),
          ],
          currentIndex: controller.selectedIndex.value,
          onTap: controller.onItemTapped,
          // These properties are important for a navbar with more than 3 items
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
        ),
      ),
    );
  }

  // Widget for building the navigation drawer
  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Use Obx to make the header reactive to user data changes
          Obx(() {
            final user = AuthController.instance.firebaseUser.value;
            return UserAccountsDrawerHeader(
              accountName: Text(
                user?.displayName ?? 'User Name',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(user?.email ?? 'user@email.com'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  user?.displayName?.isNotEmpty == true ? user!.displayName![0].toUpperCase() : 'U',
                  style: TextStyle(fontSize: 40.0, color: Theme.of(context).primaryColor),
                ),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
            );
          }),
          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(icon: Icons.info_outline_rounded, text: 'About', onTap: () {}),
              ],
            ),
          ),
          // Footer items for Logout and Delete Account
          const Divider(),
          _buildDrawerItem(
            icon: Icons.logout,
            text: 'Log Out',
            onTap: controller.logout,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Helper widget to create ListTile for the drawer menu
  ListTile _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text, style: TextStyle(color: color)),
      onTap: onTap,
    );
  }
}