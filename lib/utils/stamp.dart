// ignore_for_file: avoid_print

import 'dart:developer';

import 'package:flutter/foundation.dart';

ValueNotifier<String> errorText = ValueNotifier("");

void stamp(
  String tag,
  String message, {
  bool useLog = false,
  String decoratorChar = "",
  String decoratorCharStart = "",
  String decoratorCharEnd = "",
  bool extraLine = true,
}) {
  if (kDebugMode) {
    errorText.value =
        errorText.value.isEmpty ? message : "$message\n\n${errorText.value}";
  }

  if (kDebugMode && useLog) {
    _useLogFunction(
      decoratorChar,
      tag,
      message,
      decoratorCharStart,
      decoratorCharEnd,
      extraLine,
    );
  } else if (kDebugMode && !useLog) {
    _usePrintFunction(
      decoratorChar,
      tag,
      message,
      decoratorCharStart,
      decoratorCharEnd,
      extraLine,
    );
  }
}

void _useLogFunction(
  String decoratorChar,
  String tag,
  String message,
  String decoratorCharStart,
  String decoratorCharEnd,
  bool extraLine,
) {
  if (decoratorChar != "") {
    log('[$tag]: $decoratorChar$message$decoratorChar${extraLine ? "\n" : ""}');
    return;
  }

  if (decoratorCharStart != "" && decoratorCharEnd != "") {
    log(
      '[$tag]: $decoratorCharStart$message$decoratorCharEnd${extraLine ? "\n" : ""}',
    );
    return;
  }

  log('[$tag]: $message${extraLine ? "\n" : ""}');
}

void _usePrintFunction(
  String decoratorChar,
  String tag,
  String message,
  String decoratorCharStart,
  String decoratorCharEnd,
  bool extraLine,
) {
  if (decoratorChar != "") {
    print(
      '[$tag]: $decoratorChar$message$decoratorChar${extraLine ? "\n" : ""}',
    );
    return;
  }

  if (decoratorCharStart != "" && decoratorCharEnd != "") {
    print(
      '[$tag]: $decoratorCharStart$message$decoratorCharEnd${extraLine ? "\n" : ""}',
    );
    return;
  }

  print('[$tag]: $message${extraLine ? "\n" : ""}');
}
