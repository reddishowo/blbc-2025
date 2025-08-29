import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.indigo,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Obx(() => controller.isEditing.value
              ? Row(
                  children: [
                    IconButton(
                      onPressed: controller.cancelEdit,
                      icon: const Icon(Icons.close),
                      tooltip: 'Cancel',
                    ),
                    IconButton(
                      onPressed: controller.updateProfile,
                      icon: const Icon(Icons.check),
                      tooltip: 'Save',
                    ),
                  ],
                )
              : IconButton(
                  onPressed: controller.toggleEditMode,
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit Profile',
                ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            controller.loadUserProfile();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Profile Header Card
                _buildProfileHeader(),
                const SizedBox(height: 20),
                
                // Profile Information Card
                _buildProfileInfoCard(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            Obx(() => CircleAvatar(
              radius: 50,
              backgroundColor: Colors.indigo.shade100,
              child: Text(
                controller.currentUserName.value.isNotEmpty
                    ? controller.currentUserName.value[0].toUpperCase()
                    : 'U',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade700,
                ),
              ),
            )),
            const SizedBox(height: 15),
            
            // Name
            Obx(() => Text(
              controller.currentUserName.value.isNotEmpty
                  ? controller.currentUserName.value
                  : 'User Name',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            )),
            const SizedBox(height: 5),
            
            // Role Badge
            Obx(() => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: controller.currentUserRole.value == 'admin' 
                    ? Colors.orange.shade100 
                    : Colors.blue.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: controller.currentUserRole.value == 'admin' 
                      ? Colors.orange.shade300 
                      : Colors.blue.shade300,
                ),
              ),
              child: Text(
                controller.getRoleDisplayName(controller.currentUserRole.value),
                style: TextStyle(
                  color: controller.currentUserRole.value == 'admin' 
                      ? Colors.orange.shade700 
                      : Colors.blue.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoCard() {
    return Obx(() => Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.indigo.shade600),
                const SizedBox(width: 10),
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Name Field
            _buildProfileField(
              label: 'Full Name',
              textController: controller.nameController,
              icon: Icons.account_circle,
              isEditable: true,
            ),
            const SizedBox(height: 15),
            
            // Email Field (Read-only)
            _buildProfileField(
              label: 'Email Address',
              textController: controller.emailController,
              icon: Icons.email,
              isEditable: false,
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildProfileField({
    required String label,
    required TextEditingController textController,
    required IconData icon,
    required bool isEditable,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: textController,
          enabled: isEditable ? controller.isEditing.value : false,
          style: TextStyle(
            color: isEditable && controller.isEditing.value 
                ? Colors.black87 
                : Colors.grey[600],
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: isEditable && controller.isEditing.value 
                  ? Colors.indigo 
                  : Colors.grey,
            ),
            suffixIcon: !isEditable 
                ? const Icon(Icons.lock, color: Colors.grey, size: 20)
                : null,
            filled: true,
            fillColor: isEditable && controller.isEditing.value 
                ? Colors.white 
                : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.indigo,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
