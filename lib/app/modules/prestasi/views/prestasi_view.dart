import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/prestasi_controller.dart';
import '../../../routes/app_pages.dart';

class PrestasiView extends GetView<PrestasiController> {
  const PrestasiView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prestasi'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.prestasiList.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada data prestasi',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshPrestasi,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.prestasiList.length,
            itemBuilder: (context, index) {
              final prestasi = controller.prestasiList[index];
              return _buildPrestasiCard(prestasi);
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.ADD_PRESTASI),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPrestasiCard(prestasi) {
    // Remove file extension from filename
    String displayFileName = prestasi.buktiFileName;
    if (displayFileName.contains('.')) {
      displayFileName = displayFileName.substring(0, displayFileName.lastIndexOf('.'));
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              prestasi.nama,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              displayFileName,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
