import 'package:app_petfinder/features/adoption/styles/pet_form_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppContactPhoneFields extends StatelessWidget {
  final TextEditingController? mobileController;
  final TextEditingController? homeController;

  final bool showHeader;
  final bool showPhoneMobile;
  final bool showPhoneHome;
  final bool isPhoneMobileRequired;
  final bool isPhoneHomeRequired;

  final String? Function(String?)? mobileValidator;
  final String? Function(String?)? homeValidator;

  const AppContactPhoneFields({
    super.key,
    this.mobileController,
    this.homeController,
    this.showHeader = true,
    this.showPhoneMobile = true,
    this.showPhoneHome = true,
    this.isPhoneMobileRequired = false,
    this.isPhoneHomeRequired = false,
    this.mobileValidator,
    this.homeValidator,
  });

  @override
  Widget build(BuildContext context) {
    if (!showPhoneMobile && !showPhoneHome) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool useTwoColumns = constraints.maxWidth >= 520;

        final fields = <Widget>[
          if (showPhoneMobile)
            _buildMobileField(),

          if (showPhoneMobile && showPhoneHome)
            SizedBox(
              width: useTwoColumns ? 12 : 0,
              height: useTwoColumns ? 0 : 14,
            ),

          if (showPhoneHome)
            _buildHomeField(),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader) ...[
              PetFormStyles.buildSectionHeader(
                'Información de Contacto',
                'Teléfonos de referencia para recibir información',
              ),
              const SizedBox(height: 12),
            ],
            if (useTwoColumns && showPhoneMobile && showPhoneHome)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: fields[0]),
                  const SizedBox(width: 12),
                  Expanded(child: fields[2]),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showPhoneMobile) _buildMobileField(),
                  if (showPhoneMobile && showPhoneHome)
                    const SizedBox(height: 14),
                  if (showPhoneHome) _buildHomeField(),
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _buildMobileField() {
    return TextFormField(
      controller: mobileController,
      keyboardType: TextInputType.phone,
      maxLength: 15,
      validator: mobileValidator ??
          (val) {
            if (isPhoneMobileRequired &&
                (val == null || val.trim().isEmpty)) {
              return 'Ingresa el celular';
            }
            return null;
          },
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d+\s]')),
        TextInputFormatter.withFunction((oldValue, newValue) {
          final text = newValue.text;

          if (text.contains('+') && !text.startsWith('+')) {
            return oldValue;
          }

          if (text.indexOf('+') != text.lastIndexOf('+')) {
            return oldValue;
          }

          final spaceCount = text.split(' ').length - 1;

          if (spaceCount > 1) {
            return oldValue;
          }

          return newValue;
        }),
        LengthLimitingTextInputFormatter(15),
      ],
      decoration: PetFormStyles.inputDecoration(
        'Teléfono Celular${isPhoneMobileRequired ? ' *' : ''}',
        Icons.smartphone_rounded,
      ).copyWith(
        hintText: '+593 987654321',
        counterText: '',
      ),
    );
  }

  Widget _buildHomeField() {
    return TextFormField(
      controller: homeController,
      keyboardType: TextInputType.phone,
      maxLength: 10,
      validator: homeValidator ??
          (val) {
            if (isPhoneHomeRequired &&
                (val == null || val.trim().isEmpty)) {
              return 'Ingresa el convencional';
            }
            return null;
          },
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      decoration: PetFormStyles.inputDecoration(
        'Teléfono Convencional${isPhoneHomeRequired ? ' *' : ''}',
        Icons.phone_rounded,
      ).copyWith(counterText: ''),
    );
  }
}