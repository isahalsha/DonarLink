import 'package:flutter/services.dart';

class CapitalizeFirstThreeLettersInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String formattedText = newValue.text;
    if (newValue.text.isNotEmpty) {
      String capitalizedPart = '';
      if (newValue.text.length >= 3) {
        capitalizedPart =
            newValue.text.substring(0, 3).toUpperCase() +
            newValue.text.substring(3);
      } else {
        capitalizedPart = newValue.text.toUpperCase();
      }

      formattedText = capitalizedPart;

      final parts = newValue.text.split(' ');
      final capitalizedParts =
          parts.map((part) {
            if (part.isNotEmpty) {
              if (part.length >= 3) {
                return part.substring(0, 3).toUpperCase() + part.substring(3);
              } else {
                return part.toUpperCase();
              }
            }
            return part;
          }).toList();
      formattedText = capitalizedParts.join(' ');
    }

    return newValue.copyWith(
      text: formattedText,
      selection: newValue.selection,
    );
  }
}
