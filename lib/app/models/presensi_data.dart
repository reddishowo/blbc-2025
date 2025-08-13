import 'package:cloud_firestore/cloud_firestore.dart';

class PresensiData {
  String? id;
  String nama;
  String kehadiran;
  String status;
  String keterangan;
  String? imageUrl;
  String? location; // New field for location
  DateTime? time; // New field for time
  DateTime? createdAt;

  PresensiData({
    this.id,
    required this.nama,
    required this.kehadiran,
    required this.status,
    required this.keterangan,
    this.imageUrl,
    this.location, // Added location
    this.time, // Added time
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
      location: json['location'], // Parse location
      time: json['time'] != null
          ? (json['time'] as Timestamp).toDate()
          : null, // Parse time
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
      'location': location, // Include location in JSON
      'time': time, // Include time in JSON
      'createdAt': createdAt,
    };
  }
}