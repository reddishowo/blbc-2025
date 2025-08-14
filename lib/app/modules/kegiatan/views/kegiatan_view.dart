import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sppdn/app/routes/app_pages.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/kegiatan_controller.dart';

class KegiatanView extends GetView<KegiatanController> {
  const KegiatanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.kegiatanList.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada bukti kegiatan yang ditambahkan.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return _buildGroupedKegiatanList();
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(Routes.ADD_KEGIATAN),
        label: const Text('Tambah Kegiatan'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  // Method to build grouped list view with date separators
  Widget _buildGroupedKegiatanList() {
    // Group the kegiatan items by date
    final Map<String, List<dynamic>> groupedData = {};

    for (final kegiatan in controller.kegiatanList) {
      // Format date as a string key (without time)
      final DateTime kegiatanDate = kegiatan.date.toDate();
      final dateKey = DateFormat('yyyy-MM-dd').format(kegiatanDate);

      if (!groupedData.containsKey(dateKey)) {
        groupedData[dateKey] = [];
      }

      groupedData[dateKey]!.add(kegiatan);
    }

    // Sort the dates (keys) in descending order (newest first)
    final sortedDates = groupedData.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    // Build the list with separators
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: sortedDates.length * 2, // Double for headers and sections
      itemBuilder: (context, index) {
        // Even indices are date headers, odd indices are kegiatan sections
        if (index.isEven) {
          final dateKey = sortedDates[index ~/ 2];

          // Format the date for display
          final date = DateTime.parse(dateKey);
          String formattedDate = DateFormat('EEEE, dd/MM/yyyy', 'id_ID').format(date);
          // Capitalize first letter
          formattedDate = formattedDate[0].toUpperCase() + formattedDate.substring(1);

          // Return the date header
          return Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              formattedDate,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          );
        } else {
          // This is a section of kegiatan items for a date
          final dateKey = sortedDates[(index - 1) ~/ 2];
          final itemsForDate = groupedData[dateKey]!;

          // Return a column of kegiatan cards for this date
          return Column(
            children: itemsForDate.map<Widget>((kegiatan) {
              return GestureDetector(
                onTap: () => _showKegiatanDetail(kegiatan),
                child: Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                        child: Icon(
                          _getFileIcon(kegiatan.documentName),
                          color: Colors.blue,
                          size: 30,
                        ),
                      ),
                    ),
                    title: Text(
                      kegiatan.activityName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(kegiatan.userName + '\nDokumen: ${kegiatan.documentName}'),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.download_rounded, color: Colors.blue),
                      onPressed: () => _openDocument(kegiatan.documentUrl),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }
      },
    );
  }

  // Method to show detailed kegiatan information in a dialog
  void _showKegiatanDetail(dynamic kegiatan) {
    final DateTime kegiatanDate = kegiatan.date.toDate();
    final formattedDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(kegiatanDate);

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
              // Header with activity name and close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      kegiatan.activityName,
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

              // User name
              _buildDetailItem(
                'Nama',
                kegiatan.userName,
                Icons.person,
              ),

              // Date
              _buildDetailItem(
                'Tanggal',
                formattedDate,
                Icons.calendar_today,
              ),

              // Document
              _buildDetailItem(
                'Dokumen',
                kegiatan.documentName,
                Icons.description,
              ),

              const SizedBox(height: 24),

              // Download button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openDocument(kegiatan.documentUrl),
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Lihat Dokumen'),
                  style: ElevatedButton.styleFrom(
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
          Icon(icon, size: 20, color: Colors.blue),
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

  // Helper to get appropriate icon based on file extension
  IconData _getFileIcon(String fileName) {
    if (fileName.toLowerCase().endsWith('.pdf')) {
      return Icons.picture_as_pdf;
    } else if (fileName.toLowerCase().endsWith('.doc') || 
               fileName.toLowerCase().endsWith('.docx')) {
      return Icons.article;
    } else {
      return Icons.insert_drive_file;
    }
  }

  // Open the document URL
  Future<void> _openDocument(String url) async {
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
