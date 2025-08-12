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
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.lemburList.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada kegiatan lembur yang ditambahkan.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: controller.lemburList.length,
          itemBuilder: (context, index) {
            final lembur = controller.lemburList[index];
            final formattedDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID')
                .format(lembur.date.toDate());

            // **[MODIFIED]** The subtitle now always includes the user's name.
            final subtitleText =
                '${lembur.userName}\n$formattedDate\nJam: ${lembur.startTime} - ${lembur.endTime}';

            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
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
                subtitle: Text(subtitleText), // Use the updated subtitle text
                isThreeLine: true, // Keep as true to allow for multiple lines
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(Routes.ADD_LEMBUR),
        label: const Text('Tambah Lembur'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
