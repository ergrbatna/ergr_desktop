import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/plants_controller.dart';
import '../controllers/app_controller.dart';

class PlantsListView extends StatelessWidget {
  final PlantsController controller = Get.put(PlantsController());
  final AppController appController = Get.find<AppController>();
  final TextEditingController searchController = TextEditingController();

  PlantsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Bar with Title
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.purple,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Welcome Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Row(
              //   children: [
              //     // Refresh Button
              //     Obx(() => IconButton(
              //       icon: const Icon(Icons.refresh, color: Colors.white),
              //       onPressed: appController.isRefreshing.value
              //           ? null
              //           : () {
              //               appController.refreshAllData();
              //               Get.snackbar(
              //                 'Refresh',
              //                 'All data has been refreshed',
              //                 snackPosition: SnackPosition.BOTTOM,
              //                 backgroundColor: Colors.green,
              //                 colorText: Colors.white,
              //                 duration: const Duration(seconds: 2),
              //               );
              //             },
              //       tooltip: 'Refresh Data',
              //     )),
              //     const SizedBox(width: 16),
              //     // Logout Button
              //     TextButton.icon(
              //       icon: const Icon(Icons.logout, color: Colors.white),
              //       label: const Text(
              //         'LogOut',
              //         style: TextStyle(color: Colors.white),
              //       ),
              //       onPressed: () {
              //         // Implement logout functionality
              //       },
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search Plants',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onChanged: controller.updateSearchQuery,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () => controller.fetchPlants(),
                child: const Text(
                  'Search',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        // Plants Table
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.error.value.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Erreur: ${controller.error.value}',
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => controller.fetchPlants(),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              );
            }

            final plants = controller.filteredPlants;

            if (plants.isEmpty) {
              return const Center(child: Text('Aucune plante trouvée'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Table(
                border: TableBorder.all(
                  color: Colors.grey.shade300,
                ),
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(2),
                },
                children: [
                  const TableRow(
                    decoration: BoxDecoration(
                      color: Colors.purple,
                    ),
                    children: [
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Plant ID',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Plant Name',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ...plants.map((plant) => TableRow(
                        children: [
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('P${plant.id}'),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(plant.name),
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}
