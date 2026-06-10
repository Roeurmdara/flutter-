import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sync_service.dart';
import 'community_provider.dart';
import 'auth_provider.dart';
import 'habit_provider.dart';

/// Provider for SyncService
final syncServiceProvider = Provider<SyncService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final syncService = SyncService(dioClient);

  ref.onDispose(() {
    syncService.disconnect();
  });

  return syncService;
});

/// Connection manager provider that reactively handles WebSocket connection status based on Authentication state.
/// This provider must be watched at the root of the app or in the home screen to remain active.
final syncConnectionManagerProvider = Provider<void>((ref) {
  final authState = ref.watch(authProvider);
  final syncService = ref.watch(syncServiceProvider);

  if (authState.isAuthenticated && authState.user != null) {
    final userId = authState.user!.id;
    
    // Connect to WebSocket in next microtask
    Future.microtask(() {
      syncService.connect(userId);
    });

    // Automatically trigger loadHabits when receiving database sync events
    void onSyncEvent() {
      debugPrint('🔄 SyncProvider: Received sync event! Reloading habits...');
      ref.read(habitsProvider.notifier).loadHabits();
    }

    syncService.addListener(onSyncEvent);

    ref.onDispose(() {
      syncService.removeListener(onSyncEvent);
    });
  } else {
    // User is logged out, ensure the connection is closed
    Future.microtask(() {
      syncService.disconnect();
    });
  }
});
