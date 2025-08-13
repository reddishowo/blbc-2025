import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/add_olahraga_controller.dart';

class AddOlahragaView extends GetView<AddOlahragaController> {
  const AddOlahragaView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Kegiatan Olahraga'),
        centerTitle: true,
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name field
                    TextField(
                      controller: controller.nameController,
                      readOnly: true, // Make it read-only since it's auto-filled
                      decoration: const InputDecoration(
                        labelText: 'Nama',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Activity Type field
                    TextField(
                      controller: controller.activityTypeController,
                      decoration: const InputDecoration(
                        labelText: 'Jenis Aktivitas Olahraga',
                        border: OutlineInputBorder(),
                        hintText: 'contoh: Jogging, Futsal, Badminton, dll.',
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Date field
                    GestureDetector(
                      onTap: () => controller.pickDate(context),
                      child: AbsorbPointer(
                        child: TextField(
                          controller: controller.dateController,
                          decoration: const InputDecoration(
                            labelText: 'Tanggal',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Time fields in a row
                    Row(
                      children: [
                        // Start Time
                        Expanded(
                          child: GestureDetector(
                            onTap: () => controller.pickStartTime(context),
                            child: AbsorbPointer(
                              child: TextField(
                                controller: controller.startTimeController,
                                decoration: const InputDecoration(
                                  labelText: 'Mulai',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.access_time),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // End Time
                        Expanded(
                          child: GestureDetector(
                            onTap: () => controller.pickEndTime(context),
                            child: AbsorbPointer(
                              child: TextField(
                                controller: controller.endTimeController,
                                decoration: const InputDecoration(
                                  labelText: 'Selesai',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.access_time),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Description field
                    TextField(
                      controller: controller.descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi Kegiatan',
                        border: OutlineInputBorder(),
                        hintText: 'Jelaskan secara singkat kegiatan olahraga Anda',
                      ),
                      maxLines: 3,
                    ),
                    
                    const SizedBox(height: 24),
                    const Text(
                      'Foto Kegiatan',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    
                    // Image preview
                    Center(
                      child: Obx(() {
                        return controller.pickedImage.value != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(controller.pickedImage.value!.path),
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                height: 200,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              );
                      }),
                    ),
                    
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: controller.pickImage,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Ambil Foto'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.submitOlahraga,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue,
                        ),
                        child: const Text(
                          'Submit',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
