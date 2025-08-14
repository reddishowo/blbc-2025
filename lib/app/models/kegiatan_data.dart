import 'package:cloud_firestore/cloud_firestore.dart';

class KegiatanModel {
  final String id;
  final String userId;
  final String userName;
  final String activityName;
  final Timestamp date;
  final String documentUrl;
  final String documentName;
  final Timestamp createdAt;

  KegiatanModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.activityName,
    required this.date,
    required this.documentUrl,
    required this.documentName,
    required this.createdAt,
  });

  factory KegiatanModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return KegiatanModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      activityName: data['activityName'] ?? '',
      date: data['date'] ?? Timestamp.now(),
      documentUrl: data['documentUrl'] ?? '',
      documentName: data['documentName'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'activityName': activityName,
      'date': date,
      'documentUrl': documentUrl,
      'documentName': documentName,
      'createdAt': createdAt,
    };
  }
}