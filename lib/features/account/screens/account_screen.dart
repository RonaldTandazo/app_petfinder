import 'package:flutter/material.dart';
import 'package:app_petfinder/core/network/api_exception.dart';
import 'package:app_petfinder/core/utils/api_error_handler.dart';
import 'package:app_petfinder/core/utils/session_storage_service.dart';
import 'package:app_petfinder/features/account/widgets/account_skeleton.dart';
import 'package:app_petfinder/features/account/widgets/adoption_pets_grid.dart';
import 'package:app_petfinder/features/account/widgets/lost_pets_grid.dart';
import 'package:app_petfinder/features/account/widgets/metric_item.dart';
import 'package:app_petfinder/features/account/widgets/profile_drawer.dart';
import 'package:app_petfinder/features/account/widgets/sticky_tab_bar.dart';
import 'package:app_petfinder/models/account/metric_model.dart';
import 'package:app_petfinder/models/adoption/adoption_pet_list_model.dart';
import 'package:app_petfinder/models/lost_pet/lost_pet_list_model.dart';
import 'package:app_petfinder/repository/account/account_repository.dart';
import 'package:app_petfinder/repository/adoption/adoption_repository.dart';
import 'package:app_petfinder/repository/lost_pet/lost_pet_repository.dart';
import 'package:app_petfinder/widgets/state/app_empty_state.dart';
import 'package:app_petfinder/enums/account/pet_source.dart';
import 'package:app_petfinder/enums/account/metric_action.dart';

class AccountScreen extends StatefulWidget {
  final int? tutorId;

  const AccountScreen({super.key, this.tutorId});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> with SingleTickerProviderStateMixin {
  final AccountRepository _accountRepository = AccountRepository();
  final AdoptionRepository _adoptionRepository = AdoptionRepository();
  final LostPetRepository _lostPetRepository = LostPetRepository();
  late TabController _tabController;

  bool get isMyProfile {
    if (widget.tutorId == null) return true;
    return widget.tutorId == SessionStorageService.tutorId;
  }

  final List<MetricModel> _metrics = [];
  final List<AdoptionPetListModel> _adoptionPets = [];
  final List<LostPetListModel> _lostPets = [];

  String? _avatar;
  String _name = '';
  String _email = '';

  bool _isLoading = true;
  bool _isLoadingMoreAdoptions = false;
  bool _isLoadingMoreLostPets = false;
  bool _hasMoreAdoptions = true;
  bool _hasMoreLostPets = true;
  int _pageAdoptions = 1;
  int _pageLostPets = 1;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProfileData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _pageAdoptions = 1;
      _pageLostPets = 1;
      _hasMoreAdoptions = true;
      _hasMoreLostPets = true;
      _adoptionPets.clear();
      _lostPets.clear();
      _metrics.clear();
    });
    await _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);

    final payload = {
      'page_adoptions': _pageAdoptions,
      'page_lost_pets': _pageLostPets,
      'limit': _limit,
      if (!isMyProfile) 'tutor_id': widget.tutorId,
    };

    if (isMyProfile) {
      _name = SessionStorageService.name ?? 'Usuario';
      _email = SessionStorageService.email ?? '';
      _avatar = null;
    }

    try {
      final response = await _accountRepository.getProfileData(payload);
      if (!mounted) return;

      final data = response.data;
      if (data != null) {
        if (data['metrics'] is List) {
          final List metricsJson = data['metrics'];
          final newMetrics = metricsJson
              .map((e) => MetricModel.fromJson(e as Map<String, dynamic>))
              .toList();

          setState(() => _metrics.addAll(newMetrics));
        }

        if (data['adoptions'] is List) {
          final List newAdoptionPetsJson = data['adoptions'];
          final newAdoptionPets = newAdoptionPetsJson
              .map((e) => AdoptionPetListModel.fromJson(e as Map<String, dynamic>))
              .toList();

          setState(() {
            _adoptionPets.addAll(newAdoptionPets);
            _hasMoreAdoptions = data['hasMoreAdoptions'] ?? false;
            if (_hasMoreAdoptions) _pageAdoptions++;
          });
        }

        if (data['lost_pets'] is List) {
          final List newLostPetsJson = data['lost_pets'];
          final newLostPets = newLostPetsJson
              .map((e) => LostPetListModel.fromJson(e as Map<String, dynamic>))
              .toList();

          setState(() {
            _lostPets.addAll(newLostPets);
            _hasMoreLostPets = data['hasMoreLostPets'] ?? false;
            if (_hasMoreLostPets) _pageLostPets++;
          });
        }
      }
    } on ApiException catch (e) {
      ApiErrorHandler.handle(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMoreAdoptions() async {
    if (_isLoadingMoreAdoptions || !_hasMoreAdoptions || _isLoading) return;

    setState(() => _isLoadingMoreAdoptions = true);

    final Map<String, dynamic> payload = {
      'page': _pageAdoptions,
      'limit': _limit,
      if (!isMyProfile) 'tutor_id': widget.tutorId,
    };

    try {
      final response = await _adoptionRepository.getAdoptionPets(payload);
      if (!mounted) return;

      final data = response.data;
      if (data != null && data['pets'] is List) {
        final List newAdoptionPetsJson = data['pets'];
        final newPets = newAdoptionPetsJson
            .map((e) => AdoptionPetListModel.fromJson(e as Map<String, dynamic>))
            .toList();

        setState(() {
          _adoptionPets.addAll(newPets);
          _hasMoreAdoptions = data['hasMore'] ?? false;
          if (_hasMoreAdoptions) _pageAdoptions++;
        });
      }
    } on ApiException catch (e) {
      ApiErrorHandler.handle(context, e);
    } finally {
      if (mounted) setState(() => _isLoadingMoreAdoptions = false);
    }
  }

  Future<void> _loadMoreLostPets() async {
    if (_isLoadingMoreLostPets || !_hasMoreLostPets || _isLoading) return;

    setState(() => _isLoadingMoreLostPets = true);

    final Map<String, dynamic> payload = {
      'page': _pageLostPets,
      'limit': _limit,
      if (!isMyProfile) 'tutor_id': widget.tutorId,
    };

    try {
      final response = await _lostPetRepository.getLostPets(payload);
      if (!mounted) return;

      final data = response.data;
      if (data != null && data['lost_pets'] is List) {
        final List newLostPetsJson = data['lost_pets'];
        final newLostPets = newLostPetsJson
            .map((e) => LostPetListModel.fromJson(e as Map<String, dynamic>))
            .toList();

        setState(() {
          _lostPets.addAll(newLostPets);
          _hasMoreLostPets = data['hasMore'] ?? false;
          if (_hasMoreLostPets) _pageLostPets++;
        });
      }
    } on ApiException catch (e) {
      ApiErrorHandler.handle(context, e);
    } finally {
      if (mounted) setState(() => _isLoadingMoreLostPets = false);
    }
  }

  bool _handleScrollNotification(ScrollNotification scrollInfo, VoidCallback onLoadMore) {
    if (scrollInfo.metrics.pixels >= (scrollInfo.metrics.maxScrollExtent * 0.8)) {
      onLoadMore();
    }
    return false;
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar publicación'),
        content: const Text('¿Estás seguro de que deseas eliminar este registro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ??
    false;
  }

  Future<void> _handlePetDelete(int id, PetSource source) async {
    final confirmed = await _showDeleteConfirmationDialog();
    if (!confirmed) return;

    // try {
    //   switch (source) {
    //     case PetSource.adoption:
    //       await _adoptionRepository.deletePet(id);
    //       setState(() => _adoptionPets.removeWhere((pet) => pet.id == id));
    //       break;
    //     case PetSource.lost:
    //       await _lostPetRepository.deletePet(id);
    //       setState(() => _lostPets.removeWhere((pet) => pet.id == id));
    //       break;
    //   }
    // } on ApiException catch (e) {
    //   ApiErrorHandler.handle(context, e);
    // }
  }

  Future<void> _handlePetStatusChange(int id, PetSource source) async {
    // try {
    //   switch (source) {
    //     case PetSource.adoption:
    //       await _adoptionRepository.toggleStatus(id);
    //       break;
    //     case PetSource.lost:
    //       await _lostPetRepository.toggleStatus(id);
    //       break;
    //   }
    // } on ApiException catch (e) {
    //   ApiErrorHandler.handle(context, e);
    // }
  }

  void _handlePetEdit(int id, PetSource source) {}

  void _handleMetricTap(MetricAction action) {
    switch (action) {
      case MetricAction.openPublished:
        break;
      case MetricAction.openRescued:
        break;
      case MetricAction.openFollowed:
        break;
      case MetricAction.unknown:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: isMyProfile
          ? ProfileDrawer(
              name: _name,
              email: _email,
              avatar: _avatar,
            )
          : null,
      body: _isLoading
          ? AccountSkeleton(isMyProfile: isMyProfile)
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: NestedScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          CircleAvatar(
                            radius: 46,
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            backgroundImage: _avatar != null ? NetworkImage(_avatar!) : null,
                            child: _avatar == null
                                ? Icon(
                                    Icons.person_rounded,
                                    size: 50,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _email,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                for (int i = 0; i < _metrics.length; i++) ...[
                                  MetricItem(
                                    label: _metrics[i].label,
                                    count: _metrics[i].count.toString(),
                                    onTap: () => _handleMetricTap(_metrics[i].action),
                                  ),
                                  if (i < _metrics.length - 1) _buildDivider(),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: StickyTabBar(
                        TabBar(
                          controller: _tabController,
                          labelColor: Theme.of(context).colorScheme.primary,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Theme.of(context).colorScheme.primary,
                          tabs: const [
                            Tab(
                              icon: Icon(Icons.pets_rounded),
                              text: 'En Adopción',
                            ),
                            Tab(
                              icon: Icon(Icons.search_off_rounded),
                              text: 'Perdidas',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    NotificationListener<ScrollNotification>(
                      onNotification: (scrollInfo) => _handleScrollNotification(scrollInfo, _loadMoreAdoptions),
                      child: AdoptionPetsGrid(
                        pets: _adoptionPets,
                        isMyProfile: isMyProfile,
                        isLoadingMore: _isLoadingMoreAdoptions,
                        emptyStateWidget: const AppEmptyState(
                          icon: Icons.pets,
                          description: 'No has publicado mascotas en adopción'
                        ),
                        onEdit: _handlePetEdit,
                        onDelete: _handlePetDelete,
                        onStatusChange: _handlePetStatusChange,
                      ),
                    ),
                    NotificationListener<ScrollNotification>(
                      onNotification: (scrollInfo) => _handleScrollNotification(scrollInfo, _loadMoreLostPets),
                      child: LostPetsGrid(
                        lostPets: _lostPets,
                        isMyProfile: isMyProfile,
                        isLoadingMore: _isLoadingMoreLostPets,
                        emptyStateWidget: const AppEmptyState(
                          icon: Icons.pets,
                          description: 'No has publicado reportes de mascotas perdidas'
                        ),
                        onEdit: _handlePetEdit,
                        onDelete: _handlePetDelete,
                        onStatusChange: _handlePetStatusChange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 28,
      width: 1,
      color: Colors.grey[300],
    );
  }
}