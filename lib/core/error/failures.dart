import 'dart:io';

import 'package:trying_flutter/core/error/exceptions.dart';

abstract class Failure {
  final String message;
  Failure(this.message);
}

class DatabaseFailure extends Failure {
  DatabaseFailure(super.message);
}