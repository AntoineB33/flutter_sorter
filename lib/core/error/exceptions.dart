import 'dart:io';

/// Thrown when the local cache is empty or missing.
class CacheNotFoundException extends CacheException {}

/// Thrown when the local cache data is corrupted or malformed.
class CacheParsingException extends CacheException {
  CacheParsingException(FormatException super.e);
}

/// A generic cache exception.
class CacheException implements Exception {
  final Object? e;

  CacheException([this.e]);
}

class FileNotFoundException extends CacheException {
  FileNotFoundException(FileSystemException super.e);

  FileSystemException get typedE => e as FileSystemException;

  @override
  String toString() => 'File not found: ${typedE.path}';

}