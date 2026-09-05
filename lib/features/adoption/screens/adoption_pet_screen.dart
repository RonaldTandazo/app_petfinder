import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:app_petfinder/models/adoption/adoption_pet_model.dart';
import 'package:app_petfinder/core/network/api_exception.dart';
import 'package:app_petfinder/core/utils/api_error_handler.dart';
import 'package:app_petfinder/core/utils/common_helpers.dart';
import 'package:app_petfinder/features/lost_pet/widgets/lost_pet_detail_skeleton.dart';
import 'package:app_petfinder/repository/adoption/adoption_repository.dart';
import 'package:app_petfinder/widgets/images/app_bar_image_carousel.dart';
import 'package:app_petfinder/widgets/pets/app_pet_quick_info_grid.dart';
import 'package:app_petfinder/widgets/snackbars/app_snackbar.dart';
import 'package:app_petfinder/widgets/contact/app_contact_action_buttons.dart';
import 'package:app_petfinder/widgets/pets/app_pet_header_info.dart';
import 'package:app_petfinder/widgets/locations/app_location_map.dart';

class AdoptionPetScreen extends StatefulWidget {
  final int petId;

  const AdoptionPetScreen({
    super.key,
    required this.petId
  });

  @override
  State<AdoptionPetScreen> createState() => _AdoptionPetScreenState();
}

class _AdoptionPetScreenState extends State<AdoptionPetScreen> {
  final MapController _mapController = MapController();
  final _adoptionRepository = AdoptionRepository();

  bool _isFollowing = false;
  bool _isLoadingAdoptionPet = true;

  AdoptionPetModel? _adoptionPet;

  @override
  void initState() {
    super.initState();

    _loadLostPet();
  }

  Future<void> _loadLostPet() async {
    try {
      final response = await _adoptionRepository.getAdoptionPet(widget.petId);
      if (!mounted) return;

      final data = response.data;

      if (data != null) {
        if (data['pet'] != null) {
          final Map<String, dynamic> adoptionPetJson = data['pet'];

          final AdoptionPetModel adoptionPet = AdoptionPetModel.fromJson(adoptionPetJson);

          setState(() {
            _adoptionPet = adoptionPet;
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
          _isLoadingAdoptionPet = false;
        });
      }
    }
  }

  void _toggleFollowStatus() {
    setState(() {
      _isFollowing = !_isFollowing;
    });

    final String message = _isFollowing 
      ? 'Ahora sigues la adopción de ${_adoptionPet!.name}. Lo verás en tus adopciones guardadas'
      : 'Dejaste de seguir la adopción de ${_adoptionPet!.name}';

    AppSnackBar.show(context, title: message, type: SnackBarType.information, position: SnackBarPosition.bottom);
    
    final Map<String, dynamic> payload = {
      'is_following': _isFollowing,
    };
    
    try {
      _adoptionRepository.setFollowState(widget.petId, payload);
    } on ApiException catch (e) {
      ApiErrorHandler.handle(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingAdoptionPet || _adoptionPet == null) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: const LostPetDetailSkeleton(),
      );
    }

    final List<QuickInfoItem> quickInfoItems = [
      QuickInfoItem(
        icon: Icons.calendar_today,
        label: 'Edad',
        value: _adoptionPet!.age,
      ),

      if (_adoptionPet!.color != null && _adoptionPet!.color!.isNotEmpty)
        QuickInfoItem(
          icon: Icons.color_lens_outlined,
          label: 'Color',
          value: _adoptionPet!.color!,
        ),

      QuickInfoItem(
        icon: Icons.location_city,
        label: 'Ciudad',
        value: _adoptionPet!.city,
      ),
    ];

    final bool hasDescription = _adoptionPet!.description != null && _adoptionPet!.description!.isNotEmpty;
    final bool hasHealthConditions = _adoptionPet!.healthConditions.isNotEmpty;
    final bool hasAddress = _adoptionPet!.address.isNotEmpty;
    final bool hasCoordinates = _adoptionPet!.latitude != null && _adoptionPet!.longitude != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      body: CustomScrollView(
        slivers: [
          AppBarImageCarousel(
            pictures: _adoptionPet!.pictures,
            isFollowing: _isFollowing,
            onToggleFollow: _toggleFollowStatus,
            title: _adoptionPet!.name,
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado principal (Nombre, Raza, Estado, Recompensa)
                  AppPetHeaderInfo(
                    name: _adoptionPet!.name,
                    species: _adoptionPet!.species,
                    race: _adoptionPet!.race,
                    size: _adoptionPet!.size,
                    genderTag: _adoptionPet!.genderTag,
                    isUrgent: _adoptionPet!.isUrgent,
                  ),
                  const SizedBox(height: 16),

                  // Grid de información rápida
                  AppPetQuickInfoGrid(items: quickInfoItems),
                  const SizedBox(height: 16),

                  // Descripción opcional
                  if (hasDescription) ...[
                    const Text('Descripción', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(
                      _adoptionPet!.description!,
                      style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                    ),
                    const SizedBox(height: 20),
                  ],

                  if(hasHealthConditions)...[
                    const Text('Estado de Salud', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _adoptionPet!.healthConditions.map((condition) {
                        return RawChip(
                          avatar: const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 18,
                            color: Color(0xFF0F766E),
                          ),
                          label: Text(
                            condition,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F766E),
                            ),
                          ),
                          backgroundColor: const Color(0xFFCCFBF1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Botones de Contacto (Llamar / WhatsApp)
                  AppContactActionButtons(phoneNumber: _adoptionPet!.phoneMobile, phoneHome: _adoptionPet!.phoneHome),
                  const SizedBox(height: 20),

                  if (hasAddress || hasCoordinates) ...[
                    const Text(
                      'Ubicación',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    if (hasAddress) ...[
                      const SizedBox(height: 6),
                      Text(
                        _adoptionPet!.address,
                        style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                      ),
                    ],
                    if (hasCoordinates) ...[
                      const SizedBox(height: 12),
                      AppLocationMap(
                        latitude: _adoptionPet!.latitude!,
                        longitude: _adoptionPet!.longitude!,
                        mapController: _mapController,
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}