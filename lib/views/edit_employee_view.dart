import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_panel_controller.dart';
import '../widgets/custom_app_bar.dart';

class EditEmployeeView extends StatefulWidget {
  const EditEmployeeView({super.key});

  @override
  State<EditEmployeeView> createState() => _EditEmployeeViewState();
}

class _EditEmployeeViewState extends State<EditEmployeeView> {
  final AdminPanelController controller = Get.find<AdminPanelController>();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? selectedEmployeeEmail;
  bool isEditing = false;
  bool isPasswordVisible = true; // Default to visible
  bool isAdmin = false;

  @override
  void dispose() {
    searchController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _clearForm() {
    fullNameController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
    setState(() {
      selectedEmployeeEmail = null;
      isEditing = false;
      isAdmin = false;
    });
  }

  Future<void> _loadEmployeeData(String email) async {
    final employee = await controller.getEmployeeByEmail(email);
    if (employee != null) {
      setState(() {
        selectedEmployeeEmail = email;
        fullNameController.text = employee.fullName;
        emailController.text = employee.email;
        phoneController.text = employee.phone.toString();
        passwordController.text = employee.password;
        isAdmin = employee.isAdmin;
        isEditing = true;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (selectedEmployeeEmail == null) return;

    final result = await controller.editEmployee(
      currentEmail: selectedEmployeeEmail!,
      newFullName: fullNameController.text,
      newEmail: emailController.text,
      newPhone: phoneController.text,
      newPassword: passwordController.text,
      isAdmin: isAdmin,
    );

    if (result == null) {
      Get.snackbar(
        'Succès',
        'Employé mis à jour avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      _clearForm();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Modifier Employé',
        additionalActions: [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText:
                                  'Rechercher un employé par nom ou email',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onChanged: controller.updateSearchQuery,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final employees = controller.filteredEmployees;

                        if (employees.isEmpty) {
                          return const Center(
                              child: Text('Aucun employé trouvé'));
                        }

                        return ListView.builder(
                          itemCount: employees.length,
                          itemBuilder: (context, index) {
                            final employee = employees[index];
                            return ListTile(
                              title: Text(employee.fullName),
                              subtitle: Text(employee.email),
                              selected: selectedEmployeeEmail == employee.email,
                              onTap: () => _loadEmployeeData(employee.email),
                            );
                          },
                        );
                      }),
                    ),
                    if (isEditing) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Modifier les Détails de l\'Employé',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: fullNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nom Complet',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Téléphone',
                          border: OutlineInputBorder(),
                          prefixText: '0',
                          prefixStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          hintText: 'Entrez le numéro de téléphone sans le 0',
                        ),
                        onChanged: (value) {
                          if (value.startsWith('0')) {
                            phoneController.text = value.substring(1);
                            phoneController.selection =
                                TextSelection.fromPosition(
                              TextPosition(offset: phoneController.text.length),
                            );
                          }
                        },
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        obscureText: !isPasswordVisible,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Statut Admin',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: RadioListTile<bool>(
                                    title: const Text('Employé Régulier'),
                                    value: false,
                                    groupValue: isAdmin,
                                    onChanged: (value) {
                                      setState(() {
                                        isAdmin = value!;
                                      });
                                    },
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                    activeColor: Colors.purple,
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<bool>(
                                    title: const Text('Admin'),
                                    value: true,
                                    groupValue: isAdmin,
                                    onChanged: (value) {
                                      setState(() {
                                        isAdmin = value!;
                                      });
                                    },
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                    activeColor: Colors.purple,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _clearForm,
                            child: const Text('Annuler'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            child: const Text('Enregistrer les Modifications'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
