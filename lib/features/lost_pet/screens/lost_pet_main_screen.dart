import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_petfinder/core/router/lost_pet/lost_pet_routes.dart';
import 'package:app_petfinder/models/lost_pet/lost_pet_model.dart';
import 'package:app_petfinder/features/lost_pet/widgets/lost_pet_card.dart';

class LostPetHomeScreen extends StatefulWidget {
  const LostPetHomeScreen({super.key});

  @override
  State<LostPetHomeScreen> createState() => _LostPetHomeScreenState();
}

class _LostPetHomeScreenState extends State<LostPetHomeScreen> {
  int _selectedFilterIndex = 0;

  final List<LostPetModel> mockPetReports = [];

  List<LostPetModel> get _filteredReports {
    if (_selectedFilterIndex == 1) {
      return mockPetReports.where((r) => r.reportStatusTag == 'LOST').toList();
    } else if (_selectedFilterIndex == 2) {
      return mockPetReports.where((r) => r.reportStatusTag == 'FOUND').toList();
    }
    return mockPetReports;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Mascotas Perdidas',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: Colors.teal),
            onPressed: () {
              // TODO: Abrir filtros avanzados de radio/distancia
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'btn_report_lost_pet',
        onPressed: () {
          context.push(LostPetRoutes.publish);
        },
        backgroundColor: Colors.redAccent,
        icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
        label: const Text(
          'Reportar Mascota',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Selector de Categoría (Tabs superiores)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip(0, 'Todos'),
                const SizedBox(width: 8),
                _buildFilterChip(1, 'Perdidos'),
                const SizedBox(width: 8),
                _buildFilterChip(2, 'Encontrados'),
              ],
            ),
          ),

          // Lista de reportes
          Expanded(
            child: _filteredReports.isEmpty
                ? const Center(
                    child: Text(
                      'No hay reportes en esta categoría',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredReports.length,
                    itemBuilder: (context, index) {
                      final report = _filteredReports[index];
                      return LostPetCard(
                        report: report,
                        onTap: () {
                          // TODO: Abrir modal o pantalla de detalle del reporte
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(int index, String label) {
    final isSelected = _selectedFilterIndex == index;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey.shade700,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedColor: Colors.teal,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? Colors.teal : Colors.grey.shade300),
      ),
      onSelected: (_) {
        setState(() => _selectedFilterIndex = index);
      },
    );
  }
}