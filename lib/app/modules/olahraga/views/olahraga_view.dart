import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sppdn/app/routes/app_pages.dart';

import '../controllers/olahraga_controller.dart';

class OlahragaView extends GetView<OlahragaController> {
  const OlahragaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.olahragaList.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada kegiatan olahraga yang ditambahkan.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return _buildGroupedOlahragaList();
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(Routes.ADD_OLAHRAGA),
        label: const Text('Tambah Olahraga'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  // Calculate duration between start and end time
  String _calculateDuration(String startTime, String endTime) {
    try {
      // Parse the time strings
      List<String> startParts = startTime.split(':');
      List<String> endParts = endTime.split(':');
      
      if (startParts.length != 2 || endParts.length != 2) {
        return "$startTime - $endTime"; // Return original format if parsing fails
      }
      
      int startHour = int.parse(startParts[0]);
      int startMinute = int.parse(startParts[1]);
      int endHour = int.parse(endParts[0]);
      int endMinute = int.parse(endParts[1]);
      
      // Create DateTime objects for calculation (using today's date as base)
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day, startHour, startMinute);
      final end = DateTime(now.year, now.month, now.day, endHour, endMinute);
      
      // If end time is before start time, assume it's the next day
      final Duration difference = end.isAfter(start) 
          ? end.difference(start) 
          : end.add(const Duration(days: 1)).difference(start);
      
      // Format the duration
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;
      
      if (hours > 0 && minutes > 0) {
        return '$hours jam $minutes menit';
      } else if (hours > 0) {
        return '$hours jam';
      } else {
        return '$minutes menit';
      }
    } catch (e) {
      // If any error occurs during parsing, return the original format
      return "$startTime - $endTime";
    }
  }

  // Method to build grouped list view with date separators
  Widget _buildGroupedOlahragaList() {
    // Group the olahraga items by date
    final Map<String, List<dynamic>> groupedData = {};

    for (final olahraga in controller.olahragaList) {
      // Format date as a string key (without time)
      final DateTime olahragaDate = olahraga.date.toDate();
      final dateKey = DateFormat('yyyy-MM-dd').format(olahragaDate);

      if (!groupedData.containsKey(dateKey)) {
        groupedData[dateKey] = [];
      }

      groupedData[dateKey]!.add(olahraga);
    }

    // Sort the dates (keys) in descending order (newest first)
    final sortedDates = groupedData.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    // Build the list with separators
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: sortedDates.length * 2, // Double for headers and sections
      itemBuilder: (context, index) {
        // Even indices are date headers, odd indices are olahraga sections
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
          // This is a section of olahraga items for a date
          final dateKey = sortedDates[(index - 1) ~/ 2];
          final itemsForDate = groupedData[dateKey]!;

          // Return a column of olahraga cards for this date
          return Column(
            children: itemsForDate.map<Widget>((olahraga) {
              // Calculate duration for display
              final duration = _calculateDuration(
                olahraga.startTime, 
                olahraga.endTime
              );
              
              return GestureDetector(
                onTap: () => _showOlahragaDetail(olahraga),
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
                          olahraga.photoUrl,
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
                      olahraga.activityType,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    // Updated subtitle to show duration instead of time range
                    subtitle: Text(
                      '${olahraga.userName}\nWaktu: $duration'
                    ),
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

  // Method to show detailed olahraga information in a dialog
  void _showOlahragaDetail(dynamic olahraga) {
    final DateTime olahragaDate = olahraga.date.toDate();
    final formattedDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(olahragaDate);
    
    // Calculate duration for the detail view
    final duration = _calculateDuration(olahraga.startTime, olahraga.endTime);

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
                      olahraga.activityType,
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
                olahraga.userName,
                Icons.person,
              ),

              // Date
              _buildDetailItem(
                'Tanggal',
                formattedDate,
                Icons.calendar_today,
              ),

              // Show both the time range and duration
              _buildDetailItem(
                'Waktu',
                '${olahraga.startTime} - ${olahraga.endTime} ($duration)',
                Icons.access_time,
              ),

              // Description if available
              if (olahraga.description != null && olahraga.description.isNotEmpty)
                _buildDetailItem(
                  'Deskripsi',
                  olahraga.description,
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
                    olahraga.photoUrl,
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
}
