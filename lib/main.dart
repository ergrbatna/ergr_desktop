import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'package:ergr_application/views/admin_panel_view.dart';
import 'package:ergr_application/views/login_view.dart';
import 'package:ergr_application/views/messages_view.dart';
import 'package:ergr_application/controllers/admin_panel_controller.dart';
import 'package:ergr_application/controllers/app_controller.dart';
import 'package:ergr_application/controllers/plants_controller.dart';
import 'package:ergr_application/controllers/places_controller.dart';
import 'package:ergr_application/controllers/history_controller.dart';
// import 'package:ergr_application/controllers/edit_plant_controller.dart';
// import 'package:ergr_application/controllers/edit_place_controller.dart';
import 'package:ergr_application/controllers/login_controller.dart';
import 'package:ergr_application/controllers/messages_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://jusznuslfjfnabaqnvqb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp1c3pudXNsZmpmbmFiYXFudnFiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc5OTYxNDAsImV4cCI6MjA2MzU3MjE0MH0.XNn7YlJXRniWF75UefUEA69_OaNmtj0D1Tz_Zcnv_2s',
  );

  // Initialize all controllers
  Get.put(LoginController(), permanent: true);
  Get.put(AdminPanelController(), permanent: true);
  Get.put(PlantsController(), permanent: true);
  Get.put(PlacesController(), permanent: true);
  Get.put(AppController(), permanent: true);
  Get.put(HistoryController(), permanent: true);
  Get.put(MessagesController(), permanent: true);
  // Get.put(EditPlantController());
  // Get.put(EditPlaceController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Admin Panel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        useMaterial3: true,
      ),
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => LoginView()),
        GetPage(
          name: '/dashbored',
          page: () => AdminPanelView(),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<AdminPanelController>())
              Get.put(AdminPanelController());
            if (!Get.isRegistered<PlantsController>())
              Get.put(PlantsController());
            if (!Get.isRegistered<PlacesController>())
              Get.put(PlacesController());
            if (!Get.isRegistered<HistoryController>())
              Get.put(HistoryController());
            if (!Get.isRegistered<AppController>()) Get.put(AppController());
            if (!Get.isRegistered<MessagesController>())
              Get.put(MessagesController());
          }),
        ),
        GetPage(
          name: '/messages',
          page: () => MessagesView(),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<MessagesController>())
              Get.put(MessagesController());
          }),
        ),
      ],
      home: LoginView(),
    );
  }
}
