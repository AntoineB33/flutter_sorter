import 'package:logger/logger.dart';

final Logger logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,        // Removes the stack trace for non-errors to keep logs clean
    errorMethodCount: 5,   // Shows 5 lines of stack trace if an error occurs
    colors: true,          // Colorful output
    printEmojis: true,     // Adds emojis (🚀 for info, 🐛 for debug, etc.)
  ),
);