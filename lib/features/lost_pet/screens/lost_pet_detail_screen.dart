import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:app_petfinder/core/network/api_exception.dart';
import 'package:app_petfinder/core/utils/api_error_handler.dart';
import 'package:app_petfinder/core/utils/common_helpers.dart';
import 'package:app_petfinder/core/utils/api_success_handler.dart';
import 'package:app_petfinder/features/lost_pet/widgets/lost_pet_detail_skeleton.dart';
import 'package:app_petfinder/repository/lost_pet/lost_pet_repository.dart';
import 'package:app_petfinder/repository/lost_pet/lost_pet_event_repository.dart';
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
import 'package:app_petfinder/widgets/loaders/app_loading_overlay.dart';

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
  final _lostPetRepository = LostPetRepository();
  final _lostPetEventRepository = LostPetEventRepository();

  int? _selectedSightId;
  bool _isFollowing = false;
  bool _isLoadingLostPet = true;

  LostPetModel? _lostPet;
  late List<SightReportModel> _sightings;

  @override
  void initState() {
    super.initState();

    _loadLostPet();
  }

  Future<void> _loadLostPet() async {
    try {
      final response = await _lostPetRepository.getLostPet(widget.lostPetId);
      if (!mounted) return;

      final data = response.data;


      if (data != null) {
        if (data['lost_pet'] != null) {
          final Map<String, dynamic> lostPetJson = data['lost_pet'];

          final LostPetModel lostPet = LostPetModel.fromJson(lostPetJson);

          setState(() {
            _lostPet = lostPet;
          });
        }

        if (data['sightings'] != null && data['sightings'] is List) {
          final List<dynamic> sightingsJson = data['sightings'];

          final List<SightReportModel> sightings = sightingsJson
              .map((json) => SightReportModel.fromJson(json))
              .toList();

          setState(() {
            _sightings = sightings;
          });
        }

         if (data['is_following'] != null) {
          setState(() {
            _isFollowing = data['is_following'];
          });
        }
      }
    } on ApiException catch (e) {
      ApiErrorHandler.handle(context, e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLostPet = false;
        });
      }
    }
  }

  void _toggleFollowStatus() {
    setState(() {
      _isFollowing = !_isFollowing;
    });

    final String message = _isFollowing 
      ? 'Ahora sigues el caso de ${_lostPet!.name}. Lo verás en tus casos guardados'
      : 'Dejaste de seguir el caso de ${_lostPet!.name}';

    AppSnackBar.show(context, title: message, type: SnackBarType.information, position: SnackBarPosition.bottom);
    
    final Map<String, dynamic> payload = {
      'is_following': _isFollowing,
    };
    
    try {
      _lostPetRepository.setFollowState(widget.lostPetId, payload);
    } on ApiException catch (e) {
      ApiErrorHandler.handle(context, e);
    }
  }

  void _handleSightingSelected(SightReportModel sight) {
    if(sight.latitude == null || sight.longitude == null) return;

    setState(() => _selectedSightId = sight.id);
    _mapController.move(LatLng(sight.latitude!, sight.longitude!), 16.0);
  }

  void _showSighting(BuildContext context, SightReportModel sight) async {
    await ShowSightingBottomSheet.show(context, sight);
  }

  Future<void> _openReportSighting(BuildContext context) async {
    final payload = await ReportSightingBottomSheet.show(context);

    if (payload == null) return;
    
    if (!mounted) return;

    payload['lost_pet_id'] = widget.lostPetId;
    
    _submitSighting(payload);
  }

  Future<void> _submitSighting(Map<String, dynamic> payload) async {
    AppLoadingOverlay.show(
      context,
      title: 'Registrando avistamiento...',
      description: 'Estamos registrado tu reporte, por favor espera un momento',
    );

    try {
      final response = await _lostPetEventRepository.store(payload);
      
      if (!mounted) return;

      final data = response.data;

      setState(() {
        if (data != null && data['lost_pet_event_id'] != null) {
          payload['id'] = data['lost_pet_event_id'];

          final SightReportModel newSighting = SightReportModel.fromJson(payload);
          
          setState(() {
            _sightings.add(newSighting);

            _sightings.sort((a, b) => b.eventDate.compareTo(a.eventDate));
          });
        }
      });
    } on ApiException catch (e) {
      ApiErrorHandler.handle(context, e);
    } finally {
      AppLoadingOverlay.hide();
    }
  }

  Future<void> _deleteEvent(int eventId) async {
    AppLoadingOverlay.show(
      context,
      title: 'Eliminando avistamiento...',
      description: 'Estamos quitando tu reporte, por favor espera un momento',
    );

    try {
      final response = await _lostPetEventRepository.delete(eventId);
      
      if (!mounted) return;

      setState(() {
        _sightings.removeWhere((sight) => sight.id == eventId);

        if (_selectedSightId == eventId) {
          _selectedSightId = null;
        }
      });

      ApiSuccessHandler.handle(context, title: '¡Reporte Eliminado!', description: response.message);
    } on ApiException catch (e) {
      ApiErrorHandler.handle(context, e);
    } finally {
      AppLoadingOverlay.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingLostPet || _lostPet == null) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: const LostPetDetailSkeleton(),
      );
    }

    final List<QuickInfoItem> quickInfoItems = [
      QuickInfoItem(
        icon: Icons.calendar_today,
        label: 'Perdido el',
        value: formatDate(_lostPet!.eventDate),
      ),

      if (_lostPet!.color != null && _lostPet!.color!.isNotEmpty)
        QuickInfoItem(
          icon: Icons.color_lens_outlined,
          label: 'Color',
          value: _lostPet!.color!,
        ),

      QuickInfoItem(
        icon: Icons.location_city,
        label: 'Ciudad',
        value: _lostPet!.city,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // 1. Carrusel App Bar
          AppBarImageCarousel(
            pictures: _lostPet!.pictures,
            isFollowing: _isFollowing,
            onToggleFollow: _toggleFollowStatus,
            title: _lostPet!.name,
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
                    name: _lostPet!.name,
                    species: _lostPet!.species,
                    race: _lostPet!.race,
                    size: _lostPet!.size,
                    animalGenderTag: _lostPet!.animalGenderTag,
                    reportStatus: _lostPet!.reportStatus,
                    reportStatusTag: _lostPet!.reportStatusTag,
                    hasReward: _lostPet!.hasReward,
                    rewardAmount: _lostPet!.rewardAmount,
                  ),
                  const SizedBox(height: 16),

                  // Grid de información rápida
                  AppPetQuickInfoGrid(items: quickInfoItems),
                  const SizedBox(height: 16),

                  // Descripción opcional
                  if (_lostPet!.description != null && _lostPet!.description!.isNotEmpty) ...[
                    const Text('Descripción', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(
                      _lostPet!.description!,
                      style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Botones de Contacto (Llamar / WhatsApp)
                  AppContactActionButtons(phoneNumber: _lostPet!.phoneMobile, phoneHome: _lostPet!.phoneHome),
                  const SizedBox(height: 24),

                  // Avistamientos
                  if (_sightings.isNotEmpty) ...[
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
                      mainLatitude: _lostPet!.latitude,
                      mainLongitude: _lostPet!.longitude,
                      sightings: _sightings,
                      selectedSightId: _selectedSightId,
                      mapController: _mapController,
                      onSightTap: (sight) {
                        setState(() => _selectedSightId = sight.id);
                        _showSighting(context, sight);
                      },
                    ),

                    const SizedBox(height: 16),
                    
                    const Text(
                      'Historial de Avistamientos',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    AppSightingsList(
                      sightings: _sightings,
                      selectedSightId: _selectedSightId,
                      onSightingSelected: _handleSightingSelected,
                      onSightingDeleted: (sightId) => _deleteEvent(sightId) 
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