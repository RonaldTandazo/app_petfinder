import 'package:app_petfinder/widgets/app_badge.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_petfinder/models/adoption/adoption_pet_model.dart';
import 'package:app_petfinder/widgets/app_image_placeholders.dart';

class PetDetailScreen extends StatelessWidget {
  final AdoptionPetModel? pet;

  const PetDetailScreen({super.key, this.pet});

  // Datos de prueba (Fallback si no recibe modelo)
  AdoptionPetModel get _mockPet => AdoptionPetModel(
        id: 99,
        name: 'Luna',
        speciesId: 1,
        species: 'Perro',
        race: 'Siberian Husky',
        age: '1 año y 2 meses',
        genderTag: 'FEMALE',
        picture:
            'https://images.unsplash.com/photo-1537151608828-ea2b11777ee8?q=80&w=1000&auto=format&fit=crop',
        isUrgent: true,
      );

  @override
  Widget build(BuildContext context) {
    final petData = pet ?? _mockPet;
    final primaryColor = Colors.teal.shade700;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      body: CustomScrollView(
        slivers: [
          // 1. Cabecera con Imagen Desplegable
          SliverAppBar(
            expandedHeight: 380,
            pinned: true,
            backgroundColor: primaryColor,
            leading: CircleAvatar(
              backgroundColor: Colors.black.withValues(alpha: 0.35),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 18),
                onPressed: () => context.pop(),
              ),
            ),
            actions: [
              CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.35),
                child: IconButton(
                  icon: const Icon(Icons.favorite_border_rounded,
                      color: Colors.white, size: 22),
                  onPressed: () {
                    // TODO: Toggle Favorito
                  },
                ),
              ),
              const SizedBox(width: 12),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  petData.picture != null && petData.picture!.isNotEmpty
                      ? Image.network(
                          petData.picture!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => AppImagePlaceholders.swipe(
                            icon: Icons.pets,
                            message: 'Sin imagen',
                          ),
                        )
                      : AppImagePlaceholders.swipe(
                          icon: Icons.pets,
                          message: 'Sin imagen',
                        ),
                  
                  // Sombreado inferior para contraste
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.3),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.6),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Badge Urgente Flotante
                  if (petData.isUrgent)
                    const AppBadge(
                      text: 'ADOPCIÓN URGENTE',
                      icon: Icons.warning_amber_rounded,
                      position: BadgePosition.bottomLeft,
                      fontSize: 11,
                      iconSize: 15,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                ],
              ),
            ),
          ),

          // 2. Contenido e Información Detallada
          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0, -20, 0),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAF9),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre, Raza y Genero
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                petData.name,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              if (petData.race != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  petData.race!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: petData.genderTag == 'MALE'
                                ? Colors.blue.shade50
                                : Colors.pink.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            petData.genderTag == 'MALE'
                                ? Icons.male_rounded
                                : Icons.female_rounded,
                            color: petData.genderTag == 'MALE'
                                ? Colors.blue.shade700
                                : Colors.pink.shade700,
                            size: 28,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Grid de Atributos Rápidos (Edad, Especie, Tamaño, etc.)
                    Row(
                      children: [
                        _buildInfoCard(
                          title: 'Edad',
                          value: petData.age,
                          icon: Icons.cake_outlined,
                        ),
                        const SizedBox(width: 12),
                        _buildInfoCard(
                          title: 'Especie',
                          value: petData.species,
                          icon: Icons.pets_outlined,
                        ),
                        const SizedBox(width: 12),
                        _buildInfoCard(
                          title: 'Sexo',
                          value: petData.genderTag == 'MALE' ? 'Macho' : 'Hembra',
                          icon: Icons.wc_outlined,
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Historia / Descripción
                    const Text(
                      'Sobre la mascota',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${petData.name} es una mascota muy juguetona y sociable. Le encanta convivir con familias, salir a pasear y aprender nuevos trucos. Se entrega desparasitada y con su esquema de vacunación al día.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Tarjeta de Refugio / Dueño
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.teal.shade100,
                            child: Icon(Icons.foundation_rounded,
                                color: primaryColor),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Fundación Huellitas Guayaquil',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Organización de Rescate',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100), // Espacio para el botón flotante
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // 3. Botón de Acción Fijo Inferior
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              // TODO: Redirigir a formulario de adopción o chat
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Solicitar Adopción',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.teal.shade700, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}