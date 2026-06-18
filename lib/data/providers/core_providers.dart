import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/dio_client.dart';
import '../services/secure_storage_service.dart';

/// Central DioClient provider - single instance with auth token management
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(secureStorage: SecureStorageService());
});