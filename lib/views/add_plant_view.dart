import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/plants_controller.dart';

class AddPlantView extends StatelessWidget {
  AddPlantView({super.key});

  final PlantsController controller = Get.find<PlantsController>();
  final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(16),
        color: Colors.purple,
        child: const Row(
          children: [
            Text(
              'Add New Plant',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      Expanded(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_florist,
                      size: 64,
                      color: Colors.purple,
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nom de la Plante',
                        hintText: 'Entrez le nom de la plante',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.eco),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Obx(() => ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : () async {
                                  if (nameController.text.trim().isEmpty) {
                                    Get.snackbar(
                                      'Erreur',
                                      'Veuillez entrer un nom de plante',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );
                                    return;
                                  }
                                  await controller
                                      .addPlant(nameController.text.trim());
                                  nameController.clear();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: controller.isLoading.value
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  'Add Plant',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}
