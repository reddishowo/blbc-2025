import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import '../controllers/presensi_controller.dart';

class PresensiView extends GetView<PresensiController> {
  const PresensiView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: controller.fetchPresensiData,
        child: Obx(
          () => controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : controller.presensiList.isEmpty
                  ? const Center(child: Text('Tidak ada data presensi'))
                  : _buildGroupedListView(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/add-presensi'),
        child: const Icon(Icons.add),
      ),
    );
  }
  
  // New method to build grouped list view with date separators
  Widget _buildGroupedListView() {
    // Group the presensi items by date
    final Map<String, List<dynamic>> groupedData = {};
    
    for (final presensi in controller.presensiList) {
      if (presensi.time != null) {
        // Format date as a string key (without time)
        final dateKey = DateFormat('yyyy-MM-dd').format(presensi.time!);
        
        if (!groupedData.containsKey(dateKey)) {
          groupedData[dateKey] = [];
        }
        
        groupedData[dateKey]!.add(presensi);
      } else {
        // Handle items without a date (put in "No Date" group)
        final String noDateKey = 'No Date';
        if (!groupedData.containsKey(noDateKey)) {
          groupedData[noDateKey] = [];
        }
        
        groupedData[noDateKey]!.add(presensi);
      }
    }
    
    // Sort the dates (keys) in descending order (newest first)
    final sortedDates = groupedData.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    
    // Build the list with separators
    return ListView.builder(
      itemCount: sortedDates.length * 2, // Double for headers and sections
      itemBuilder: (context, index) {
        // Even indices are date headers, odd indices are presensi sections
        if (index.isEven) {
          final dateKey = sortedDates[index ~/ 2];
          
          // Format the date for display
          String formattedDate;
          if (dateKey == 'No Date') {
            formattedDate = 'Tanggal Tidak Tersedia';
          } else {
            final date = DateTime.parse(dateKey);
            formattedDate = _formatDateWithToday(date);
          }
          
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
          // This is a section of presensi items for a date
          final dateKey = sortedDates[(index - 1) ~/ 2];
          final itemsForDate = groupedData[dateKey]!;
          
          // Return a column of presensi cards for this date
          return Column(
            children: itemsForDate.map<Widget>((presensi) {
              return GestureDetector(
                onTap: () => _showPresensiDetail(presensi),
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row with name and time
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                presensi.nama,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            // Format and display time if available
                            if (presensi.time != null)
                              Text(
                                DateFormat('HH:mm').format(presensi.time!),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                        
                        // Location if available
                        if (presensi.location != null && presensi.location!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    presensi.location!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        // Details row in a more compact format
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDetailRow('kehadiran', presensi.kehadiran),
                                  const SizedBox(height: 4),
                                  _buildDetailRow('status', presensi.status),
                                  const SizedBox(height: 4),
                                  _buildDetailRow('ket', presensi.keterangan),
                                ],
                              ),
                            ),
                            
                            // Image on the right side if available
                            if (presensi.imageUrl != null &&
                                presensi.imageUrl!.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  presensi.imageUrl!,
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        height: 80,
                                        width: 80,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.broken_image),
                                      ),
                                ),
                              ),
                          ],
                        ),
                      ],
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
  
  // Method to show detailed presensi information in a dialog
  void _showPresensiDetail(dynamic presensi) {
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
              // Header with name and time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      presensi.nama,
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
              
              // Time detail
              if (presensi.time != null)
                _buildDetailItem(
                  'Waktu', 
                  DateFormat('HH:mm, dd MMM yyyy').format(presensi.time!),
                  Icons.access_time,
                ),
              
              // Location detail
              if (presensi.location != null && presensi.location!.isNotEmpty)
                _buildDetailItem(
                  'Lokasi', 
                  presensi.location!,
                  Icons.location_on,
                ),
              
              // Kehadiran detail
              _buildDetailItem(
                'Kehadiran', 
                presensi.kehadiran,
                Icons.how_to_reg,
              ),
              
              // Status detail
              _buildDetailItem(
                'Status', 
                presensi.status,
                Icons.medical_information,
              ),
              
              // Keterangan detail
              _buildDetailItem(
                'Keterangan', 
                presensi.keterangan,
                Icons.notes,
              ),
              
              // Image if available
              if (presensi.imageUrl != null && presensi.imageUrl!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Foto',
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
                      presensi.imageUrl!,
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
              ],
              
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
  
  // Helper method to build detail rows with better alignment
  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ),
        Text(
          ': ',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
            ),
          ),
        ),
      ],
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