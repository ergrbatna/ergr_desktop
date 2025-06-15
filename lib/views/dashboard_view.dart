import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_panel_controller.dart';
import '../widgets/custom_app_bar.dart';

class DashboardView extends StatelessWidget {
  DashboardView({super.key});

  final AdminPanelController controller = Get.find<AdminPanelController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Tableau de bord',
        showLogoutButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Accès rapide',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: constraints.maxWidth > 600 ? 2 : 1.2,
                  children: [
                    _buildDashboardCard(
                      title: 'Liste des Employés',
                      icon: Icons.people,
                      color: Colors.blue,
                      onTap: () => controller.selectedIndex.value = 1,
                    ),
                    _buildDashboardCard(
                      title: 'Liste des Lieux',
                      icon: Icons.place,
                      color: Colors.green,
                      onTap: () => controller.selectedIndex.value = 8,
                    ),
                    _buildDashboardCard(
                      title: 'Messages',
                      icon: Icons.message,
                      color: Colors.orange,
                      onTap: () => controller.selectedIndex.value = 11,
                    ),
                    _buildDashboardCard(
                      title: 'Historique',
                      icon: Icons.history,
                      color: Colors.purple,
                      onTap: () => controller.selectedIndex.value = 12,
                    ),
                  ],
                );
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.8),
                color,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 