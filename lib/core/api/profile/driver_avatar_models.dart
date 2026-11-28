import 'dart:typed_data';

class DriverAvatarUploadIntentDto {
  const DriverAvatarUploadIntentDto({
    required this.intentId,
    required this.objectKey,
    required this.uploadUrl,
    required this.uploadMethod,
    required this.uploadHeaders,
    required this.expiresAt,
  });

  factory DriverAvatarUploadIntentDto.fromJson(Map<String, dynamic> json) {
    final headersRaw = json['uploadHeaders'] as Map<String, dynamic>? ?? const {};
    return DriverAvatarUploadIntentDto(
      intentId: (json['intentId'] as String?) ?? '',
      objectKey: (json['objectKey'] as String?) ?? '',
      uploadUrl: (json['uploadUrl'] as String?) ?? '',
      uploadMethod: (json['uploadMethod'] as String?) ?? 'PUT',
      uploadHeaders: headersRaw.map((k, v) => MapEntry(k, v.toString())),
      expiresAt: (json['expiresAt'] as String?) ?? '',
    );
  }

  final String intentId;
  final String objectKey;
  final String uploadUrl;
  final String uploadMethod;
  final Map<String, String> uploadHeaders;
  final String expiresAt;
}

class DriverAvatarResponseDto {
  const DriverAvatarResponseDto({required this.avatarUrl});

  factory DriverAvatarResponseDto.fromJson(Map<String, dynamic> json) {
    return DriverAvatarResponseDto(avatarUrl: json['avatarUrl'] as String?);
  }

  final String? avatarUrl;
}

class PickedAvatarImage {
  const PickedAvatarImage({
    required this.bytes,
    required this.contentType,
    required this.filename,
  });

  final Uint8List bytes;
  final String contentType;
  final String filename;
}
