import 'package:app_petfinder/core/utils/session_info.dart';
import 'package:app_petfinder/models/storage/temp_file_model.dart';
import 'package:app_petfinder/widgets/images/app_image_picker_grid.dart';
import 'package:app_petfinder/widgets/locations/app_location_picket_tile.dart';
import 'package:app_petfinder/widgets/snackbars/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:app_petfinder/widgets/datepickers/app_datepicker.dart';
import 'package:app_petfinder/widgets/locations/app_location_picker.dart';
import 'package:app_petfinder/features/adoption/styles/pet_form_styles.dart';

class ReportSightingBottomSheet extends StatefulWidget {
  const ReportSightingBottomSheet({super.key});

  static Future<Map<String, dynamic>?> show(BuildContext context) {
    return showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => const ReportSightingBottomSheet(),
    );
  }

  @override
  State<ReportSightingBottomSheet> createState() => _ReportSightingBottomSheetState();
}

class _ReportSightingBottomSheetState extends State<ReportSightingBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final int? currentTutorId = SessionInfo.tutorId;

  DateTime? _selectedEventDate;
  double? _latitude;
  double? _longitude;
  List<TempFileModel> _selectedImages = [];

  @override
  void dispose() {
    _addressController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'Registrar Avistamiento',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),

                AppImagePickerGrid(
                  images: _selectedImages,
                  enableMainSelection: false,
                  onImagesChanged: (updatedList) {
                    setState(() {
                      _selectedImages = updatedList;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // 1. Selector de fecha
                AppDatePicker(
                  label: 'Fecha de avistamiento *',
                  icon: Icons.event_rounded,
                  selectionType: DateSelectionType.single,
                  filterType: DateFilterType.disableFuture,
                  selectedDate: _selectedEventDate,
                  onDateSelected: (date) {
                    setState(() {
                      _selectedEventDate = date;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty || value == 'Seleccionar fecha') {
                      return 'Selecciona fecha';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // 2. Campo para la dirección de referencia
                TextFormField(
                  controller: _addressController,
                  validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa la dirección' : null,
                  decoration: PetFormStyles.inputDecoration(
                    'Dirección de referencia / Sector *',
                    Icons.place_rounded,
                  ),
                ),
                const SizedBox(height: 12),

                // 3. Selección de avistamiento en el mapa
                AppLocationPickerTile(
                  latitude: _latitude,
                  longitude: _longitude,
                  isRequired: false,
                  title: 'Marcar lugar de avistamiento',
                  customHint: 'Indica el punto de referencia donde viste a la mascota',
                  onLocationSelected: (LatLng result) {
                    setState(() {
                      _latitude = result.latitude;
                      _longitude = result.longitude;
                    });
                  },
                ),
                const SizedBox(height: 12),

                // 4. Comentario adicional
                TextFormField(
                  controller: _commentController,
                  maxLines: 2,
                  decoration: PetFormStyles.inputDecoration(
                    'Comentario u observación (ej. Tenía collar rojo)',
                    Icons.comment_rounded,
                  ),
                ),
                const SizedBox(height: 16),

                // 5. Botón de envío
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        final hasUploading = _selectedImages.any((img) => img.isUploading);
                        if (hasUploading) {
                          AppSnackBar.show(
                            context,
                            title: 'Imágenes subiendo',
                            description: 'Por favor espera a que terminen de subirse las fotografías.',
                            type: SnackBarType.warning,
                          );
                          return;
                        }

                        final photosPayload = _selectedImages.asMap().entries.map((entry) {
                          final item = entry.value;
                          
                          return {
                            'path_temp': item.key,
                            'is_main':false,
                          };
                        }).toList();
                        
                        final Map<String, dynamic> payload = {
                          'tutor_id': currentTutorId,
                          'event_date': _selectedEventDate?.toIso8601String(),
                          'event_address': _addressController.text.trim(),
                          'latitude': _latitude,
                          'longitude': _longitude,
                          'comment': _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
                          'photos': photosPayload,
                        };
                        
                        Navigator.pop(context, payload);
                      }
                    },
                    child: const Text('Enviar Reporte'),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}