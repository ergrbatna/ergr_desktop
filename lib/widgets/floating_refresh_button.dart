import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/app_controller.dart';

class FloatingRefreshButton extends StatelessWidget {
  FloatingRefreshButton({Key? key}) : super(key: key);

  final AppController appController = Get.find<AppController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => FloatingActionButton(
      onPressed: appController.isRefreshing.value
          ? null
          : () async {
              try {
                await appController.refreshAllData();
                Get.snackbar(
                  'Success',
                  'Data refreshed successfully',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to refresh data',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
      backgroundColor: Colors.purple,
      child: appController.isRefreshing.value
          ? const CircularProgressIndicator(color: Colors.white)
          : const Icon(Icons.refresh, color: Colors.white),
    ));
  }
} 