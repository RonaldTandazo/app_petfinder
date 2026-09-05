import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:app_petfinder/widgets/datepickers/app_datepicker.dart';
import 'package:app_petfinder/widgets/locations/app_location_picker.dart';
import 'package:app_petfinder/features/pet/styles/pet_form_styles.dart';

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

  double? _latitude;
  double? _longitude;
  DateTime? _selectedEventDate;

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

                // 3. Botón para seleccionar ubicación exacta en el mapa
                InkWell(
                  onTap: () async {
                    final LatLng? result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AppLocationPicker(
                          initialPosition: (_latitude != null && _longitude != null)
                              ? LatLng(_latitude!, _longitude!)
                              : null,
                        ),
                      ),
                    );

                    if (result != null) {
                      setState(() {
                        _latitude = result.latitude;
                        _longitude = result.longitude;
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: _latitude != null ? Colors.teal.shade50 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _latitude != null ? Colors.teal : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _latitude != null ? Icons.pin_drop_rounded : Icons.map_rounded,
                          color: _latitude != null ? Colors.teal : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _latitude != null
                                    ? 'Punto exacto marcado'
                                    : 'Marcar posición en mapa (Opcional)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: _latitude != null ? Colors.teal.shade900 : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _latitude != null
                                    ? 'Lat: ${_latitude!.toStringAsFixed(5)}, Lng: ${_longitude!.toStringAsFixed(5)}'
                                    : 'Abre el mapa para seleccionar el lugar preciso del extravío',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: Colors.grey.shade500),
                      ],
                    ),
                  ),
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
                        final Map<String, dynamic> payload = {
                          'event_date': _selectedEventDate?.toIso8601String(),
                          'event_address': _addressController.text.trim(),
                          'latitude': _latitude != null ? double.parse(_latitude!.toStringAsFixed(8)) : null,
                          'longitude': _longitude != null ? double.parse(_longitude!.toStringAsFixed(8)) : null,
                          'comment': _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
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