import 'package:app_petfinder/core/network/api_client.dart';

class ImageUrlHelper {
  ImageUrlHelper._();

  static String resolve(String url) {
    if (url.isEmpty) return url;

    final uri = Uri.tryParse(url);
    if (uri == null || uri.host != 'host.docker.internal') return url;

    return uri.replace(host: ApiClient.baseUrlHost).toString();
  }
}