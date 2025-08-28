import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/add_prestasi_controller.dart';

class AddPrestasiView extends GetView<AddPrestasiController> {
  const AddPrestasiView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Prestasi'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add the new field for recipient name
              _buildTextField(
                controller: controller.recipientNameController,
                label: 'Nama Penerima Prestasi',
                hint: 'Masukkan nama penerima prestasi',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: controller.namaPrestasiController,
                label: 'Nama Prestasi',
                hint: 'Masukkan nama prestasi',
              ),
              const SizedBox(height: 16),
              _buildDropdown(),
              
              // Custom Jabatan field (conditionally visible)
              Obx(() => controller.showCustomJabatan.value 
                ? Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: controller.customJabatanController,
                        label: 'Jabatan Lainnya',
                        hint: 'Masukkan jabatan pemberi penghargaan',
                      ),
                    ],
                  ) 
                : const SizedBox.shrink()
              ),
              
              const SizedBox(height: 16),
              _buildTextField(
                controller: controller.namaPemberiController,
                label: 'Nama Pemberi Penghargaan',
                hint: 'Masukkan nama pemberi penghargaan',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: controller.nomorSertifikatController,
                label: 'Nomor Sertifikat (Opsional)',
                hint: 'Masukkan nomor sertifikat jika ada',
              ),
              const SizedBox(height: 16),
              _buildFilePicker(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jabatan Pemberi Penghargaan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => DropdownButtonFormField<String>(
          value: controller.selectedJabatan.value.isEmpty ? null : controller.selectedJabatan.value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
          ),
          items: controller.jabatanOptions.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: controller.onJabatanChanged,
        )),
      ],
    );
  }

  Widget _buildFilePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bukti (PDF, Word, atau Gambar)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: controller.pickFile,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Obx(() => Row(
              children: [
                const Icon(Icons.attach_file),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.selectedFileName.value.isEmpty
                        ? 'Pilih file bukti'
                        : controller.selectedFileName.value,
                    style: TextStyle(
                      color: controller.selectedFileName.value.isEmpty
                          ? Colors.grey[600]
                          : Colors.black,
                    ),
                  ),
                ),
              ],
            )),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: Obx(() => ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.submitPrestasi,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: controller.isLoading.value
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Simpan Prestasi',
                style: TextStyle(fontSize: 16),
              ),
      )),
    );
  }
}
