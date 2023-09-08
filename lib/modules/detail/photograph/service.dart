import 'package:contrast/security/session.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Provider for the photograph details service
final photographDetailsServiceProvider = Provider<PhotographDetailsService>((ref) => PhotographDetailsService());
/// Photograph details service
class PhotographDetailsService {
  /// Fetch a single image
  String getPhotograph(String imagePath) => '${Session.proxy.host}/files/image?image_path=$imagePath&compressed=false&platform=DESKTOP';
}