import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart'; // <-- Import this

import 'app/modules/auth/controllers/auth_controller.dart';
import 'app/services/admin_config_service.dart';
import 'app/routes/app_pages.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('id_ID', null); // <-- Add this line

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );  

  Get.put(AuthController(), permanent: true);
  Get.put(AdminConfigService(), permanent: true);

  runApp(
    GetMaterialApp(
      title: "E-BLBC",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    ),
  );
}