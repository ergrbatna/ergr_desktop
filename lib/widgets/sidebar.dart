import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.purple.shade800,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: const Column(
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                    size: 48,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Panneau d\'Administration',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24),
            _buildSection(
              'Principal',
              [
                MenuItem(
                  icon: Icons.dashboard,
                  title: 'Tableau de Bord',
                  index: 0,
                ),
              ],
            ),
            _buildSection(
              'Employés',
              [
                MenuItem(
                  icon: Icons.people,
                  title: 'Liste des Employés',
                  index: 1,
                ),
                MenuItem(
                  icon: Icons.person_add,
                  title: 'Ajouter un Employé',
                  index: 2,
                ),
                MenuItem(
                  icon: Icons.person_remove,
                  title: 'Supprimer un Employé',
                  index: 3,
                ),
                MenuItem(
                  icon: Icons.edit,
                  title: 'Modifier un Employé',
                  index: 4,
                ),
              ],
            ),
            _buildSection(
              'Plantes',
              [
                MenuItem(
                  icon: Icons.eco,
                  title: 'Liste des Plantes',
                  index: 5,
                ),
                MenuItem(
                  icon: Icons.add_circle,
                  title: 'Ajouter une Plante',
                  index: 6,
                ),
                MenuItem(
                  icon: Icons.remove_circle,
                  title: 'Supprimer une Plante',
                  index: 7,
                ),
              ],
            ),
            _buildSection(
              'Lieux',
              [
                MenuItem(
                  icon: Icons.place,
                  title: 'Liste des Lieux',
                  index: 8,
                ),
                MenuItem(
                  icon: Icons.add_location,
                  title: 'Ajouter un Lieu',
                  index: 9,
                ),
                MenuItem(
                  icon: Icons.delete,
                  title: 'Supprimer un Lieu',
                  index: 10,
                ),
              ],
            ),
            _buildSection(
              'Communication',
              [
                MenuItem(
                  icon: Icons.message,
                  title: 'Messages',
                  index: 11,
                ),
              ],
            ),
            _buildSection(
              'Historique',
              [
                MenuItem(
                  icon: Icons.history,
                  title: 'Historique',
                  index: 12,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<MenuItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...items.map((item) => _buildMenuItem(item)),
        const Divider(color: Colors.white24),
      ],
    );
  }

  Widget _buildMenuItem(MenuItem item) {
    final isSelected = selectedIndex == item.index;
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(
          item.icon,
          color: isSelected ? Colors.white : Colors.white70,
        ),
        title: Text(
          item.title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
          ),
        ),
        selected: isSelected,
        selectedTileColor: Colors.white.withOpacity(0.1),
        onTap: () => onItemSelected(item.index),
      ),
    );
  }
}

class MenuItem {
  final IconData icon;
  final String title;
  final int index;

  MenuItem({
    required this.icon,
    required this.title,
    required this.index,
  });
}
