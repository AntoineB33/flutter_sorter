import 'dart:io';

/// Thrown when the local cache is empty or missing.
class CacheNotFoundException implements Exception {}

/// Thrown when the local cache data is corrupted or malformed.
class CacheParsingException implements Exception {
  final FormatException e;

  CacheParsingException(this.e);
}

/// A generic cache exception.
class CacheException implements Exception {
  final Object? e;

  CacheException([this.e]);
}

class FileNotFoundException implements Exception {
  final FileSystemException e;

  FileNotFoundException(this.e);

  @override
  String toString() => 'File not found: ${e.path}';

}