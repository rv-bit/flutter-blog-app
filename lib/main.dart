import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logging/logging.dart';

import 'package:flutter_blog_app/core/database/migration_utils.dart';

import 'app/app.dart'; 

void main() async {
	WidgetsFlutterBinding.ensureInitialized();
  
	// Set up logging
	Logger.root.level = Level.ALL;

	// Check migration status (optional, for debugging)
	await MigrationUtils.printCurrentVersion();
	MigrationUtils.printAllMigrations();
	await MigrationUtils.checkMigrationStatus();

	// await MigrationUtils.resetDatabase();
	
	runApp(const ProviderScope(child: App()));
}
