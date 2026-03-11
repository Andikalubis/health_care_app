import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class PermissionHelper {
  /// Request standard permissions sequentially.
  /// Returns true if all essential permissions are granted or not permanently denied in a way that blocks the app.
  static Future<void> requestStandardPermissions() async {
    // We request permissions sequentially to not overwhelm the user and also because
    // requesting them all at once can sometimes cause issues on certain OS versions.

    // 1. Notification Permission
    await Permission.notification.request();

    // 2. Camera Permission
    await Permission.camera.request();

    // 3. Storage/Gallery Permission
    // On Android 13+, READ_EXTERNAL_STORAGE is deprecated and READ_MEDIA_IMAGES is used.
    // The permission_handler package handles this mapping nicely under the hood for `storage` or `photos`.
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await Permission.photos.request();
    } else {
      // For Android, storage is the most appropriate general permission for gallery/files
      await Permission.storage.request();
      // On Android 13+, we might also need to request photos explicitly if we need them
      await Permission.photos.request();
    }
  }
}
