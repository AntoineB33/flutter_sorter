import 'dart:io';

import 'package:trying_flutter/core/error/exceptions.dart';

abstract class Failure {}

/// Thrown when the local cache is empty or missing.
class CacheNotFoundFailure implements Failure {}

/// Thrown when the local cache data is corrupted or malformed.
class CacheParsingFailure implements Failure {
  final CacheParsingException e;

  CacheParsingFailure(this.e);
}

/// A generic cache exception.
class CacheFailure implements Failure {
  final CacheException? e;

  CacheFailure([this.e]);
}

class FileNotFoundFailure implements Failure {
  final FileSystemException e;

  FileNotFoundFailure(this.e);

  @override
  String toString() => 'File not found: ${e.path}';

}

class CacheRepairedFailure implements Failure {
  bool sortStatusChanged = false;
  bool workbookCacheChanged = false;
  bool selectionCacheChanged = false;

  CacheRepairedFailure({
    this.sortStatusChanged = false,
    this.workbookCacheChanged = false,
    this.selectionCacheChanged = false,
  });
}

class ClipboardEmptyFailure implements Failure {}

class ClipboardUnsupportedCharactersFailure implements Failure {}