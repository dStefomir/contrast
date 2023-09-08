import 'package:contrast/security/session.dart';
import 'package:contrast/utils/device.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Provider for the photograph details service
final photographDetailsServiceProvider = Provider<PhotographDetailsService>((ref) => PhotographDetailsService());
/// Photograph details service
class PhotographDetailsService {
  /// Fetch a single image
  String getPhotograph(BuildContext context, String imagePath) => '${Session.proxy.host}/files/image?image_path=$imagePath&compressed=false&platform=DESKTOP';
}