import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/api/profile/driver_avatar_models.dart';

enum DriverAvatarSource { gallery, camera }

/// Injectable abstraction over `image_picker` so profile photo selection can be
/// tested deterministically without platform channels.
abstract class DriverAvatarPicker {
  Future<PickedAvatarImage?> pick(DriverAvatarSource source);
}

class PlatformDriverAvatarPicker implements DriverAvatarPicker {
  PlatformDriverAvatarPicker({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<PickedAvatarImage?> pick(DriverAvatarSource source) async {
    final file = await _picker.pickImage(
      source: source == DriverAvatarSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    final contentType = _inferContentType(file.name, file.mimeType);
    return PickedAvatarImage(
      bytes: bytes,
      contentType: contentType,
      filename: file.name,
    );
  }

  String _inferContentType(String name, String? mimeType) {
    final normalized = (mimeType ?? '').trim().toLowerCase();
    if (normalized == 'image/png' ||
        normalized == 'image/jpeg' ||
        normalized == 'image/webp') {
      return normalized;
    }
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}

final driverAvatarPickerProvider = Provider<DriverAvatarPicker>(
  (ref) => PlatformDriverAvatarPicker(),
);
