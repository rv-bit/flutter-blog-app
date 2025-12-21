class MyDatabaseException implements Exception {
	final String message;
	MyDatabaseException(this.message);

	@override
	String toString() => "MyDatabaseException: $message";
}
