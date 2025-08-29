import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';

class DataExtractionController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final RxList<Map<String, dynamic>> allUsers = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllUsers();
  }

  Future<void> loadAllUsers() async {
    try {
      isLoading.value = true;
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      
      allUsers.clear();
      for (var doc in snapshot.docs) {
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
        userData['uid'] = doc.id;
        allUsers.add(userData);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load users: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void showExtractDialog(Map<String, dynamic> user) {
    Get.dialog(
      AlertDialog(
        title: Text('Extract Data for ${user['name'] ?? 'Unknown User'}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildExtractButton('Extract Lembur', () => extractLembur(user)),
            _buildExtractButton('Extract Presensi', () => extractPresensi(user)),
            _buildExtractButton('Extract Olahraga', () => extractOlahraga(user)),
            _buildExtractButton('Extract Kegiatan', () => extractKegiatan(user)),
            _buildExtractButton('Extract Prestasi', () => extractPrestasi(user)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildExtractButton(String title, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        onPressed: () {
          Get.back(); // Close dialog
          onPressed();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
        ),
        child: Text(title),
      ),
    );
  }

  Future<void> extractLembur(Map<String, dynamic> user) async {
    try {
      isLoading.value = true;
      QuerySnapshot snapshot = await _firestore
          .collection('lembur')
          .where('userId', isEqualTo: user['uid'])
          .get();

      List<List<String>> excelData = [
        ['Date', 'Start Time', 'End Time', 'Activity', 'User Name']
      ];

      print('Lembur data count: ${snapshot.docs.length}');
      
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print('Lembur doc data: $data');
        
        // Handle date conversion properly
        String tanggal = '';
        if (data['date'] != null) {
          if (data['date'] is Timestamp) {
            tanggal = DateFormat('yyyy-MM-dd').format((data['date'] as Timestamp).toDate());
          } else {
            tanggal = data['date'].toString();
          }
        } else if (data['createdAt'] != null) {
          if (data['createdAt'] is Timestamp) {
            tanggal = DateFormat('yyyy-MM-dd').format((data['createdAt'] as Timestamp).toDate());
          } else {
            tanggal = data['createdAt'].toString();
          }
        }
        
        excelData.add([
          tanggal,
          data['startTime']?.toString() ?? '',
          data['endTime']?.toString() ?? '',
          data['activityType']?.toString() ?? '',
          data['userName']?.toString() ?? '',
        ]);
      }

      await _createAndOpenExcel('Lembur_${user['name']?.toString().replaceAll(' ', '_') ?? 'User'}.xlsx', 'Lembur Data', excelData);
    } catch (e) {
      Get.snackbar('Error', 'Failed to extract lembur data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> extractPresensi(Map<String, dynamic> user) async {
    try {
      isLoading.value = true;
      QuerySnapshot snapshot = await _firestore
          .collection('presensi')
          .where('userId', isEqualTo: user['uid'])
          .get();

      List<List<String>> excelData = [
        ['User Name', 'Date/Time', 'Kehadiran', 'Keterangan', 'Location']
      ];

      print('Presensi data count: ${snapshot.docs.length}');

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print('Presensi doc data: $data');
        
        // Handle date conversion properly
        String dateTime = '';
        if (data['time'] != null) {
          if (data['time'] is Timestamp) {
            dateTime = DateFormat('yyyy-MM-dd HH:mm').format((data['time'] as Timestamp).toDate());
          } else {
            dateTime = data['time'].toString();
          }
        } else if (data['createdAt'] != null) {
          if (data['createdAt'] is Timestamp) {
            dateTime = DateFormat('yyyy-MM-dd HH:mm').format((data['createdAt'] as Timestamp).toDate());
          } else {
            dateTime = data['createdAt'].toString();
          }
        }
        
        excelData.add([
          data['nama']?.toString() ?? '',
          dateTime,
          data['kehadiran']?.toString() ?? '',
          data['keterangan']?.toString() ?? '',
          data['location']?.toString() ?? '',
        ]);
      }

      await _createAndOpenExcel('Presensi_${user['name']?.toString().replaceAll(' ', '_') ?? 'User'}.xlsx', 'Presensi Data', excelData);
    } catch (e) {
      Get.snackbar('Error', 'Failed to extract presensi data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> extractOlahraga(Map<String, dynamic> user) async {
    try {
      isLoading.value = true;
      QuerySnapshot snapshot = await _firestore
          .collection('olahraga')
          .where('userId', isEqualTo: user['uid'])
          .get();

      List<List<String>> excelData = [
        ['Date', 'Activity Type', 'Start Time', 'End Time', 'Description', 'User Name']
      ];

      print('Olahraga data count: ${snapshot.docs.length}');

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print('Olahraga doc data: $data');
        
        // Handle date conversion properly
        String tanggal = '';
        if (data['date'] != null) {
          if (data['date'] is Timestamp) {
            tanggal = DateFormat('yyyy-MM-dd').format((data['date'] as Timestamp).toDate());
          } else {
            tanggal = data['date'].toString();
          }
        } else if (data['createdAt'] != null) {
          if (data['createdAt'] is Timestamp) {
            tanggal = DateFormat('yyyy-MM-dd').format((data['createdAt'] as Timestamp).toDate());
          } else {
            tanggal = data['createdAt'].toString();
          }
        }
        
        excelData.add([
          tanggal,
          data['activityType']?.toString() ?? '',
          data['startTime']?.toString() ?? '',
          data['endTime']?.toString() ?? '',
          data['description']?.toString() ?? '',
          data['userName']?.toString() ?? '',
        ]);
      }

      await _createAndOpenExcel('Olahraga_${user['name']?.toString().replaceAll(' ', '_') ?? 'User'}.xlsx', 'Olahraga Data', excelData);
    } catch (e) {
      Get.snackbar('Error', 'Failed to extract olahraga data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> extractKegiatan(Map<String, dynamic> user) async {
    try {
      isLoading.value = true;
      QuerySnapshot snapshot = await _firestore
          .collection('kegiatan')
          .where('userId', isEqualTo: user['uid'])
          .get();

      List<List<String>> excelData = [
        ['Date', 'Activity Name', 'User Name', 'Document Name']
      ];

      print('Kegiatan data count: ${snapshot.docs.length}');

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print('Kegiatan doc data: $data');
        
        // Handle date conversion properly
        String tanggal = '';
        if (data['date'] != null) {
          if (data['date'] is Timestamp) {
            tanggal = DateFormat('yyyy-MM-dd').format((data['date'] as Timestamp).toDate());
          } else {
            tanggal = data['date'].toString();
          }
        } else if (data['createdAt'] != null) {
          if (data['createdAt'] is Timestamp) {
            tanggal = DateFormat('yyyy-MM-dd').format((data['createdAt'] as Timestamp).toDate());
          } else {
            tanggal = data['createdAt'].toString();
          }
        }
        
        excelData.add([
          tanggal,
          data['activityName']?.toString() ?? '',
          data['userName']?.toString() ?? '',
          data['documentName']?.toString() ?? '',
        ]);
      }

      await _createAndOpenExcel('Kegiatan_${user['name']?.toString().replaceAll(' ', '_') ?? 'User'}.xlsx', 'Kegiatan Data', excelData);
    } catch (e) {
      Get.snackbar('Error', 'Failed to extract kegiatan data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> extractPrestasi(Map<String, dynamic> user) async {
    try {
      isLoading.value = true;
      QuerySnapshot snapshot = await _firestore
          .collection('prestasi')
          .where('userId', isEqualTo: user['uid'])
          .get();

      List<List<String>> excelData = [
        ['Date', 'Achievement Name', 'Recipient Name', 'Position', 'Giver Name', 'Certificate Number', 'Document Name']
      ];

      print('Prestasi data count: ${snapshot.docs.length}');

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print('Prestasi doc data: $data');
        
        // Handle date conversion properly
        String tanggal = '';
        if (data['createdAt'] != null) {
          if (data['createdAt'] is Timestamp) {
            tanggal = DateFormat('yyyy-MM-dd').format((data['createdAt'] as Timestamp).toDate());
          } else {
            tanggal = data['createdAt'].toString();
          }
        }
        
        excelData.add([
          tanggal,
          data['namaPrestasi']?.toString() ?? '',
          data['recipientName']?.toString() ?? '',
          data['jabatanPemberi']?.toString() ?? '',
          data['namaPemberi']?.toString() ?? '',
          data['nomorSertifikat']?.toString() ?? '',
          data['buktiFileName']?.toString() ?? '',
        ]);
      }

      await _createAndOpenExcel('Prestasi_${user['name']?.toString().replaceAll(' ', '_') ?? 'User'}.xlsx', 'Prestasi Data', excelData);
    } catch (e) {
      Get.snackbar('Error', 'Failed to extract prestasi data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _createAndOpenExcel(String fileName, String sheetName, List<List<String>> data) async {
    try {
      print('Creating Excel with ${data.length} rows (including header)');
      for (int i = 0; i < data.length && i < 5; i++) {
        print('Row $i: ${data[i]}');
      }
      
      if (data.length <= 1) {
        Get.snackbar('Info', 'No data found for this user');
        return;
      }

      // Create Excel workbook
      var excel = Excel.createExcel();
      Sheet sheetObject = excel[sheetName];
      
      // Delete default sheet if it exists
      if (excel.tables.containsKey('Sheet1')) {
        excel.delete('Sheet1');
      }

      // Add data to sheet with formatting
      for (int rowIndex = 0; rowIndex < data.length; rowIndex++) {
        List<String> row = data[rowIndex];
        for (int colIndex = 0; colIndex < row.length; colIndex++) {
          var cell = sheetObject.cell(CellIndex.indexByColumnRow(
            columnIndex: colIndex,
            rowIndex: rowIndex,
          ));
          cell.value = TextCellValue(row[colIndex]);
          
          // Format header row
          if (rowIndex == 0) {
            cell.cellStyle = CellStyle(
              backgroundColorHex: ExcelColor.blue,
              fontColorHex: ExcelColor.white,
              bold: true,
            );
          }
        }
      }

      // Auto fit columns
      for (int i = 0; i < data[0].length; i++) {
        sheetObject.setColumnAutoFit(i);
      }

      // Get app documents directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        Get.snackbar('Error', 'Could not access storage');
        return;
      }

      // Create file path
      String filePath = '${directory.path}/$fileName';
      File file = File(filePath);

      // Save Excel file
      List<int>? fileBytes = excel.save();
      if (fileBytes != null) {
        await file.writeAsBytes(fileBytes);
        
        // Show success message
        Get.snackbar(
          'Success', 
          'Excel file created: $fileName\nSaved to: ${directory.path}',
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Open the file
        try {
          OpenResult result = await OpenFile.open(filePath);
          if (result.type != ResultType.done) {
            Get.snackbar(
              'Info', 
              'File saved but could not open automatically. Please check: ${directory.path}',
              duration: const Duration(seconds: 4),
            );
          }
        } catch (e) {
          Get.snackbar(
            'Info', 
            'File saved but could not open automatically: ${directory.path}',
            duration: const Duration(seconds: 4),
          );
        }
      } else {
        Get.snackbar('Error', 'Failed to generate Excel file');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create Excel file: $e');
    }
  }

  Future<void> refreshData() async {
    await loadAllUsers();
  }

  // Extract all data methods
  Future<void> extractAllLembur() async {
    try {
      isLoading.value = true;
      QuerySnapshot snapshot = await _firestore.collection('lembur').get();

      List<List<String>> excelData = [
        ['User Name', 'Activity Type', 'Date', 'Start Time', 'End Time']
      ];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        // Get user name from users collection
        String userName = 'Unknown User';
        try {
          DocumentSnapshot userDoc = await _firestore
              .collection('users')
              .doc(data['userId'])
              .get();
          if (userDoc.exists) {
            userName = (userDoc.data() as Map<String, dynamic>)['name'] ?? 'Unknown User';
          }
        } catch (e) {
          userName = data['userName'] ?? 'Unknown User';
        }

        String formattedDate = '';
        if (data['date'] != null) {
          try {
            if (data['date'] is Timestamp) {
              formattedDate = DateFormat('dd/MM/yyyy').format((data['date'] as Timestamp).toDate());
            } else {
              formattedDate = data['date'].toString();
            }
          } catch (e) {
            formattedDate = data['date'].toString();
          }
        }

        excelData.add([
          userName,
          data['activityType']?.toString() ?? '',
          formattedDate,
          data['startTime']?.toString() ?? '',
          data['endTime']?.toString() ?? '',
        ]);
      }

      await _createAndOpenExcel('All_Lembur_Data_${DateTime.now().millisecondsSinceEpoch}.xlsx', 'All Lembur Data', excelData);
    } catch (e) {
      Get.snackbar('Error', 'Failed to extract all lembur data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> extractAllPresensi() async {
    try {
      isLoading.value = true;
      QuerySnapshot snapshot = await _firestore.collection('presensi').get();

      List<List<String>> excelData = [
        ['User Name', 'Kehadiran', 'Date', 'Location', 'Keterangan']
      ];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        String userName = 'Unknown User';
        try {
          DocumentSnapshot userDoc = await _firestore
              .collection('users')
              .doc(data['userId'])
              .get();
          if (userDoc.exists) {
            userName = (userDoc.data() as Map<String, dynamic>)['name'] ?? 'Unknown User';
          }
        } catch (e) {
          userName = data['nama'] ?? 'Unknown User';
        }

        String formattedTime = '';
        if (data['time'] != null) {
          try {
            if (data['time'] is Timestamp) {
              formattedTime = DateFormat('dd/MM/yyyy').format((data['time'] as Timestamp).toDate());
            } else {
              formattedTime = data['time'].toString();
            }
          } catch (e) {
            formattedTime = data['time'].toString();
          }
        }

        excelData.add([
          userName,
          data['kehadiran']?.toString() ?? '',
          formattedTime,
          data['location']?.toString() ?? '',
          data['keterangan']?.toString() ?? '',
        ]);
      }

      await _createAndOpenExcel('All_Presensi_Data_${DateTime.now().millisecondsSinceEpoch}.xlsx', 'All Presensi Data', excelData);
    } catch (e) {
      Get.snackbar('Error', 'Failed to extract all presensi data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> extractAllOlahraga() async {
    try {
      isLoading.value = true;
      QuerySnapshot snapshot = await _firestore.collection('olahraga').get();

      List<List<String>> excelData = [
        ['User Name', 'Activity Type', 'Date', 'Start Time', 'End Time', 'Description']
      ];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        String userName = 'Unknown User';
        try {
          DocumentSnapshot userDoc = await _firestore
              .collection('users')
              .doc(data['userId'])
              .get();
          if (userDoc.exists) {
            userName = (userDoc.data() as Map<String, dynamic>)['name'] ?? 'Unknown User';
          }
        } catch (e) {
          userName = data['userName'] ?? 'Unknown User';
        }

        String formattedDate = '';
        if (data['date'] != null) {
          try {
            if (data['date'] is Timestamp) {
              formattedDate = DateFormat('dd/MM/yyyy').format((data['date'] as Timestamp).toDate());
            } else {
              formattedDate = data['date'].toString();
            }
          } catch (e) {
            formattedDate = data['date'].toString();
          }
        }

        excelData.add([
          userName,
          data['activityType']?.toString() ?? '',
          formattedDate,
          data['startTime']?.toString() ?? '',
          data['endTime']?.toString() ?? '',
          data['description']?.toString() ?? '',
        ]);
      }

      await _createAndOpenExcel('All_Olahraga_Data_${DateTime.now().millisecondsSinceEpoch}.xlsx', 'All Olahraga Data', excelData);
    } catch (e) {
      Get.snackbar('Error', 'Failed to extract all olahraga data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> extractAllKegiatan() async {
    try {
      isLoading.value = true;
      QuerySnapshot snapshot = await _firestore.collection('kegiatan').get();

      List<List<String>> excelData = [
        ['User Name', 'Activity Name', 'Date', 'Document Name']
      ];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        String userName = 'Unknown User';
        try {
          DocumentSnapshot userDoc = await _firestore
              .collection('users')
              .doc(data['userId'])
              .get();
          if (userDoc.exists) {
            userName = (userDoc.data() as Map<String, dynamic>)['name'] ?? 'Unknown User';
          }
        } catch (e) {
          userName = data['userName'] ?? 'Unknown User';
        }

        String formattedDate = '';
        if (data['date'] != null) {
          try {
            if (data['date'] is Timestamp) {
              formattedDate = DateFormat('dd/MM/yyyy').format((data['date'] as Timestamp).toDate());
            } else {
              formattedDate = data['date'].toString();
            }
          } catch (e) {
            formattedDate = data['date'].toString();
          }
        }

        excelData.add([
          userName,
          data['activityName']?.toString() ?? '',
          formattedDate,
          data['documentName']?.toString() ?? '',
        ]);
      }

      await _createAndOpenExcel('All_Kegiatan_Data_${DateTime.now().millisecondsSinceEpoch}.xlsx', 'All Kegiatan Data', excelData);
    } catch (e) {
      Get.snackbar('Error', 'Failed to extract all kegiatan data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> extractAllPrestasi() async {
    try {
      isLoading.value = true;
      QuerySnapshot snapshot = await _firestore.collection('prestasi').get();

      List<List<String>> excelData = [
        ['User Name', 'Recipient Name', 'Achievement Name', 'Giver Position', 'Giver Name', 'Certificate Number']
      ];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        String userName = 'Unknown User';
        try {
          DocumentSnapshot userDoc = await _firestore
              .collection('users')
              .doc(data['userId'])
              .get();
          if (userDoc.exists) {
            userName = (userDoc.data() as Map<String, dynamic>)['name'] ?? 'Unknown User';
          }
        } catch (e) {
          userName = data['nama'] ?? 'Unknown User';
        }

        excelData.add([
          userName,
          data['recipientName']?.toString() ?? '',
          data['namaPrestasi']?.toString() ?? '',
          data['jabatanPemberi']?.toString() ?? '',
          data['namaPemberi']?.toString() ?? '',
          data['nomorSertifikat']?.toString() ?? '',
        ]);
      }

      await _createAndOpenExcel('All_Prestasi_Data_${DateTime.now().millisecondsSinceEpoch}.xlsx', 'All Prestasi Data', excelData);
    } catch (e) {
      Get.snackbar('Error', 'Failed to extract all prestasi data: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
