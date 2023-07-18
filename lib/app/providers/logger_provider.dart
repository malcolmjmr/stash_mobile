import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

final loggerProvider = Provider<Logger>((ref) => Logger(
      printer: PrettyPrinter(
        lineLength: 200,
        methodCount: 1,
        printEmojis: false,
      ),
    ));
