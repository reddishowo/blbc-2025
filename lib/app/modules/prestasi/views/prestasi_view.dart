import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/prestasi_controller.dart';
import '../../../routes/app_pages.dart';

class PrestasiView extends GetView<PrestasiController> {
  const PrestasiView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

    return GestureDetector(
      onTap: () => _showPrestasiDetail(prestasi),
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          leading: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Center(
              child: Icon(
                Icons.emoji_events,
                color: Colors.amber.shade700,
                size: 30,
              ),
            ),
          ),
          title: Text(
            // Use recipientName instead of nama
            prestasi.recipientName ?? prestasi.nama,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(prestasi.namaPrestasi),
              const SizedBox(height: 4),
              Text(
                'Dokumen: $displayFileName',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          isThreeLine: true,
          trailing: IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.amber),
            onPressed: () => _openDocument(prestasi.buktiUrl),
          ),
        ),
      ),
    );
  }

  // Method to show detailed prestasi information in a dialog
  void _showPrestasiDetail(dynamic prestasi) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with prestasi name and close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      prestasi.namaPrestasi,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  // Close button
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),

              const Divider(height: 24),

              // Recipient Name (instead of account holder name)
              _buildDetailItem(
                'Nama Penerima',
                prestasi.recipientName ?? prestasi.nama,
                Icons.person,
              ),

              // Nama Prestasi
              _buildDetailItem(
                'Nama Prestasi',
                prestasi.namaPrestasi,
                Icons.emoji_events,
              ),

              // Jabatan Pemberi
              _buildDetailItem(
                'Jabatan Pemberi Penghargaan',
                prestasi.jabatanPemberi,
                Icons.work,
              ),

              // Nama Pemberi
              _buildDetailItem(
                'Nama Pemberi Penghargaan',
                prestasi.namaPemberi,
                Icons.person_outline,
              ),

              // Nomor Sertifikat
              _buildDetailItem(
                'Nomor Sertifikat',
                prestasi.nomorSertifikat,
                Icons.confirmation_number,
              ),

              // Document
              _buildDetailItem(
                'Bukti',
                prestasi.buktiFileName,
                Icons.description,
              ),

              const SizedBox(height: 24),

              // Download button
              if (prestasi.buktiUrl != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openDocument(prestasi.buktiUrl),
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Lihat Bukti'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Close button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build a detail item in the dialog
  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.amber.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Open the document URL
  Future<void> _openDocument(String? url) async {
    if (url == null || url.isEmpty) {
      Get.snackbar(
        'Error',
        'URL dokumen tidak tersedia',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Error',
        'Tidak dapat membuka dokumen',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
