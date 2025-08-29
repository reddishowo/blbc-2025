import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sppdn/app/routes/app_pages.dart';
import '../controllers/lembur_controller.dart';

class LemburView extends GetView<LemburController> {
  const LemburView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: controller.fetchLembur, // Or refreshLembur if you implement it
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.lemburList.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 200),
                Center(
                  child: Text(
                    'Belum ada kegiatan lembur yang ditambahkan.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ],
            );
          }

          return _buildGroupedLemburList();
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Get.toNamed(Routes.ADD_LEMBUR);
          // Refresh data when returning from add page
          controller.refreshLembur();
        },
        label: const Text('Tambah Lembur'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  // Method to build grouped list view with date separators
  Widget _buildGroupedLemburList() {
    // Group the lembur items by date
    final Map<String, List<dynamic>> groupedData = {};

    for (final lembur in controller.lemburList) {
      // Format date as a string key (without time)
      final DateTime lemburDate = lembur.date.toDate();
      final dateKey = DateFormat('yyyy-MM-dd').format(lemburDate);

      if (!groupedData.containsKey(dateKey)) {
        groupedData[dateKey] = [];
      }

      groupedData[dateKey]!.add(lembur);
    }

    // Sort the dates (keys) in descending order (newest first)
    final sortedDates = groupedData.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    // Build the list with separators
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: sortedDates.length * 2, // Double for headers and sections
      itemBuilder: (context, index) {
        // Even indices are date headers, odd indices are lembur sections
        if (index.isEven) {
          final dateKey = sortedDates[index ~/ 2];

          // Format the date for display
          final date = DateTime.parse(dateKey);
          String formattedDate = _formatDateWithToday(date);

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
          // This is a section of lembur items for a date
          final dateKey = sortedDates[(index - 1) ~/ 2];
          final itemsForDate = groupedData[dateKey]!;

          // Return a column of lembur cards for this date
          return Column(
            children: itemsForDate.map<Widget>((lembur) {
              return GestureDetector(
                onTap: () => _showLemburDetail(lembur),
                child: Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    leading: SizedBox(
                      width: 60,
                      height: 60,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          lembur.photoUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(child: Icon(Icons.broken_image));
                          },
                        ),
                      ),
                    ),
                    title: Text(
                      lembur.activityType,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(lembur.userName + '\nJam: ${lembur.startTime} - ${lembur.endTime}'),
                    isThreeLine: true,
                  ),
                ),
              );
            }).toList(),
          );
        }
      },
    );
  }

  // Method to show detailed lembur information in a dialog
  void _showLemburDetail(dynamic lembur) {
    final DateTime lemburDate = lembur.date.toDate();
    final formattedDate = _formatDateWithToday(lemburDate);

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
              // Header with activity type and close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      lembur.activityType,
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
                lembur.userName,
                Icons.person,
              ),

              // Date
              _buildDetailItem(
                'Tanggal',
                formattedDate,
                Icons.calendar_today,
              ),

              // Time range
              _buildDetailItem(
                'Waktu',
                '${lembur.startTime} - ${lembur.endTime}',
                Icons.access_time,
              ),

              // Description if available
              if (lembur.description != null && lembur.description.isNotEmpty)
                _buildDetailItem(
                  'Deskripsi',
                  lembur.description,
                  Icons.description,
                ),

              // Photo
              const SizedBox(height: 16),
              const Text(
                'Foto Kegiatan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    lembur.photoUrl,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, size: 50),
                        ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
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

  // Helper method to format date with "Today" and "Yesterday"
  String _formatDateWithToday(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);
    
    if (dateToCheck == today) {
      return 'Today';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday';
    } else {
      String formattedDate = DateFormat('EEEE, dd/MM/yyyy', 'id_ID').format(date);
      // Capitalize first letter
      return formattedDate[0].toUpperCase() + formattedDate.substring(1);
    }
  }
}
