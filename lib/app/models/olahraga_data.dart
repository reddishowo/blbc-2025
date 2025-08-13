import 'package:cloud_firestore/cloud_firestore.dart';

class OlahragaModel {
  final String id;
  final String userId;
  final String userName;
  final String activityType;
  final String description;
  final String photoUrl;
  final String startTime;
  final String endTime;
  final Timestamp date;
  final Timestamp createdAt;

  OlahragaModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.activityType,
    required this.description,
    required this.photoUrl,
    required this.startTime,
    required this.endTime,
    required this.date,
    required this.createdAt,
  });

  factory OlahragaModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return OlahragaModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      activityType: data['activityType'] ?? '',
      description: data['description'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      date: data['date'] ?? Timestamp.now(),
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'activityType': activityType,
      'description': description,
      'photoUrl': photoUrl,
      'startTime': startTime,
      'endTime': endTime,
      'date': date,
      'createdAt': createdAt,
    };
  }
}