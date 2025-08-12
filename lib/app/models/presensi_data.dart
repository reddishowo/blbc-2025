import 'package:cloud_firestore/cloud_firestore.dart';

class PresensiData {
  String? id;
  String nama;
  String kehadiran;
  String status;
  String keterangan;
  String? imageUrl;
  DateTime? createdAt;

  PresensiData({
    this.id,
    required this.nama,
    required this.kehadiran,
    required this.status,
    required this.keterangan,
    this.imageUrl,
    this.createdAt,
  });

  factory PresensiData.fromJson(Map<String, dynamic> json) {
    return PresensiData(
      id: json['id'],
      nama: json['nama'] ?? '',
      kehadiran: json['kehadiran'] ?? '',
      status: json['status'] ?? '',
      keterangan: json['keterangan'] ?? '',
      imageUrl: json['imageUrl'],
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'kehadiran': kehadiran,
      'status': status,
      'keterangan': keterangan,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
    };
  }
}