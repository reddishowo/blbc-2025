import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';

class AdminController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Loading states
  final RxBool isLoadingLembur = false.obs;
  final RxBool isLoadingPresensi = false.obs;
  final RxBool isLoadingKegiatan = false.obs;
  final RxBool isLoadingPrestasi = false.obs;
  
  // Lists for admin management
  final RxList<String> lemburActivityList = <String>[].obs;
  final RxList<String> presensiKehadiranList = <String>[].obs;
  final RxList<String> kegiatanActivityList = <String>[].obs;
  final RxList<String> prestasiJabatanList = <String>[].obs;
  
  // Text controllers for adding new items
  final TextEditingController lemburController = TextEditingController();
  final TextEditingController presensiController = TextEditingController();
  final TextEditingController kegiatanController = TextEditingController();
  final TextEditingController prestasiController = TextEditingController();
  
  @override
  void onInit() {
    super.onInit();
    initializeDefaultData();
    loadAllData();
  }
  
  @override
  void onClose() {
    lemburController.dispose();
    presensiController.dispose();
    kegiatanController.dispose();
    prestasiController.dispose();
    super.onClose();
  }
  
  // Check if current user is admin
  bool get isAdmin => AuthController.instance.isAdmin;
  
  // Initialize default data if collections don't exist
  Future<void> initializeDefaultData() async {
    if (!isAdmin) return; // Only admin can initialize data
    
    try {
      // Initialize Lembur Activities
      final lemburDoc = await _firestore.collection('admin_config').doc('lembur_activities').get();
      if (!lemburDoc.exists) {
        await _firestore.collection('admin_config').doc('lembur_activities').set({
          'items': ['Piket CPO / Lartas', 'Kegiatan Lain'],
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('Initialized lembur activities');
      }
      
      // Initialize Presensi Kehadiran
      final presensiDoc = await _firestore.collection('admin_config').doc('presensi_kehadiran').get();
      if (!presensiDoc.exists) {
        await _firestore.collection('admin_config').doc('presensi_kehadiran').set({
          'items': ['WFH', 'WFO', 'WFHB', 'CUTI', 'ST'],
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('Initialized presensi kehadiran');
      }
      
      // Initialize Kegiatan Activities
      final kegiatanDoc = await _firestore.collection('admin_config').doc('kegiatan_activities').get();
      if (!kegiatanDoc.exists) {
        await _firestore.collection('admin_config').doc('kegiatan_activities').set({
          'items': [
            'Survei Evaluasi Budaya Organisasi',
            '[ Reskilling ] E-Learning Peningkatan Kompetensi Pemecahan Masalah dan Pengambilan Keputusan',
            '[ Reskilling II ] E-Learning Penguatan Kemampuan Analisis Pegawai dalam Menghadapi Ekosistem Kerja Baru',
            'Pelaksanaan Survei Penguatan Budaya Kementerian Keuangan',
            'Seminar PUG Kemenkeu 2023',
            'E-Learning Mandatori Penegakan Disiplin',
            'Kuesioner Piloting Presensi Melalui Aplikasi Satu Kemenkeu',
            'Pengisian Survei Forum PINTAR',
          ],
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('Initialized kegiatan activities');
      }
      
      // Initialize Prestasi Jabatan
      final prestasiDoc = await _firestore.collection('admin_config').doc('prestasi_jabatan').get();
      if (!prestasiDoc.exists) {
        await _firestore.collection('admin_config').doc('prestasi_jabatan').set({
          'items': ['MENTERI', 'ES I', 'ES II', 'ES III', 'ES IV', 'Lainnya'],
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('Initialized prestasi jabatan');
      }
      
    } catch (e) {
      print('Failed to initialize default data: $e');
      // Set fallback data locally if Firestore fails
      lemburActivityList.value = ['Piket CPO / Lartas', 'Kegiatan Lain'];
      presensiKehadiranList.value = ['WFH', 'WFO', 'WFHB', 'CUTI', 'ST'];
      kegiatanActivityList.value = [
        'Survei Evaluasi Budaya Organisasi',
        '[ Reskilling ] E-Learning Peningkatan Kompetensi Pemecahan Masalah dan Pengambilan Keputusan',
        '[ Reskilling II ] E-Learning Penguatan Kemampuan Analisis Pegawai dalam Menghadapi Ekosistem Kerja Baru',
        'Pelaksanaan Survei Penguatan Budaya Kementerian Keuangan',
        'Seminar PUG Kemenkeu 2023',
        'E-Learning Mandatori Penegakan Disiplin',
        'Kuesioner Piloting Presensi Melalui Aplikasi Satu Kemenkeu',
        'Pengisian Survei Forum PINTAR',
      ];
      prestasiJabatanList.value = ['MENTERI', 'ES I', 'ES II', 'ES III', 'ES IV', 'Lainnya'];
    }
  }
  
  // Load all data from Firestore
  Future<void> loadAllData() async {
    await Future.wait([
      _loadLemburActivities(),
      _loadPresensiKehadiran(),
      _loadKegiatanActivities(),
      _loadPrestasiJabatan(),
    ]);
  }
  
  // Load Lembur Activities
  Future<void> _loadLemburActivities() async {
    if (!isAdmin) {
      lemburActivityList.value = ['Piket CPO / Lartas', 'Kegiatan Lain'];
      return;
    }
    
    try {
      isLoadingLembur.value = true;
      final doc = await _firestore.collection('admin_config').doc('lembur_activities').get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data['items'] != null) {
          lemburActivityList.value = List<String>.from(data['items']);
        } else {
          lemburActivityList.value = ['Piket CPO / Lartas', 'Kegiatan Lain'];
        }
      } else {
        lemburActivityList.value = ['Piket CPO / Lartas', 'Kegiatan Lain'];
      }
    } catch (e) {
      print('Error loading lembur activities: $e');
      lemburActivityList.value = ['Piket CPO / Lartas', 'Kegiatan Lain'];
      if (e.toString().contains('permission-denied')) {
        Get.snackbar('Permission Error', 'You need admin privileges to access this data');
      }
    } finally {
      isLoadingLembur.value = false;
    }
  }
  
  // Load Presensi Kehadiran
  Future<void> _loadPresensiKehadiran() async {
    if (!isAdmin) {
      presensiKehadiranList.value = ['WFH', 'WFO', 'WFHB', 'CUTI', 'ST'];
      return;
    }
    
    try {
      isLoadingPresensi.value = true;
      final doc = await _firestore.collection('admin_config').doc('presensi_kehadiran').get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data['items'] != null) {
          presensiKehadiranList.value = List<String>.from(data['items']);
        } else {
          presensiKehadiranList.value = ['WFH', 'WFO', 'WFHB', 'CUTI', 'ST'];
        }
      } else {
        presensiKehadiranList.value = ['WFH', 'WFO', 'WFHB', 'CUTI', 'ST'];
      }
    } catch (e) {
      print('Error loading presensi kehadiran: $e');
      presensiKehadiranList.value = ['WFH', 'WFO', 'WFHB', 'CUTI', 'ST'];
      if (e.toString().contains('permission-denied')) {
        Get.snackbar('Permission Error', 'You need admin privileges to access this data');
      }
    } finally {
      isLoadingPresensi.value = false;
    }
  }
  
  // Load Kegiatan Activities
  Future<void> _loadKegiatanActivities() async {
    if (!isAdmin) {
      kegiatanActivityList.value = [
        'Survei Evaluasi Budaya Organisasi',
        '[ Reskilling ] E-Learning Peningkatan Kompetensi Pemecahan Masalah dan Pengambilan Keputusan',
        '[ Reskilling II ] E-Learning Penguatan Kemampuan Analisis Pegawai dalam Menghadapi Ekosistem Kerja Baru',
        'Pelaksanaan Survei Penguatan Budaya Kementerian Keuangan',
        'Seminar PUG Kemenkeu 2023',
        'E-Learning Mandatori Penegakan Disiplin',
        'Kuesioner Piloting Presensi Melalui Aplikasi Satu Kemenkeu',
        'Pengisian Survei Forum PINTAR',
      ];
      return;
    }
    
    try {
      isLoadingKegiatan.value = true;
      final doc = await _firestore.collection('admin_config').doc('kegiatan_activities').get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data['items'] != null) {
          kegiatanActivityList.value = List<String>.from(data['items']);
        } else {
          kegiatanActivityList.value = [
            'Survei Evaluasi Budaya Organisasi',
            '[ Reskilling ] E-Learning Peningkatan Kompetensi Pemecahan Masalah dan Pengambilan Keputusan',
            '[ Reskilling II ] E-Learning Penguatan Kemampuan Analisis Pegawai dalam Menghadapi Ekosistem Kerja Baru',
            'Pelaksanaan Survei Penguatan Budaya Kementerian Keuangan',
            'Seminar PUG Kemenkeu 2023',
            'E-Learning Mandatori Penegakan Disiplin',
            'Kuesioner Piloting Presensi Melalui Aplikasi Satu Kemenkeu',
            'Pengisian Survei Forum PINTAR',
          ];
        }
      } else {
        kegiatanActivityList.value = [
          'Survei Evaluasi Budaya Organisasi',
          '[ Reskilling ] E-Learning Peningkatan Kompetensi Pemecahan Masalah dan Pengambilan Keputusan',
          '[ Reskilling II ] E-Learning Penguatan Kemampuan Analisis Pegawai dalam Menghadapi Ekosistem Kerja Baru',
          'Pelaksanaan Survei Penguatan Budaya Kementerian Keuangan',
          'Seminar PUG Kemenkeu 2023',
          'E-Learning Mandatori Penegakan Disiplin',
          'Kuesioner Piloting Presensi Melalui Aplikasi Satu Kemenkeu',
          'Pengisian Survei Forum PINTAR',
        ];
      }
    } catch (e) {
      print('Error loading kegiatan activities: $e');
      kegiatanActivityList.value = [
        'Survei Evaluasi Budaya Organisasi',
        '[ Reskilling ] E-Learning Peningkatan Kompetensi Pemecahan Masalah dan Pengambilan Keputusan',
        '[ Reskilling II ] E-Learning Penguatan Kemampuan Analisis Pegawai dalam Menghadapi Ekosistem Kerja Baru',
        'Pelaksanaan Survei Penguatan Budaya Kementerian Keuangan',
        'Seminar PUG Kemenkeu 2023',
        'E-Learning Mandatori Penegakan Disiplin',
        'Kuesioner Piloting Presensi Melalui Aplikasi Satu Kemenkeu',
        'Pengisian Survei Forum PINTAR',
      ];
      if (e.toString().contains('permission-denied')) {
        Get.snackbar('Permission Error', 'You need admin privileges to access this data');
      }
    } finally {
      isLoadingKegiatan.value = false;
    }
  }
  
  // Load Prestasi Jabatan
  Future<void> _loadPrestasiJabatan() async {
    if (!isAdmin) {
      prestasiJabatanList.value = ['MENTERI', 'ES I', 'ES II', 'ES III', 'ES IV', 'Lainnya'];
      return;
    }
    
    try {
      isLoadingPrestasi.value = true;
      final doc = await _firestore.collection('admin_config').doc('prestasi_jabatan').get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data['items'] != null) {
          prestasiJabatanList.value = List<String>.from(data['items']);
        } else {
          prestasiJabatanList.value = ['MENTERI', 'ES I', 'ES II', 'ES III', 'ES IV', 'Lainnya'];
        }
      } else {
        prestasiJabatanList.value = ['MENTERI', 'ES I', 'ES II', 'ES III', 'ES IV', 'Lainnya'];
      }
    } catch (e) {
      print('Error loading prestasi jabatan: $e');
      prestasiJabatanList.value = ['MENTERI', 'ES I', 'ES II', 'ES III', 'ES IV', 'Lainnya'];
      if (e.toString().contains('permission-denied')) {
        Get.snackbar('Permission Error', 'You need admin privileges to access this data');
      }
    } finally {
      isLoadingPrestasi.value = false;
    }
  }
  
  // Add new item to Lembur Activities
  Future<void> addLemburActivity(String activity) async {
    if (activity.trim().isEmpty) {
      Get.snackbar('Error', 'Activity name cannot be empty');
      return;
    }
    
    if (lemburActivityList.contains(activity.trim())) {
      Get.snackbar('Error', 'Activity already exists');
      return;
    }
    
    if (!isAdmin) {
      Get.snackbar('Error', 'You need admin privileges to perform this action');
      return;
    }
    
    try {
      // Debug info
      final user = AuthController.instance.firebaseUser.value;
      print('Current user: ${user?.email}');
      print('Is admin: $isAdmin');
      print('User UID: ${user?.uid}');
      
      lemburActivityList.add(activity.trim());
      await _firestore.collection('admin_config').doc('lembur_activities').set({
        'items': lemburActivityList.toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      lemburController.clear();
      Get.snackbar('Success', 'Activity added successfully', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      lemburActivityList.remove(activity.trim()); // Rollback on error
      print('Error adding activity: $e');
      Get.snackbar('Error', 'Failed to add activity: $e');
    }
  }
  
  // Remove item from Lembur Activities
  Future<void> removeLemburActivity(String activity) async {
    try {
      lemburActivityList.remove(activity);
      await _firestore.collection('admin_config').doc('lembur_activities').set({
        'items': lemburActivityList.toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      Get.snackbar('Success', 'Activity removed successfully', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      lemburActivityList.add(activity); // Rollback on error
      Get.snackbar('Error', 'Failed to remove activity: $e');
    }
  }
  
  // Add new item to Presensi Kehadiran
  Future<void> addPresensiKehadiran(String kehadiran) async {
    if (kehadiran.trim().isEmpty) {
      Get.snackbar('Error', 'Kehadiran name cannot be empty');
      return;
    }
    
    if (presensiKehadiranList.contains(kehadiran.trim())) {
      Get.snackbar('Error', 'Kehadiran already exists');
      return;
    }
    
    try {
      presensiKehadiranList.add(kehadiran.trim());
      await _firestore.collection('admin_config').doc('presensi_kehadiran').set({
        'items': presensiKehadiranList.toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      presensiController.clear();
      Get.snackbar('Success', 'Kehadiran added successfully', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      presensiKehadiranList.remove(kehadiran.trim());
      Get.snackbar('Error', 'Failed to add kehadiran: $e');
    }
  }
  
  // Remove item from Presensi Kehadiran
  Future<void> removePresensiKehadiran(String kehadiran) async {
    try {
      presensiKehadiranList.remove(kehadiran);
      await _firestore.collection('admin_config').doc('presensi_kehadiran').set({
        'items': presensiKehadiranList.toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      Get.snackbar('Success', 'Kehadiran removed successfully', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      presensiKehadiranList.add(kehadiran);
      Get.snackbar('Error', 'Failed to remove kehadiran: $e');
    }
  }
  
  // Add new item to Kegiatan Activities
  Future<void> addKegiatanActivity(String activity) async {
    if (activity.trim().isEmpty) {
      Get.snackbar('Error', 'Activity name cannot be empty');
      return;
    }
    
    if (kegiatanActivityList.contains(activity.trim())) {
      Get.snackbar('Error', 'Activity already exists');
      return;
    }
    
    try {
      kegiatanActivityList.add(activity.trim());
      await _firestore.collection('admin_config').doc('kegiatan_activities').set({
        'items': kegiatanActivityList.toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      kegiatanController.clear();
      Get.snackbar('Success', 'Activity added successfully', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      kegiatanActivityList.remove(activity.trim());
      Get.snackbar('Error', 'Failed to add activity: $e');
    }
  }
  
  // Remove item from Kegiatan Activities
  Future<void> removeKegiatanActivity(String activity) async {
    try {
      kegiatanActivityList.remove(activity);
      await _firestore.collection('admin_config').doc('kegiatan_activities').set({
        'items': kegiatanActivityList.toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      Get.snackbar('Success', 'Activity removed successfully', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      kegiatanActivityList.add(activity);
      Get.snackbar('Error', 'Failed to remove activity: $e');
    }
  }
  
  // Add new item to Prestasi Jabatan
  Future<void> addPrestasiJabatan(String jabatan) async {
    if (jabatan.trim().isEmpty) {
      Get.snackbar('Error', 'Jabatan name cannot be empty');
      return;
    }
    
    if (prestasiJabatanList.contains(jabatan.trim())) {
      Get.snackbar('Error', 'Jabatan already exists');
      return;
    }
    
    try {
      prestasiJabatanList.add(jabatan.trim());
      await _firestore.collection('admin_config').doc('prestasi_jabatan').set({
        'items': prestasiJabatanList.toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      prestasiController.clear();
      Get.snackbar('Success', 'Jabatan added successfully', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      prestasiJabatanList.remove(jabatan.trim());
      Get.snackbar('Error', 'Failed to add jabatan: $e');
    }
  }
  
  // Remove item from Prestasi Jabatan
  Future<void> removePrestasiJabatan(String jabatan) async {
    try {
      prestasiJabatanList.remove(jabatan);
      await _firestore.collection('admin_config').doc('prestasi_jabatan').set({
        'items': prestasiJabatanList.toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      Get.snackbar('Success', 'Jabatan removed successfully', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      prestasiJabatanList.add(jabatan);
      Get.snackbar('Error', 'Failed to remove jabatan: $e');
    }
  }
}
