import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/add_lembur_controller.dart';

class AddLemburView extends GetView<AddLemburController> {
  const AddLemburView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Kegiatan Lembur'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: controller.nameController,
                label: 'Nama',
                readOnly: true,
              ),
              const SizedBox(height: 16),
              Obx(() => DropdownButtonFormField<String>(
                    value: controller.selectedActivity.value.isEmpty ? null : controller.selectedActivity.value,
                    decoration: const InputDecoration(
                      labelText: 'Jenis Kegiatan',
                      border: OutlineInputBorder(),
                    ),
                    items: controller.activityOptions
                        .map((activity) => DropdownMenuItem(
                              value: activity,
                              child: Text(activity),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.selectedActivity.value = value;
                      }
                    },
                    validator: (value) =>
                        value == null ? 'Pilih jenis kegiatan' : null,
                  )),
              const SizedBox(height: 16),
              Obx(() {
                if (controller.selectedActivity.value == 'Kegiatan Lain') {
                  return _buildTextField(
                    controller: controller.otherActivityController,
                    label: 'Nama Kegiatan Lain',
                    hint: 'Masukkan nama kegiatan',
                    validator: (value) {
                      if (controller.selectedActivity.value == 'Kegiatan Lain' &&
                          (value == null || value.isEmpty)) {
                        return 'Nama kegiatan lain tidak boleh kosong';
                      }
                      return null;
                    },
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }),
              const SizedBox(height: 16),
              _buildTextField(
                controller: controller.dateController,
                label: 'Tanggal',
                readOnly: true,
                icon: Icons.calendar_today,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTimeField(context, controller.startTimeController, 'Waktu Mulai'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTimeField(context, controller.endTimeController, 'Waktu Selesai'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Foto Output Pekerjaan', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Obx(() {
                return Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: controller.pickedImage.value != null
                      ? Image.file(
                          File(controller.pickedImage.value!.path),
                          fit: BoxFit.cover,
                        )
                      : const Center(child: Text('Belum ada foto dipilih')),
                );
              }),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: controller.pickImage,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Pilih Foto'),
              ),
              const SizedBox(height: 32),
              Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value ? null : controller.submit,
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Submit'),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        prefixIcon: icon != null ? Icon(icon) : null,
      ),
      validator: validator,
    );
  }

  Widget _buildTimeField(BuildContext context, TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.access_time),
      ),
      onTap: () async {
        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (pickedTime != null) {
          // ignore: use_build_context_synchronously
          controller.text = pickedTime.format(context);
        }
      },
      validator: (value) =>
          value == null || value.isEmpty ? 'Waktu tidak boleh kosong' : null,
    );
  }
}