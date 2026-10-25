import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:app_petfinder/core/utils/session_storage_service.dart';
import 'package:app_petfinder/enums/snackbar/snackbar_position.dart';
import 'package:app_petfinder/enums/snackbar/snackbar_type.dart';
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
import 'package:app_petfinder/widgets/state/app_empty_state.dart';

class LostPetScreen extends StatefulWidget {
  final int lostPetId;
  const LostPetScreen({
    super.key,
    required this.lostPetId,
  });

  @override
  State<LostPetScreen> createState() => _LostPetScreenState();
}

class _LostPetScreenState extends State<LostPetScreen> {
  final MapController _mapController = MapController();
  final _lostPetRepository = LostPetRepository();
  final _lostPetEventRepository = LostPetEventRepository();
  final int? currentTutorId = SessionStorageService.tutorId;

  int? _selectedSightId;
  bool _isFollowing = false;
  bool _isLoadingLostPet = true;

  LostPetModel? _lostPet;
  List<SightReportModel> _sightings = [];

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
      if (mounted) setState(() => _isLoadingLostPet = false);
    }
  }

  void _toggleFollowStatus() {
    setState(() {
      _isFollowing = !_isFollowing;
    });

    final String message = _isFollowing 
      ? 'Ahora sigues el caso de ${_lostPet!.name}. Lo verás en tus casos guardados'
      : 'Dejaste de seguir el caso de ${_lostPet!.name}';

    AppSnackBar.show(
      context,
      title: message,
      type: SnackBarType.information,
      position: SnackBarPosition.bottom
    );
    
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
      title: 'Registrando Avistamiento...',
      description: 'Estamos registrado tu reporte, por favor espera un momento',
    );

    try {
      final response = await _lostPetEventRepository.store(payload);
      
      if (!mounted) return;

      final data = response.data;

      setState(() {
        if (data != null && data['new_event'] != null && data['new_event'] is Map<String, dynamic>) {
          final SightReportModel newSighting = SightReportModel.fromJson(data['new_event']);
          
          setState(() {
            _sightings.add(newSighting);
            _sightings.sort((a, b) => b.eventDate.compareTo(a.eventDate));
          });
        }
      });
    } on ApiException catch (e) {
      ApiErrorHandler.handle(context, e);
    } finally {
      if(mounted) AppLoadingOverlay.hide();
    }
  }

  Future<void> _deleteEvent(int eventId) async {
    AppLoadingOverlay.show(
      context,
      title: 'Eliminando Avistamiento...',
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
      if(mounted) AppLoadingOverlay.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);

    final bool isSmallPhone = screenSize.width < 360;
    final bool isMobile = screenSize.width < 600;
    final bool isTablet = screenSize.width >= 600;

    final double contentPadding = isSmallPhone
        ? 10
        : isMobile
            ? 14
            : 20;

    final double sectionSpacing = isSmallPhone ? 12 : 16;
    final double sectionTitleSize = isSmallPhone ? 15 : 16;
    final double bodyTextSize = isSmallPhone ? 13 : 14;

    if (_isLoadingLostPet || _lostPet == null) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: const LostPetDetailSkeleton(),
      );
    }

    final pet = _lostPet!;

    final List<QuickInfoItem> quickInfoItems = [
      QuickInfoItem(
        icon: Icons.calendar_today,
        label: 'Perdido el',
        value: formatDate(pet.eventDate),
      ),
      if (pet.color != null && pet.color!.isNotEmpty)
        QuickInfoItem(
          icon: Icons.color_lens_outlined,
          label: 'Color',
          value: pet.color!,
        ),
      QuickInfoItem(
        icon: Icons.location_city,
        label: 'Ciudad',
        value: pet.city,
      ),
    ];

    final bool hasDescription = pet.description != null && pet.description!.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // 1. Carrusel App Bar
          AppBarImageCarousel(
            pictures: pet.pictures,
            isFollowing: _isFollowing,
            onToggleFollow: _toggleFollowStatus,
            title: pet.name,
          ),

          // 2. Detalle de la Mascota y mapa
           SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isTablet ? 900 : double.infinity,
                ),
                child: Padding(
                  padding: EdgeInsets.all(contentPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Encabezado principal (Nombre, Raza, Estado, Recompensa)
                      AppPetHeaderInfo(
                        name: _lostPet!.name,
                        species: _lostPet!.species,
                        race: _lostPet!.race,
                        size: _lostPet!.size,
                        genderTag: _lostPet!.genderTag,
                        reportStatus: _lostPet!.reportStatus,
                        reportStatusTag: _lostPet!.reportStatusTag,
                        hasReward: _lostPet!.hasReward,
                        rewardAmount: _lostPet!.rewardAmount,
                      ),
                      SizedBox(height: sectionSpacing),

                      // Grid de información rápida
                      AppPetQuickInfoGrid(items: quickInfoItems),

                      // Descripción opcional
                      if (hasDescription) ...[
                        SizedBox(height: sectionSpacing),
                        Text(
                          'Descripción',
                          style: TextStyle(
                            fontSize: sectionTitleSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          pet.description!,
                          style: TextStyle(
                            fontSize: bodyTextSize,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      ],

                      SizedBox(height: sectionSpacing),

                      // Botones de Contacto (Llamar / WhatsApp)
                      AppContactActionButtons(phoneNumber: _lostPet!.phoneMobile, phoneHome: _lostPet!.phoneHome),
                      SizedBox(height: sectionSpacing + 4),

                      // Avistamientos
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Avistamientos',
                              style: TextStyle(
                                fontSize: sectionTitleSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_sightings.length} reportes',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: isSmallPhone ? 11 : 13,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallPhone ? 8 : 12),
                      
                      if (_sightings.isNotEmpty) ...[
                        Text(
                          'Ruta en mapa',
                          style: TextStyle(
                            fontSize: isSmallPhone ? 13 : 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),
                        
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

                        SizedBox(height: sectionSpacing),
                        
                        Text(
                          'Historial de avistamientos',
                          style: TextStyle(
                            fontSize: isSmallPhone ? 13 : 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        AppSightingsList(
                          currentTutorId: currentTutorId,
                          sightings: _sightings,
                          selectedSightId: _selectedSightId,
                          onSightingSelected: _handleSightingSelected,
                          onSightingDeleted: (sightId) => _deleteEvent(sightId) 
                        ),
                      ]else...[
                        AppEmptyState(
                          icon: Icons.location_off_outlined,
                          description: 'No hay avistamientos registrados'
                        ),
                      ],
                      SizedBox(
                        height: screenSize.height < 650 ? 72 : 88,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'btn_report_sighting',
        onPressed: () => _openReportSighting(context),
        backgroundColor: Colors.teal,
        icon: Icon(
          Icons.add_location_alt,
          color: Colors.white,
          size: isSmallPhone ? 19 : 24,
        ),
         label: Text(
          '¡Lo he visto!',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isSmallPhone ? 12 : 14,
          ),
        ),
      ),
    );
  }
}