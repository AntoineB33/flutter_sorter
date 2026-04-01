

abstract class Failure {
  final String message;
  Failure(this.message);
}

class DatabaseFailure extends Failure {
  DatabaseFailure(super.message);
}

class ClipboardEmptyFailure extends Failure {
  ClipboardEmptyFailure() : super('Clipboard is empty');
}

class ClipboardUnsupportedCharactersFailure extends Failure {
  ClipboardUnsupportedCharactersFailure() : super('Clipboard contains unsupported characters');
}