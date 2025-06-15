import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? additionalActions;
  final bool showLogoutButton;
  final double height;

  const CustomAppBar({
    super.key,
    required this.title,
    this.additionalActions,
    this.showLogoutButton = false,
    this.height = 60.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: Colors.purple,
      child: AppBar(
        toolbarHeight: height,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (additionalActions != null) ...additionalActions!,
          if (showLogoutButton) ...[
            const SizedBox(width: 8),
            TextButton.icon(
              icon: const Icon(
                Icons.logout,
                color: Colors.white,
              ),
              label: const Text(
                'Déconnexion',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Get.dialog(
                  AlertDialog(
                    title: const Text('Déconnexion'),
                    content: const Text(
                        'Êtes-vous sûr de vouloir vous déconnecter ?'),
                    actions: [
                      TextButton(
                        child: const Text('Annuler'),
                        onPressed: () => Get.back(),
                      ),
                      TextButton(
                        child: const Text('Déconnexion'),
                        onPressed: () {
                          Get.back();
                          Get.find<LoginController>().logout();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
