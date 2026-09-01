import 'package:app_petfinder/widgets/snackbars/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:app_petfinder/core/network/api_exception.dart';

class ApiErrorHandler {
  static void handle(BuildContext context, ApiException e) {
    if (!context.mounted) return;

    String errorDetail = e.message;

    if (e.error is Map<String, dynamic>) {
      final validationErrors = e.error as Map<String, dynamic>;
      if (validationErrors.isNotEmpty) {
        final firstKey = validationErrors.keys.first;
        final firstValue = validationErrors[firstKey];

        if (firstValue is List && firstValue.isNotEmpty) {
          errorDetail = firstValue[0].toString();
        } else if (firstValue is String) {
          errorDetail = firstValue;
        }
      }
    }

    AppSnackBar.show(
      context,
      title: errorDetail,
      type: SnackBarType.error,
    );
  }
}