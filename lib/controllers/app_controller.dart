import 'dart:async';
import 'package:ergr_application/controllers/admin_panel_controller.dart';
import 'package:ergr_application/controllers/plants_controller.dart';
import 'package:get/get.dart';

class AppController extends GetxController {
  Timer? _refreshTimer;
  final RxBool isRefreshing = false.obs;

  @override
  void onInit() {
    super.onInit();
    startRefreshTimer();
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }

  void startRefreshTimer() {
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) => refreshAllData());
  }

  Future<void> refreshAllData() async {
    isRefreshing.value = true;
    
    try {
      // Refresh all controllers' data
      if (Get.isRegistered<PlantsController>()) {
        await Get.find<PlantsController>().fetchPlants();
      }
      
      if (Get.isRegistered<AdminPanelController>()) {
        await Get.find<AdminPanelController>().fetchEmployees();
      }
      
      // Add more controllers' refresh methods here as needed
      
    } finally {
      isRefreshing.value = false;
    }
  }
} 