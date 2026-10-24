import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:app_petfinder/enums/snackbar/snackbar_type.dart';
import 'package:app_petfinder/enums/datepicker/date_filter_type.dart';
import 'package:app_petfinder/enums/datepicker/date_selection_type.dart';
import 'package:app_petfinder/models/storage/temp_file_model.dart';
import 'package:app_petfinder/widgets/images/app_image_picker_grid.dart';
import 'package:app_petfinder/widgets/locations/app_location_picket_tile.dart';
import 'package:app_petfinder/widgets/snackbars/app_snackbar.dart';
import 'package:app_petfinder/widgets/datepickers/app_datepicker.dart';
import 'package:app_petfinder/features/adoption/styles/pet_form_styles.dart';

class ReportSightingBottomSheet extends StatefulWidget {
  const ReportSightingBottomSheet({super.key});

  static Future<Map<String, dynamic>?> show(BuildContext context) {
    return showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      elevation: 0,
      builder: (modalContext) {
        return const ReportSightingBottomSheet();
      },
    );
  }

  @override
  State<ReportSightingBottomSheet> createState() => _ReportSightingBottomSheetState();
}

class _ReportSightingBottomSheetState extends State<ReportSightingBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

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

  void _submitReport() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

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

    final List<Map<String, dynamic>> photosPayload = _selectedImages.asMap().entries.map((entry) {
      final int index = entry.key;
      final TempFileModel image = entry.value;

      return image.toFinalPayload(
        isMain: false,
        sortOrder: index,
      );
    }).toList();

    final Map<String, dynamic> payload = {
      'event_date': _selectedEventDate?.toIso8601String(),
      'event_address': _addressController.text.trim(),
      'latitude': _latitude,
      'longitude': _longitude,
      'comment': _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),
      'photos': photosPayload,
    };

    Navigator.pop(context, payload);
  }
  
  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    
    final double screenWidth = mediaQuery.size.width;
    final double screenHeight = mediaQuery.size.height;
    final double bottomInset = mediaQuery.viewInsets.bottom;

    final bool isSmallPhone = screenWidth < 360;
    final bool isTablet = screenWidth >= 600;

    final double horizontalPadding = isSmallPhone ? 14 : 20;
    final double titleFontSize = isSmallPhone ? 17 : 19;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: screenHeight,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAF9),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Encabezado fijo
            Container(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                12,
                horizontalPadding,
                16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: Text(
                      'Registrar Avistamiento',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Formulario desplazable
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 700 : double.infinity,
                  ),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        20,
                        horizontalPadding,
                        24,
                      ),
                      children: [
                        AppImagePickerGrid(
                          images: _selectedImages,
                          onImagesChanged: (updatedList) {
                            setState(() {
                              _selectedImages = updatedList;
                            });
                          },
                        ),
                        const SizedBox(height: 20),

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
                            if (value == null ||
                                value.isEmpty ||
                                value == 'Seleccionar fecha') {
                              return 'Selecciona fecha';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _addressController,
                          textInputAction: TextInputAction.next,
                          validator: (val) =>
                              val == null || val.trim().isEmpty
                                  ? 'Ingresa la dirección'
                                  : null,
                          decoration: PetFormStyles.inputDecoration(
                            'Dirección de referencia / Sector *',
                            Icons.place_rounded,
                          ),
                        ),
                        const SizedBox(height: 16),

                        AppLocationPickerTile(
                          latitude: _latitude,
                          longitude: _longitude,
                          isRequired: false,
                          title: 'Marcar lugar de avistamiento',
                          customHint:
                              'Indica el punto de referencia donde viste a la mascota',
                          onLocationSelected: (LatLng result) {
                            setState(() {
                              _latitude = result.latitude;
                              _longitude = result.longitude;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _commentController,
                          maxLines: 3,
                          minLines: 2,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: PetFormStyles.inputDecoration(
                            'Comentario u observación (ej. Tenía collar rojo)',
                            Icons.comment_rounded,
                          ),
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: isSmallPhone ? 12 : 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _submitReport,
                            child: const Text(
                              'Enviar Reporte',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}