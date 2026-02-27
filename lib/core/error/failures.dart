import 'dart:io';

abstract class Failure {}

/// Thrown when the local cache is empty or missing.
class CacheNotFoundFailure implements Failure {}

/// Thrown when the local cache data is corrupted or malformed.
class CacheParsingFailure implements Failure {
  final FormatException e;

  CacheParsingFailure(this.e);
}

/// A generic cache exception.
class CacheFailure implements Failure {
  final Object? e;

  CacheFailure([this.e]);
}

class FileNotFoundFailure implements Failure {
  final FileSystemException e;

  FileNotFoundFailure(this.e);

  @override
  String toString() => 'File not found: ${e.path}';

}