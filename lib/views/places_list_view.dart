import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/places_controller.dart';
import '../controllers/app_controller.dart';

class PlacesListView extends StatelessWidget {
  PlacesListView({super.key});

  final PlacesController controller = Get.find<PlacesController>();
  final AppController appController = Get.find<AppController>();
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Bar
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.purple,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Places List',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Refresh Button
              // Obx(() => IconButton(
              //       icon: const Icon(Icons.refresh, color: Colors.white),
              //       onPressed: appController.isRefreshing.value
              //           ? null
              //           : () {
              //               appController.refreshAllData();
              //               Get.snackbar(
              //                 'Refresh',
              //                 'Places list has been refreshed',
              //                 snackPosition: SnackPosition.BOTTOM,
              //                 backgroundColor: Colors.green,
              //                 colorText: Colors.white,
              //               );
              //             },
              //       tooltip: 'Refresh Places',
              //     )),
            ],
          ),
        ),
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: searchController,
            onChanged: (value) => controller.searchQuery.value = value,
            decoration: InputDecoration(
              hintText: 'Rechercher des lieux...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
        // Places List
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
                      onPressed: () => controller.fetchPlaces(),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              );
            }

            final places = controller.filteredPlaces;

            if (places.isEmpty) {
              return const Center(
                child: Text('Aucun lieu trouvé'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: places.length,
              itemBuilder: (context, index) {
                final place = places[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.place, color: Colors.purple),
                    title: Text(place.wilaya),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dayra: ${place.dayra}'),
                        Text('Baladya: ${place.baladya}'),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
