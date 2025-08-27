import 'package:cloud_firestore/cloud_firestore.dart';

class PrestasiData {
  final String id;
  final String userId;
  final String nama;
  final String recipientName; // Add this field
  final String namaPrestasi;
  final String jabatanPemberi;
  final String namaPemberi;
  final String nomorSertifikat;
  final String buktiUrl;
  final String buktiFileName;
  final DateTime? createdAt;

  PrestasiData({
    required this.id,
    required this.userId,
    required this.nama,
    required this.recipientName, // Add this field
    required this.namaPrestasi,
    required this.jabatanPemberi,
    required this.namaPemberi,
    required this.nomorSertifikat,
    required this.buktiUrl,
    required this.buktiFileName,
    this.createdAt,
  });

  factory PrestasiData.fromFirestore(Map<String, dynamic> data, String id) {
    return PrestasiData(
      id: id,
      userId: data['userId'] ?? '',
      nama: data['nama'] ?? '',
      recipientName: data['recipientName'] ?? data['nama'] ?? '', // Add this field with fallback to nama
      namaPrestasi: data['namaPrestasi'] ?? '',
      jabatanPemberi: data['jabatanPemberi'] ?? '',
      namaPemberi: data['namaPemberi'] ?? '',
      nomorSertifikat: data['nomorSertifikat'] ?? '',
      buktiUrl: data['buktiUrl'] ?? '',
      buktiFileName: data['buktiFileName'] ?? '',
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'nama': nama,
      'recipientName': recipientName, // Add this field
      'namaPrestasi': namaPrestasi,
      'jabatanPemberi': jabatanPemberi,
      'namaPemberi': namaPemberi,
      'nomorSertifikat': nomorSertifikat,
      'buktiUrl': buktiUrl,
      'buktiFileName': buktiFileName,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }
}