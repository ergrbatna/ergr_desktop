import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/history_controller.dart';
import 'package:intl/intl.dart';
import 'package:file_selector/file_selector.dart';

class HistoryView extends StatelessWidget {
  HistoryView({super.key});

  final HistoryController controller = Get.find<HistoryController>();
  final ScrollController verticalScrollController = ScrollController();
  final ScrollController horizontalScrollController = ScrollController();
  final ScrollController filterScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.purple,
          child: Row(
            children: [
              const Text(
                'Historique',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // Export Excel Button
              IconButton(
                icon: const Icon(
                  Icons.file_download_sharp,
                  color: Colors.white,
                ),
                tooltip: 'Exporter vers Excel',
                onPressed: () async {
                  final filePath = await controller.exportToExcelWithDialog();
                  if (filePath != null) {
                    Get.snackbar(
                      'Succès',
                      'Fichier Excel exporté avec succès: $filePath',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  } else {
                    Get.snackbar(
                      'Erreur',
                      'Erreur lors de l\'exportation du fichier Excel',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
              ),
              // const SizedBox(width: 16),
              // // Print Button
              // ElevatedButton.icon(
              //   onPressed: () {},
              //   icon: const Icon(Icons.print, color: Colors.purple),
              //   label: const Text(
              //     'Imprimer',
              //     style: TextStyle(color: Colors.purple),
              //   ),
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Colors.white,
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(30),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 7,
                child: GetX<HistoryController>(
                    init: controller,
                    builder: (controller) {
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
                                onPressed: () => controller.fetchHistory(),
                                child: const Text('Réessayer'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (controller.history.isEmpty) {
                        return const Center(
                            child: Text('Aucun historique trouvé'));
                      }

                      return SingleChildScrollView(
                        controller: verticalScrollController,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          controller: horizontalScrollController,
                          child: DataTable(
                            headingRowColor:
                                WidgetStateProperty.all(Colors.grey[200]),
                            columns: const [
                              DataColumn(
                                label: Text(
                                  'Nom de la Plante',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Quantité',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Espace',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Wilaya',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Dayra',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Baladia',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Créé par',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Date',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                            rows: controller.history.map((record) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(record.plantName)),
                                  DataCell(Text(record.quantity)),
                                  DataCell(Text(record.space)),
                                  DataCell(Text(record.wilaya)),
                                  DataCell(Text(record.dayra)),
                                  DataCell(Text(record.baladya)),
                                  DataCell(Text(record.createdBy)),
                                  DataCell(
                                      Text(controller.formatDate(record.date))),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    }),
              ),
              Container(
                width: 300,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Scrollbar(
                  thumbVisibility: true,
                  trackVisibility: true,
                  controller: filterScrollController,
                  child: SingleChildScrollView(
                    controller: filterScrollController,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Filtres',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Obx(() => DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Créé par',
                                prefixIcon: const Icon(Icons.person),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              value: controller.selectedCreatedBy.value,
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('Tous les Utilisateurs'),
                                ),
                                ...controller.createdByUsers.map((user) {
                                  return DropdownMenuItem(
                                    value: user,
                                    child: Text(user),
                                  );
                                }).toList(),
                              ],
                              onChanged: (value) {
                                controller.selectedCreatedBy.value = value;
                              },
                            )),
                        const SizedBox(height: 16),
                        Obx(() => DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Nom de la Plante',
                                prefixIcon: const Icon(Icons.local_florist),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              value: controller.selectedPlantName.value,
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('Toutes les Plantes'),
                                ),
                                ...controller.plantNames.map((plant) {
                                  return DropdownMenuItem(
                                    value: plant,
                                    child: Text(plant),
                                  );
                                }).toList(),
                              ],
                              onChanged: (value) {
                                controller.selectedPlantName.value = value;
                              },
                            )),
                        const SizedBox(height: 24),
                        const Text(
                          'Emplacement',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Obx(() => DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Wilaya',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              value: controller.selectedWilaya.value,
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('Sélectionner Wilaya'),
                                ),
                                ...controller.wilayas.map((wilaya) {
                                  return DropdownMenuItem<String>(
                                    value: wilaya,
                                    child: Text(wilaya),
                                  );
                                }).toList(),
                              ],
                              onChanged: (value) {
                                controller.selectedWilaya.value = value;
                              },
                            )),
                        const SizedBox(height: 16),
                        Obx(() => DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Dayra',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              value: controller.selectedDayra.value,
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('Sélectionner Dayra'),
                                ),
                                ...controller.dayras.map((dayra) {
                                  return DropdownMenuItem<String>(
                                    value: dayra,
                                    child: Text(dayra),
                                  );
                                }).toList(),
                              ],
                              onChanged: (value) {
                                controller.selectedDayra.value = value;
                              },
                            )),
                        const SizedBox(height: 16),
                        Obx(() => DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Baladia',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              value: controller.selectedBaladia.value,
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('Sélectionner Baladia'),
                                ),
                                ...controller.baladias.map((baladia) {
                                  return DropdownMenuItem<String>(
                                    value: baladia,
                                    child: Text(baladia),
                                  );
                                }).toList(),
                              ],
                              onChanged: (value) {
                                controller.selectedBaladia.value = value;
                              },
                            )),
                        const SizedBox(height: 24),
                        const Text(
                          'Période',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Obx(() => TextField(
                              decoration: InputDecoration(
                                labelText: 'Start Date',
                                prefixIcon: const Icon(Icons.calendar_today),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                suffixIcon:
                                    controller.selectedStartDate.value != null
                                        ? IconButton(
                                            icon: const Icon(Icons.clear),
                                            onPressed: () {
                                              controller.setDateRange(
                                                  null,
                                                  controller
                                                      .selectedEndDate.value);
                                            },
                                          )
                                        : null,
                              ),
                              readOnly: true,
                              controller: TextEditingController(
                                text: controller.selectedStartDate.value != null
                                    ? DateFormat('yyyy-MM-dd').format(
                                        controller.selectedStartDate.value!)
                                    : '',
                              ),
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      controller.selectedStartDate.value ??
                                          DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  controller.setDateRange(
                                      picked, controller.selectedEndDate.value);
                                }
                              },
                            )),
                        const SizedBox(height: 16),
                        Obx(() => TextField(
                              decoration: InputDecoration(
                                labelText: 'End Date',
                                prefixIcon: const Icon(Icons.calendar_today),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                suffixIcon:
                                    controller.selectedEndDate.value != null
                                        ? IconButton(
                                            icon: const Icon(Icons.clear),
                                            onPressed: () {
                                              controller.setDateRange(
                                                  controller
                                                      .selectedStartDate.value,
                                                  null);
                                            },
                                          )
                                        : null,
                              ),
                              readOnly: true,
                              controller: TextEditingController(
                                text: controller.selectedEndDate.value != null
                                    ? DateFormat('yyyy-MM-dd').format(
                                        controller.selectedEndDate.value!)
                                    : '',
                              ),
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      controller.selectedEndDate.value ??
                                          DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  controller.setDateRange(
                                      controller.selectedStartDate.value,
                                      picked);
                                }
                              },
                            )),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.filter_list),
                            label: const Text('Apply Filters'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              controller.applyFilters();
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            icon: const Icon(Icons.clear),
                            label: const Text('Clear Filters'),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () {
                              controller.clearFilters();
                            },
                          ),
                        ),
                        // Add floating refresh button
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: FloatingActionButton(
                              heroTag: 'history_refresh',
                              backgroundColor: Colors.purple,
                              child: const Icon(Icons.refresh,
                                  color: Colors.white),
                              onPressed: () {
                                controller.fetchHistory();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
