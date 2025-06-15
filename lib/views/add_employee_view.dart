import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_panel_controller.dart';

class AddEmployeeView extends StatelessWidget {
  AddEmployeeView({super.key});

  final AdminPanelController controller = Get.find<AdminPanelController>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final RxString nameError = ''.obs;
  final RxString emailError = ''.obs;
  final RxString phoneError = ''.obs;
  final RxString passwordError = ''.obs;
  final RxString confirmPasswordError = ''.obs;

  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  final RxBool isAdmin = false.obs;

  void validateName() {
    if (nameController.text.trim().isEmpty) {
      nameError.value = 'Nom complet est requis';
    } else {
      nameError.value = '';
    }
  }

  void validateEmail() {
    if (!controller.isValidEmail(emailController.text.trim())) {
      emailError.value = 'Format email invalide';
    } else {
      emailError.value = '';
    }
  }

  void validatePhone() {
    if (!controller.isValidAlgerianPhone(phoneController.text.trim())) {
      phoneError.value = 'Format numéro de téléphone invalide (ex: 0512345678)';
    } else {
      phoneError.value = '';
    }
  }

  void validatePasswords() {
    if (passwordController.text.isEmpty) {
      passwordError.value = 'Mot de passe requis';
    } else {
      passwordError.value = '';
    }

    if (confirmPasswordController.text != passwordController.text) {
      confirmPasswordError.value = 'Les mots de passe ne correspondent pas';
    } else {
      confirmPasswordError.value = '';
    }
  }

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
                'Ajouter Nouveau Employé',
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
            child: SingleChildScrollView(
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
                          Icons.person_add,
                          size: 64,
                          color: Colors.purple,
                        ),
                        const SizedBox(height: 24),
                        Obx(() => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: nameController,
                                  onChanged: (_) => validateName(),
                                  decoration: InputDecoration(
                                    labelText: 'Nom Complet',
                                    hintText: 'Entrez le nom complet',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    prefixIcon: const Icon(Icons.person),
                                    errorText: nameError.value.isEmpty
                                        ? null
                                        : nameError.value,
                                  ),
                                ),
                              ],
                            )),
                        const SizedBox(height: 16),
                        Obx(() => TextField(
                              controller: emailController,
                              onChanged: (_) => validateEmail(),
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                hintText: 'Entrez l\'adresse email',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.email),
                                errorText: emailError.value.isEmpty
                                    ? null
                                    : emailError.value,
                              ),
                            )),
                        const SizedBox(height: 16),
                        Obx(() => TextField(
                              controller: phoneController,
                              onChanged: (_) => validatePhone(),
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: 'Téléphone',
                                hintText:
                                    'Entrez le numéro de téléphone (ex: 0512345678)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.phone),
                                errorText: phoneError.value.isEmpty
                                    ? null
                                    : phoneError.value,
                              ),
                            )),
                        const SizedBox(height: 16),
                        Obx(() => TextField(
                              controller: passwordController,
                              onChanged: (_) => validatePasswords(),
                              obscureText: !isPasswordVisible.value,
                              decoration: InputDecoration(
                                labelText: 'Mot de passe',
                                hintText: 'Entrez le mot de passe',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isPasswordVisible.value
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () => isPasswordVisible.value =
                                      !isPasswordVisible.value,
                                ),
                                errorText: passwordError.value.isEmpty
                                    ? null
                                    : passwordError.value,
                              ),
                            )),
                        const SizedBox(height: 16),
                        Obx(() => TextField(
                              controller: confirmPasswordController,
                              onChanged: (_) => validatePasswords(),
                              obscureText: !isConfirmPasswordVisible.value,
                              decoration: InputDecoration(
                                labelText: 'Confirmer le mot de passe',
                                hintText: 'Confirmez votre mot de passe',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isConfirmPasswordVisible.value
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () => isConfirmPasswordVisible
                                      .value = !isConfirmPasswordVisible.value,
                                ),
                                errorText: confirmPasswordError.value.isEmpty
                                    ? null
                                    : confirmPasswordError.value,
                              ),
                            )),
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
                              Obx(() => Row(
                                    children: [
                                      Expanded(
                                        child: RadioListTile<bool>(
                                          title: const Text('Employé Régulier'),
                                          value: false,
                                          groupValue: isAdmin.value,
                                          onChanged: (value) =>
                                              isAdmin.value = value!,
                                          contentPadding: EdgeInsets.zero,
                                          dense: true,
                                          activeColor: Colors.purple,
                                        ),
                                      ),
                                      Expanded(
                                        child: RadioListTile<bool>(
                                          title: const Text('Admin'),
                                          value: true,
                                          groupValue: isAdmin.value,
                                          onChanged: (value) =>
                                              isAdmin.value = value!,
                                          contentPadding: EdgeInsets.zero,
                                          dense: true,
                                          activeColor: Colors.purple,
                                        ),
                                      ),
                                    ],
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        Obx(() => ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : () async {
                                      validateName();
                                      validateEmail();
                                      validatePhone();
                                      validatePasswords();

                                      if (nameError.value.isNotEmpty ||
                                          emailError.value.isNotEmpty ||
                                          phoneError.value.isNotEmpty ||
                                          passwordError.value.isNotEmpty ||
                                          confirmPasswordError
                                              .value.isNotEmpty) {
                                        return;
                                      }

                                      final result =
                                          await controller.addEmployee(
                                        fullName: nameController.text.trim(),
                                        email: emailController.text.trim(),
                                        phone: phoneController.text.trim(),
                                        password: passwordController.text,
                                        isAdmin: isAdmin.value,
                                      );

                                      if (result == null) {
                                        Get.snackbar(
                                          'Succès',
                                          'Employé ajouté avec succès',
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.green,
                                          colorText: Colors.white,
                                        );
                                        nameController.clear();
                                        emailController.clear();
                                        phoneController.clear();
                                        passwordController.clear();
                                        confirmPasswordController.clear();
                                        isAdmin.value = false;
                                        nameError.value = '';
                                        emailError.value = '';
                                        phoneError.value = '';
                                        passwordError.value = '';
                                        confirmPasswordError.value = '';
                                      } else {
                                        if (result.contains('name')) {
                                          nameError.value = result;
                                        } else if (result.contains('email')) {
                                          emailError.value = result;
                                        } else if (result.contains('phone')) {
                                          phoneError.value = result;
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
                                      'Ajouter Employé',
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
        ),
      ],
    );
  }
}
