import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/places_controller.dart';

class AddPlaceView extends StatelessWidget {
  AddPlaceView({super.key});

  final PlacesController controller = Get.find<PlacesController>();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController wilayaController = TextEditingController();
  final TextEditingController dayraController = TextEditingController();
  final TextEditingController baladyaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.purple,
          child: const Row(
            children: [
              Text(
                'Add New Place',
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: wilayaController,
                    decoration: const InputDecoration(
                      labelText: 'Wilaya',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer la wilaya';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: dayraController,
                    decoration: const InputDecoration(
                      labelText: 'Dayra',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.place),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer la dayra';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: baladyaController,
                    decoration: const InputDecoration(
                      labelText: 'Baladya',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer la baladya';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                final result = await controller.addPlace(
                                  wilaya: wilayaController.text,
                                  dayra: dayraController.text,
                                  baladya: baladyaController.text,
                                );

                                if (result == null) {
                                  wilayaController.clear();
                                  dayraController.clear();
                                  baladyaController.clear();
                                  Get.snackbar(
                                    'Succès',
                                    'Lieu ajouté avec succès',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                  );
                                } else {
                                  Get.snackbar(
                                    'Erreur',
                                    result,
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Add Place',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ))),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
