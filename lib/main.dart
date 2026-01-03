import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logging/logging.dart';

import 'package:flutter_blog_app/core/database/migration_utils.dart';

import 'app/app.dart'; 


void main() async {
	WidgetsFlutterBinding.ensureInitialized();

	// debugPaintSizeEnabled = true;
  
	// Set up logging
	Logger.root.level = Level.ALL;
	Logger.root.onRecord.listen((rec) {
		stderr.writeln('${rec.time} [${rec.loggerName}] ${rec.level.name}: ${rec.message}');
		if (rec.error != null) stderr.writeln('Error: ${rec.error}');
		if (rec.stackTrace != null) stderr.writeln(rec.stackTrace);
	});

	// Check migration status (optional, for debugging)
	await MigrationUtils.printCurrentVersion();
	MigrationUtils.printAllMigrations();
	await MigrationUtils.checkMigrationStatus();

	// await MigrationUtils.resetDatabase();
	
	runApp(const ProviderScope(child: App()));
}
