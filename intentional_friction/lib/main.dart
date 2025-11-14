import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/storage_service.dart';
import 'providers/friction_providers.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  final storage = StorageService();
  await storage.initialize();

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storage),
      ],
      child: const IntentionalFrictionApp(),
    ),
  );
}
