import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'secure_session_storage.dart';

final secureSessionStorageProvider = Provider<SecureSessionStorage>((ref) => FlutterSecureSessionStorage());
