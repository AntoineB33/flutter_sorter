import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/utils/logger.dart';

class UtilsServices {
  static bool handleDataCorruption(Either<Failure, void> result) {
    return result.fold(
      (failure) {
        logger.e("Problems with local saves");
        return false;
      },
      (result) {
        return true;
      },
    );
  }
}