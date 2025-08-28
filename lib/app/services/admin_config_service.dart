import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AdminConfigService extends GetxService {
  static AdminConfigService get instance => Get.find();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get lembur activities from Firestore
  Future<List<String>> getLemburActivities() async {
    try {
      final doc = await _firestore.collection('admin_config').doc('lembur_activities').get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data['items'] != null) {
          return List<String>.from(data['items']);
        }
      }
      // Fallback to default values
      return ['Piket CPO / Lartas', 'Kegiatan Lain'];
    } catch (e) {
      // Fallback to default values on error
      return ['Piket CPO / Lartas', 'Kegiatan Lain'];
    }
  }
  
  // Get presensi kehadiran from Firestore
  Future<List<String>> getPresensiKehadiran() async {
    try {
      final doc = await _firestore.collection('admin_config').doc('presensi_kehadiran').get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data['items'] != null) {
          return List<String>.from(data['items']);
        }
      }
      // Fallback to default values
      return ['WFH', 'WFO', 'WFHB', 'CUTI', 'ST'];
    } catch (e) {
      // Fallback to default values on error
      return ['WFH', 'WFO', 'WFHB', 'CUTI', 'ST'];
    }
  }
  
  // Get kegiatan activities from Firestore
  Future<List<String>> getKegiatanActivities() async {
    try {
      final doc = await _firestore.collection('admin_config').doc('kegiatan_activities').get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data['items'] != null) {
          return List<String>.from(data['items']);
        }
      }
      // Fallback to default values
      return [
        'Survei Evaluasi Budaya Organisasi',
        '[ Reskilling ] E-Learning Peningkatan Kompetensi Pemecahan Masalah dan Pengambilan Keputusan',
        '[ Reskilling II ] E-Learning Penguatan Kemampuan Analisis Pegawai dalam Menghadapi Ekosistem Kerja Baru',
        'Pelaksanaan Survei Penguatan Budaya Kementerian Keuangan',
        'Seminar PUG Kemenkeu 2023',
        'E-Learning Mandatori Penegakan Disiplin',
        'Kuesioner Piloting Presensi Melalui Aplikasi Satu Kemenkeu',
        'Pengisian Survei Forum PINTAR',
      ];
    } catch (e) {
      // Fallback to default values on error
      return [
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
  }
  
  // Get prestasi jabatan from Firestore
  Future<List<String>> getPrestasiJabatan() async {
    try {
      final doc = await _firestore.collection('admin_config').doc('prestasi_jabatan').get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data['items'] != null) {
          return List<String>.from(data['items']);
        }
      }
      // Fallback to default values
      return ['MENTERI', 'ES I', 'ES II', 'ES III', 'ES IV', 'Lainnya'];
    } catch (e) {
      // Fallback to default values on error
      return ['MENTERI', 'ES I', 'ES II', 'ES III', 'ES IV', 'Lainnya'];
    }
  }
}
