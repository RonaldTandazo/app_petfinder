import 'package:flutter/material.dart';
import 'package:app_petfinder/enums/legal/legal_document_type.dart';

class LegalDocumentScreen extends StatelessWidget {
  final LegalDocumentType type;

  const LegalDocumentScreen({
    super.key,
    required this.type,
  });

  String get _title {
    switch (type) {
      case LegalDocumentType.terms:
        return 'Términos y Condiciones';
      case LegalDocumentType.privacy:
        return 'Política de Privacidad';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: switch (type) {
                LegalDocumentType.terms => _buildTerms(theme),
                LegalDocumentType.privacy => _buildPrivacy(theme),
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTerms(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Términos y Condiciones de Uso',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Última actualización: 24 de octubre de 2026',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 24),

        _section(
          theme,
          '1. Aceptación de los términos',
          'Al utilizar PetFinder, aceptas los términos y condiciones '
              'aplicables al uso de la plataforma. Lee este documento '
              'antes de crear tu cuenta.',
        ),

        _section(
          theme,
          '2. Uso de la plataforma',
          'PetFinder facilita la publicación y consulta de información '
              'sobre mascotas en adopción y mascotas extraviadas. '
              'La información publicada debe ser veraz y utilizarse '
              'de forma responsable.',
        ),

        _section(
          theme,
          '3. Responsabilidad del usuario',
          'Cada usuario es responsable de la información que registra '
              'y publica, incluidos los datos de contacto y los detalles '
              'relacionados con las mascotas.',
        ),

        _section(
          theme,
          '4. Cuenta de usuario',
          'El usuario debe proporcionar información correcta durante '
              'el registro y mantener la confidencialidad de sus '
              'credenciales de acceso.',
        ),

        _section(
          theme,
          '5. Eliminación de la cuenta',
          'El usuario puede solicitar la eliminación de su cuenta '
              'mediante los mecanismos habilitados en la plataforma. '
              'El tratamiento de la información se regirá por la '
              'Política de Privacidad.',
        ),

        _section(
          theme,
          '6. Alcance de la plataforma',
          'PetFinder es una herramienta de apoyo para conectar a '
              'personas interesadas en adoptar mascotas y ayudar a '
              'localizar animales extraviados. El uso de la plataforma '
              'no garantiza una adopción ni la recuperación de una mascota.',
        ),

        const SizedBox(height: 16),
        Text(
          'Importante: sustituye y completa estas secciones con la '
          'versión definitiva de tus Términos y Condiciones antes de '
          'publicar la aplicación.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacy(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Política de Privacidad y Protección de Datos Personales',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Última actualización: 24 de octubre de 2026',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 24),

        _section(
          theme,
          '1. Información que recopilamos',
          'PetFinder puede tratar los datos proporcionados durante el '
              'registro, como nombres, apellidos, fecha de nacimiento, '
              'correo electrónico y datos de contacto opcionales, '
              'así como la información y las imágenes que el usuario '
              'publique sobre las mascotas.',
        ),

        _section(
          theme,
          '2. Finalidad del tratamiento',
          'Los datos se utilizan para gestionar las cuentas, permitir '
              'el funcionamiento de las publicaciones y facilitar '
              'el contacto entre usuarios en relación con adopciones '
              'y mascotas extraviadas.',
        ),

        _section(
          theme,
          '3. Almacenamiento de la información',
          'La información se almacena mediante los servicios '
              'tecnológicos configurados para la aplicación. El acceso '
              'y el tratamiento de los datos deben ajustarse a las '
              'medidas de seguridad y obligaciones legales aplicables.',
        ),

        _section(
          theme,
          '4. Ubicación',
          'Las publicaciones pueden incluir ubicaciones relacionadas '
              'con la mascota. La aplicación puede utilizar coordenadas '
              'para calcular distancias, de acuerdo con su funcionamiento '
              'y los permisos que correspondan.',
        ),

        _section(
          theme,
          '5. Derechos del titular',
          'Los usuarios pueden ejercer los derechos que les reconozca '
              'la legislación aplicable sobre sus datos personales, '
              'mediante los canales de contacto habilitados.',
        ),

        _section(
          theme,
          '6. Eliminación de datos',
          'El usuario puede solicitar la eliminación de su cuenta y '
              'de la información asociada, conforme al procedimiento '
              'establecido por la plataforma y las obligaciones legales '
              'de conservación que resulten aplicables.',
        ),

        _section(
          theme,
          '7. Contacto',
          'Para consultas relacionadas con la privacidad y los datos '
              'personales, puedes escribir a pet-finder@gmail.com.',
        ),

        const SizedBox(height: 16),
        Text(
          'Importante: este texto es una estructura inicial y debe '
          'completarse y revisarse antes de publicarlo como política '
          'definitiva.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
      ],
    );
  }

  Widget _section(
    ThemeData theme,
    String title,
    String content,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}