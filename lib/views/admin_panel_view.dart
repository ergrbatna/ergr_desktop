import 'package:ergr_application/views/messages_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_panel_controller.dart';
import '../controllers/app_controller.dart';
import '../widgets/sidebar.dart';
import '../widgets/floating_refresh_button.dart';
import 'dashboard_view.dart';
import 'plants_list_view.dart';
import 'add_plant_view.dart';
import 'delete_plant_view.dart';
import 'add_employee_view.dart';
import 'delete_employee_view.dart';
import 'edit_employee_view.dart';
import 'places_list_view.dart';
import 'add_place_view.dart';
import 'delete_place_view.dart';
import 'history_view.dart';
import 'employee_list_view.dart';

class AdminPanelView extends StatelessWidget {
  AdminPanelView({super.key});

  final AdminPanelController controller = Get.find<AdminPanelController>();
  final AppController appController = Get.find<AppController>();

  Widget _getSelectedView(int index) {
    switch (index) {
      case 0: // Dashboard
        return DashboardView();
      case 1: // Employee List
        return EmployeeListView();
      case 2: // Add Employee
        return AddEmployeeView();
      case 3: // Delete Employee
        return DeleteEmployeeView();
      case 4: // Edit Employee
        return const EditEmployeeView();
      case 5: // Plants List
        return PlantsListView();
      case 6: // Add Plant
        return AddPlantView();
      case 7: // Delete Plant
        return DeletePlantView();
      case 8: // Places List
        return PlacesListView();
      case 9: // Add Place
        return AddPlaceView();
      case 10: // Delete Place
        return DeletePlaceView();
      case 11: // Messages
        return const MessagesView();
      case 12: // History
        return HistoryView();
      default:
        return const Center(child: Text('Select an option from the sidebar'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Obx(() => Sidebar(
                selectedIndex: controller.selectedIndex.value,
                onItemSelected: (index) {
                  controller.selectedIndex.value = index;
                },
              )),
          Expanded(
            child: Obx(() => _getSelectedView(controller.selectedIndex.value)),
          ),
        ],
      ),
      // floatingActionButton: Obx(() =>
      // controller.selectedIndex.value != 11 ? FloatingRefreshButton() : Container(),
      // ),
    );
  }
}
