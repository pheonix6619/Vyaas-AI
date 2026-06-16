import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Provides the current app version and build number.
final appVersionProvider = FutureProvider<PackageInfo>((ref) async {
  return await PackageInfo.fromPlatform();
});
