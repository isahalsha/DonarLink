import 'package:flutter/services.dart';

class CapitalizeFirstLetterInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String formattedText = newValue.text;

    if (oldValue.text.isEmpty ||
        (newValue.text.length > oldValue.text.length &&
            newValue.text[newValue.selection.start - 1] == ' ')) {
      if (newValue.text.isNotEmpty) {
        String firstLetter = newValue.text[0].toUpperCase();
        String rest = newValue.text.substring(1);
        formattedText = firstLetter + rest;

        if (newValue.selection.start > 1 &&
            newValue.text[newValue.selection.start - 1] == ' ') {
          final parts = newValue.text.split(' ');
          final capitalizedParts =
              parts.map((part) {
                if (part.isNotEmpty) {
                  return part[0].toUpperCase() + part.substring(1);
                }
                return part;
              }).toList();
          formattedText = capitalizedParts.join(' ');
        }
      }
    }

    return newValue.copyWith(
      text: formattedText,
      selection: newValue.selection,
    );
  }
}
