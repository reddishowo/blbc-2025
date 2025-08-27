import 'package:cloud_firestore/cloud_firestore.dart';

class LemburModel {
  final String id;
  final String activityType;
  final Timestamp date;
  final String startTime;
  final String endTime;
  final String photoUrl;
  final String userName;
  final String? description; // Add this line

  LemburModel({
    required this.id,
    required this.activityType,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.photoUrl,
    required this.userName,
    this.description,
  });

  // Factory constructor to create an instance from a Firestore document
  factory LemburModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return LemburModel(
      id: doc.id,
      activityType: data['activityType'] ?? 'N/A',
      // Ensure 'date' is handled correctly, it might be 'createdAt'
      date: data['createdAt'] ?? Timestamp.now(), 
      startTime: data['startTime'] ?? 'N/A',
      endTime: data['endTime'] ?? 'N/A',
      photoUrl: data['photoUrl'] ?? '',
      userName: data['userName'] ?? 'N/A',
      description: data['description'], // Map Firestore field to model
    );
  }
}