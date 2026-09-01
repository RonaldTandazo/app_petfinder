import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:app_petfinder/features/lost_pet/widgets/report_sighting_bottom_sheet.dart';
import 'package:app_petfinder/features/lost_pet/widgets/show_sighting_bottom_sheet.dart';
import 'package:app_petfinder/models/lost_pet/lost_pet_model.dart';
import 'package:app_petfinder/models/lost_pet/sight_report_model.dart';
import 'package:app_petfinder/widgets/contact/app_contact_action_buttons.dart';
import 'package:app_petfinder/widgets/images/app_bar_image_carousel.dart';
import 'package:app_petfinder/widgets/locations/app_tracking_map.dart';
import 'package:app_petfinder/widgets/pets/app_pet_header_info.dart';
import 'package:app_petfinder/widgets/pets/app_pet_quick_info_grid.dart';
import 'package:app_petfinder/widgets/sightings/app_sightings_list.dart';
import 'package:app_petfinder/widgets/snackbars/app_snackbar.dart';


class LostPetDetailScreen extends StatefulWidget {
  final int lostPetId;
  const LostPetDetailScreen({
    super.key,
    required this.lostPetId,
  });

  @override
  State<LostPetDetailScreen> createState() => _LostPetDetailScreenState();
}

class _LostPetDetailScreenState extends State<LostPetDetailScreen> {
  final MapController _mapController = MapController();
  int? _selectedSightId;
  bool _isFollowing = false;

  late final LostPetModel _lostPet;
  late final List<SightReportModel> _sightings;

  @override
  void initState() {
    super.initState();
    _lostPet = _mockPet;
    _sightings = _mockSightings;
  }

  void _toggleFollowStatus() {
    setState(() {
      _isFollowing = !_isFollowing;
    });

    final message = _isFollowing 
      ? 'Siguiendo el caso de ${_lostPet.name}. Lo verás en tus casos guardados'
      : 'Dejaste de seguir el caso de ${_lostPet.name}';

    AppSnackBar.show(context, title: message, type: SnackBarType.information, position: SnackBarPosition.bottom);
  }

  void _handleSightingSelected(SightReportModel sight) {
    setState(() => _selectedSightId = sight.id);
    _mapController.move(LatLng(sight.latitude, sight.longitude), 16.0);
  }

  void _showSighting(BuildContext context, SightReportModel sight) async {
    await ShowSightingBottomSheet.show(context, sight);
  }

  void _openReportSighting(BuildContext context) async {
    await ReportSightingBottomSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final quickInfoItems = [
      QuickInfoItem(icon: Icons.calendar_today, label: 'Perdido el', value: _lostPet.eventDate),
      QuickInfoItem(icon: Icons.color_lens_outlined, label: 'Color', value: _lostPet.color ?? 'N/A'),
      QuickInfoItem(icon: Icons.location_city, label: 'Ciudad', value: _lostPet.city),
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // 1. Carrusel App Bar
          AppBarImageCarousel(
            pictures: _lostPet.pictures,
            isFollowing: _isFollowing,
            onToggleFollow: _toggleFollowStatus,
            title: _lostPet.name,
          ),

          // 2. Detalle de la Mascota y mapa
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado principal (Nombre, Raza, Estado, Recompensa)
                  AppPetHeaderInfo(
                    name: _lostPet.name,
                    species: _lostPet.species,
                    race: _lostPet.race,
                    size: _lostPet.size,
                    animalGenderTag: _lostPet.animalGenderTag,
                    reportStatus: _lostPet.reportStatus,
                    reportStatusTag: _lostPet.reportStatusTag,
                    hasReward: _lostPet.hasReward,
                    rewardAmount: _lostPet.rewardAmount,
                  ),
                  const SizedBox(height: 16),

                  // Grid de información rápida
                  AppPetQuickInfoGrid(items: quickInfoItems),
                  const SizedBox(height: 16),

                  // Descripción opcional
                  if (_lostPet.description != null && _lostPet.description!.isNotEmpty) ...[
                    const Text('Descripción', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(
                      _lostPet.description!,
                      style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Botones de Contacto (Llamar / WhatsApp)
                  AppContactActionButtons(phoneNumber: _lostPet.phoneMobile),
                  const SizedBox(height: 24),

                  // Mapa interactivo y marcadores
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ruta de Avistamientos',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${_sightings.length} reportes',
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  AppTrackingMap(
                    mainLatitude: _lostPet.latitude,
                    mainLongitude: _lostPet.longitude,
                    sightings: _sightings,
                    selectedSightId: _selectedSightId,
                    mapController: _mapController,
                    onSightTap: (sight) {
                      setState(() => _selectedSightId = sight.id);
                      _showSighting(context, sight);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Lista de avistamientos
                  if (_sightings.isNotEmpty) ...[
                    const Text(
                      'Historial de Avistamientos',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    AppSightingsList(
                      sightings: _sightings,
                      selectedSightId: _selectedSightId,
                      onSightingSelected: _handleSightingSelected,
                    ),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'btn_report_sighting',
        onPressed: () => _openReportSighting(context),
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.add_location_alt, color: Colors.white),
        label: const Text('¡Lo he visto!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// MOCKS
final _mockPet = LostPetModel(
  id: 101,
  name: 'Sasha',
  species: 'Perro',
  race: 'Shih Tzu',
  size: 'Pequeño',
  animalGenderTag: 'FEMALE',
  reportStatus: 'Perdido',
  reportStatusTag: 'ACTIVE',
  hasReward: true,
  rewardAmount: 150.00,
  eventDate: '28 Ago 2026',
  color: 'Blanco con Marrón',
  city: 'Guayaquil',
  description: 'Se extravió cerca del parque central. Tiene un collar rojo con cascabel, es muy amigable y responde a su nombre.',
  phoneMobile: '+593991234567',
  latitude: -2.1894,
  longitude: -79.8891,
  pictures: [
    'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=800&q=80',
  ], 
  reportTypeTag: 'LOST',
  reportType: 'Mascota Perdida',
  speciesTag: 'DOG',
  animalGender: 'Hembra',
  sizeTag: 'SMALL',
);

final List<SightReportModel> _mockSightings = [
  SightReportModel(
    id: 1,
    address: 'Av. Las Monjas y Calle 3ra',
    dateText: 'Ayer, 16:30',
    comment: 'Caminaba rápido cerca de la gasolinera',
    latitude: -2.1850,
    longitude: -79.8850,
  ),
  SightReportModel(
    id: 2,
    address: 'Cerca del Centro Comercial Aventura',
    dateText: 'Hoy, 09:15',
    comment: 'Estaba descansando bajo un árbol',
    latitude: -2.1920,
    longitude: -79.8920,
  ),
];