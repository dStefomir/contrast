import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// import 'dart:html' as html;


/// Determines if the app should load a mobile or other type of layout based on calculated pixels
bool useMobileLayout(BuildContext context, {int shortestSideLimit = 670}) {
  /// The equivalent of the "smallestWidth" qualifier on Android.
  var shortestSide = MediaQuery.of(context).size.shortestSide;  // it's in dps
  /// Determine if we should use mobile layout or not. The
  /// number 600 is a common breakpoint for a typical 7-inch tablet.
  return shortestSide < shortestSideLimit;
}

/// Determines the correct scaling of pixels based on the device the app is ran on
double getScaledPixels(BuildContext context, double pixels) {
  final double pixelScale = MediaQuery.of(context).devicePixelRatio;
  if(pixelScale > 1) {
    return pixels * pixelScale;
  } else {
    return pixels / 0.5;
  }
}

/// Gets the running platform based on the layout of the device
String getRunningPlatform(BuildContext context) {
  if(defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) {
    return 'MOBILE';
  }
  // if (_isIpad()) {
  //   return 'MOBILE';
  // }

  return 'DESKTOP';
}

/// Check if the app is ran on an ipad
// bool _isIpad() {
//   final width = html.window.screen?.width;
//   final height = html.window.screen?.height;
//   final ratio = width! / height!;
//
//   return ratio <= 1.34 && ratio >= 1.32;
// }