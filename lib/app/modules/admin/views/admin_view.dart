import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';
import '../../auth/controllers/auth_controller.dart';

class AdminView extends GetView<AdminController> {
  const AdminView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if user is admin
    if (!AuthController.instance.isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel'),
          centerTitle: true,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: Colors.red,
              ),
              SizedBox(height: 16),
              Text(
                'Access Denied',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'You need admin privileges to access this page.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            Container(
              color: Colors.indigo,
              child: Column(
                children: [
                  const TabBar(
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    tabs: [
                      Tab(text: 'Lembur'),
                      Tab(text: 'Presensi'),
                      Tab(text: 'Kegiatan'),
                      Tab(text: 'Prestasi'),
                    ],
                  ),
                  // Add initialization button
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            Get.dialog(
                              const Center(child: CircularProgressIndicator()),
                              barrierDismissible: false,
                            );
                            await controller.initializeDefaultData();
                            await controller.loadAllData();
                            Get.back(); // Close loading dialog
                            Get.snackbar(
                              'Success', 
                              'Admin configuration initialized successfully!',
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.indigo,
                          ),
                          child: const Text('Initialize/Refresh Data'),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => Get.toNamed('/data-extraction'),
                          icon: const Icon(Icons.download),
                          label: const Text('Data Extraction'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildLemburTab(),
                  _buildPresensiTab(),
                  _buildKegiatanTab(),
                  _buildPrestasiTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLemburTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Manage Lembur Activities',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildAddItemSection(
            controller: controller.lemburController,
            hintText: 'Add new lembur activity',
            onAdd: () => controller.addLemburActivity(controller.lemburController.text),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingLembur.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (controller.lemburActivityList.isEmpty) {
                return const Center(
                  child: Text(
                    'No activities found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }
              
              return ListView.builder(
                itemCount: controller.lemburActivityList.length,
                itemBuilder: (context, index) {
                  final activity = controller.lemburActivityList[index];
                  return _buildListItem(
                    title: activity,
                    onDelete: () => _showDeleteDialog(
                      'Delete Activity',
                      'Are you sure you want to delete "$activity"?',
                      () => controller.removeLemburActivity(activity),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPresensiTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Manage Presensi Kehadiran',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildAddItemSection(
            controller: controller.presensiController,
            hintText: 'Add new kehadiran type',
            onAdd: () => controller.addPresensiKehadiran(controller.presensiController.text),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingPresensi.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (controller.presensiKehadiranList.isEmpty) {
                return const Center(
                  child: Text(
                    'No kehadiran types found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }
              
              return ListView.builder(
                itemCount: controller.presensiKehadiranList.length,
                itemBuilder: (context, index) {
                  final kehadiran = controller.presensiKehadiranList[index];
                  return _buildListItem(
                    title: kehadiran,
                    onDelete: () => _showDeleteDialog(
                      'Delete Kehadiran',
                      'Are you sure you want to delete "$kehadiran"?',
                      () => controller.removePresensiKehadiran(kehadiran),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildKegiatanTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Manage Kegiatan Activities',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildAddItemSection(
            controller: controller.kegiatanController,
            hintText: 'Add new kegiatan activity',
            onAdd: () => controller.addKegiatanActivity(controller.kegiatanController.text),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingKegiatan.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (controller.kegiatanActivityList.isEmpty) {
                return const Center(
                  child: Text(
                    'No activities found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }
              
              return ListView.builder(
                itemCount: controller.kegiatanActivityList.length,
                itemBuilder: (context, index) {
                  final activity = controller.kegiatanActivityList[index];
                  return _buildListItem(
                    title: activity,
                    onDelete: () => _showDeleteDialog(
                      'Delete Activity',
                      'Are you sure you want to delete this activity?',
                      () => controller.removeKegiatanActivity(activity),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPrestasiTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Manage Prestasi Jabatan',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildAddItemSection(
            controller: controller.prestasiController,
            hintText: 'Add new jabatan',
            onAdd: () => controller.addPrestasiJabatan(controller.prestasiController.text),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingPrestasi.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (controller.prestasiJabatanList.isEmpty) {
                return const Center(
                  child: Text(
                    'No jabatan found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }
              
              return ListView.builder(
                itemCount: controller.prestasiJabatanList.length,
                itemBuilder: (context, index) {
                  final jabatan = controller.prestasiJabatanList[index];
                  return _buildListItem(
                    title: jabatan,
                    onDelete: () => _showDeleteDialog(
                      'Delete Jabatan',
                      'Are you sure you want to delete "$jabatan"?',
                      () => controller.removePrestasiJabatan(jabatan),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAddItemSection({
    required TextEditingController controller,
    required String hintText,
    required VoidCallback onAdd,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onSubmitted: (_) => onAdd(),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: onAdd,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Add'),
        ),
      ],
    );
  }

  Widget _buildListItem({
    required String title,
    required VoidCallback onDelete,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }

  void _showDeleteDialog(String title, String content, VoidCallback onConfirm) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              onConfirm();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
