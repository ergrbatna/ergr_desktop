import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_panel_controller.dart';
import '../controllers/app_controller.dart';

class DeleteEmployeeView extends StatelessWidget {
  DeleteEmployeeView({super.key});

  final AdminPanelController controller = Get.find<AdminPanelController>();
  final AppController appController = Get.find<AppController>();
  final TextEditingController searchController = TextEditingController();
  final Map<String, RxBool> selectedActiveValues = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.purple,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delete Employees',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: searchController,
            onChanged: (value) => controller.searchQuery.value = value,
            decoration: InputDecoration(
              hintText: 'Search employees...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
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
                      onPressed: () => controller.fetchEmployees(),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              );
            }

            final employees = controller.filteredEmployees;

            if (employees.isEmpty) {
              return const Center(
                child: Text('Aucun employé trouvé'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: employees.length,
              itemBuilder: (context, index) {
                final employee = employees[index];
                final selectedActiveValue = selectedActiveValues.putIfAbsent(
                  employee.id, () => RxBool(employee.active),
                );

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.person, color: Colors.purple),
                    title: Text(employee.fullName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email: ${employee.email}'),
                        Text('Phone: 0${employee.phone}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Obx(() => Row(
                          children: [
                            Radio<bool>(
                              value: true,
                              groupValue: selectedActiveValue.value,
                              onChanged: (value) async {
                                selectedActiveValue.value = value!;
                                await controller.setEmployeeActiveStatus(employee.id, true);
                              },
                            ),
                            const Text('Actif'),
                            Radio<bool>(
                              value: false,
                              groupValue: selectedActiveValue.value,
                              onChanged: (value) async {
                                selectedActiveValue.value = value!;
                                await controller.setEmployeeActiveStatus(employee.id, false);
                              },
                            ),
                            const Text('Désactif'),
                          ],
                        )),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final hasHistory = await controller.employeeHasHistory(employee.id);

                            if (hasHistory) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Suppression impossible'),
                                  content: const Text(
                                    "Cet employé a un historique, vous ne pouvez pas le supprimer. Veuillez activer ou désactiver son compte à la place."
                                  ),
                                  actions: [
                                    TextButton(
                                      child: const Text('OK'),
                                      onPressed: () => Navigator.of(context).pop(),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }

                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirmer la suppression'),
                                content: const Text('Êtes-vous sûr de vouloir supprimer cet employé ?'),
                                actions: [
                                  TextButton(
                                    child: const Text('Annuler'),
                                    onPressed: () => Navigator.of(context).pop(false),
                                  ),
                                  TextButton(
                                    child: const Text('Supprimer'),
                                    onPressed: () => Navigator.of(context).pop(true),
                                  ),
                                ],
                              ),
                            );

                            if (confirm != true) return;

                            if (employee.isAdmin) {
                              final hasOtherAdmins = await controller.hasMultipleAdmins();
                              if (!hasOtherAdmins) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Suppression impossible'),
                                    content: const Text(
                                      "Vous ne pouvez pas supprimer le seul administrateur du système."
                                    ),
                                    actions: [
                                      TextButton(
                                        child: const Text('OK'),
                                        onPressed: () => Navigator.of(context).pop(),
                                      ),
                                    ],
                                  ),
                                );
                                return;
                              }
                            }

                            await controller.deleteEmployeeAndMessages(employee.id, employee.email);
                          },
                        ),
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
