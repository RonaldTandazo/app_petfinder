import 'dart:math' as math;
import 'package:app_petfinder/enums/followed/followed_pet_filter.dart';
import 'package:app_petfinder/enums/followed/followed_pet_type.dart';
import 'package:app_petfinder/features/followed/widgets/followed_pet_card.dart';
import 'package:app_petfinder/features/followed/widgets/summary_card.dart';
import 'package:app_petfinder/models/followed/followed_pet_model.dart';
import 'package:app_petfinder/widgets/state/app_empty_state.dart';
import 'package:flutter/material.dart';

class FollowedPetsScreen extends StatefulWidget {
  const FollowedPetsScreen({super.key});

  @override
  State<FollowedPetsScreen> createState() =>
      _FollowedPetsScreenState();
}

class _FollowedPetsScreenState extends State<FollowedPetsScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  FollowedPetFilter _selectedFilter = FollowedPetFilter.all;

  // Datos de prueba. Sustituir por los datos del endpoint.
  final List<FollowedPetModel> _followedPets = const [
    FollowedPetModel(
      id: 1,
      name: 'Max',
      description: 'Cariñoso, juguetón y muy amigable.',
      location: 'Guayaquil',
      species: 'Perro',
      age: '2 años',
      gender: 'male',
      type: FollowedPetType.adoption,
      imageUrl:
          'https://images.unsplash.com/photo-1552053831-71594a27632d?w=800',
    ),
    FollowedPetModel(
      id: 2,
      name: 'Luna',
      description: 'Busca una familia que le dé mucho amor.',
      location: 'Samborondón',
      species: 'Gato',
      age: '1 año',
      gender: 'female',
      type: FollowedPetType.adoption,
      imageUrl:
          'https://images.unsplash.com/photo-1573865526739-10659fec78a5?w=800',
    ),
    FollowedPetModel(
      id: 3,
      name: 'Rocky',
      description: 'Reportado como perdido. Se busca a su familia.',
      location: 'Urdesa, Guayaquil',
      species: 'Perro',
      age: '4 años',
      gender: 'male',
      type: FollowedPetType.lost,
      imageUrl:
          'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=800',
    ),
    FollowedPetModel(
      id: 4,
      name: 'Milo',
      description: 'Gatito rescatado que espera un nuevo hogar.',
      location: 'Alborada, Guayaquil',
      species: 'Gato',
      age: '6 meses',
      gender: 'male',
      type: FollowedPetType.adoption,
      imageUrl:
          'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=800',
    ),
    FollowedPetModel(
      id: 5,
      name: 'Toby',
      description: 'Se perdió cerca de un parque. Su familia lo busca.',
      location: 'Ceibos, Guayaquil',
      species: 'Perro',
      age: '3 años',
      gender: 'male',
      type: FollowedPetType.lost,
      imageUrl:
          'https://images.unsplash.com/photo-1537151608828-ea2b11777ee8?w=800',
    ),
    FollowedPetModel(
      id: 6,
      name: 'Nala',
      description: 'Tranquila y sociable. Lista para ser adoptada.',
      location: 'Durán',
      species: 'Perro',
      age: '1 año',
      gender: 'female',
      type: FollowedPetType.adoption,
      imageUrl:
          'https://images.unsplash.com/photo-1517849845537-4d257902454a?w=800',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FollowedPetModel> get _filteredPets {
    final query = _searchController.text.trim().toLowerCase();

    return _followedPets.where((pet) {
      final matchesFilter = switch (_selectedFilter) {
        FollowedPetFilter.all => true,
        FollowedPetFilter.adoption =>
          pet.type == FollowedPetType.adoption,
        FollowedPetFilter.lost =>
          pet.type == FollowedPetType.lost,
      };

      final matchesSearch = query.isEmpty ||
          pet.name.toLowerCase().contains(query) ||
          pet.location.toLowerCase().contains(query) ||
          pet.species.toLowerCase().contains(query);

      return matchesFilter && matchesSearch;
    }).toList();
  }

  int get _adoptionCount => _followedPets
      .where((pet) => pet.type == FollowedPetType.adoption)
      .length;

  int get _lostCount => _followedPets
      .where((pet) => pet.type == FollowedPetType.lost)
      .length;

  void _showPetDetails(FollowedPetModel pet) {
    // TODO: Navegar al detalle correspondiente según pet.type.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Seleccionaste a ${pet.name}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Favoritos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          final horizontalPadding = width < 360
              ? 12.0
              : width < 600
                  ? 16.0
                  : width < 900
                      ? 24.0
                      : 32.0;

          final maxContentWidth = width >= 1200
              ? 1120.0
              : double.infinity;

          // Número de columnas según el ancho disponible.
          final crossAxisCount = width < 600
              ? 1
              : width < 900
                  ? 2
                  : 3;

          final isMobile = crossAxisCount == 1;

          // Altura de las tarjetas adaptada al dispositivo.
          final cardHeight = isMobile
              ? width < 360
                  ? 170.0
                  : width < 420
                      ? 180.0
                      : 190.0
              : width < 900
                  ? 300.0
                  : 320.0;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxContentWidth,
              ),
              child: CustomScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      12,
                      horizontalPadding,
                      24,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildSummary(
                          colorScheme,
                          width,
                        ),
                        const SizedBox(height: 20),

                        // Buscador
                        TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: 'Buscar por nombre o ubicación',
                            prefixIcon:
                                const Icon(Icons.search_rounded),
                            suffixIcon:
                                _searchController.text.isNotEmpty
                                    ? IconButton(
                                        tooltip: 'Limpiar búsqueda',
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {});
                                        },
                                        icon: const Icon(
                                          Icons.close_rounded,
                                        ),
                                      )
                                    : null,
                            filled: true,
                            fillColor: colorScheme.surface,
                            contentPadding:
                                const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: colorScheme.outlineVariant,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: colorScheme.outlineVariant,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: colorScheme.primary,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // Encabezado de resultados
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Mis seguimientos',
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_filteredPets.length} resultados',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),
                      ]),
                    ),
                  ),

                  // Resultados vacíos
                  if (_filteredPets.isEmpty)
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 300,
                        child: AppEmptyState(
                          icon: Icons.pets,
                          title: 'No encontramos casos',
                          description: 'Prueba con otra búsqueda o cambia de filtro',
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        0,
                        horizontalPadding,
                        32,
                      ),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final pet = _filteredPets[index];

                            return FollowedPetCard(
                              pet: pet,
                              compact: isMobile,
                              onTap: () => _showPetDetails(pet),
                            );
                          },
                          childCount: _filteredPets.length,
                        ),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: width < 600 ? 0 : 16,
                          mainAxisSpacing: width < 600 ? 12 : 16,
                          mainAxisExtent: cardHeight,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummary(
    ColorScheme colorScheme,
    double availableWidth,
  ) {
    final bool isSmallPhone = availableWidth < 360;
    final bool isMobile = availableWidth < 600;

    final double spacing = isSmallPhone ? 8 : 10;

    // En teléfonos pequeños se muestran dos tarjetas por fila.
    // En pantallas más grandes se muestran las tres en una fila.
    final int columns = isSmallPhone ? 2 : 3;

    final double itemWidth = isSmallPhone
        ? (availableWidth - spacing) / columns
        : (availableWidth - spacing * 2) / columns;

    final cards = [
      SummaryCard(
        title: 'Todos',
        count: _followedPets.length,
        icon: Icons.favorite_rounded,
        color: colorScheme.primary,
        selected: _selectedFilter == FollowedPetFilter.all,
        onTap: () {
          setState(() {
            _selectedFilter = FollowedPetFilter.all;
          });
        },
      ),
      SummaryCard(
        title: 'Adopción',
        count: _adoptionCount,
        icon: Icons.home_rounded,
        color: const Color(0xFF16866B),
        selected: _selectedFilter == FollowedPetFilter.adoption,
        onTap: () {
          setState(() {
            _selectedFilter = FollowedPetFilter.adoption;
          });
        },
      ),
      SummaryCard(
        title: 'Perdidas',
        count: _lostCount,
        icon: Icons.search_rounded,
        color: const Color(0xFFE58B35),
        selected: _selectedFilter == FollowedPetFilter.lost,
        onTap: () {
          setState(() {
            _selectedFilter = FollowedPetFilter.lost;
          });
        },
      ),
    ];

    if (isSmallPhone) {
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: cards.map((card) {
          return SizedBox(
            width: itemWidth,
            child: card,
          );
        }).toList(),
      );
    }

    if (isMobile) {
      return Row(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            if (i > 0) SizedBox(width: spacing),
            Expanded(child: cards[i]),
          ],
        ],
      );
    }

    return Row(
      children: [
        for (int i = 0; i < cards.length; i++) ...[
          if (i > 0) SizedBox(width: spacing),
          Expanded(child: cards[i]),
        ],
      ],
    );
  }
}
