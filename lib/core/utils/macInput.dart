import 'package:flutter/material.dart';

class MacInput {
  String formatMacAddress(String cleanMac) {
    int grouppedCharacters = 0;
    String formattedMac = "";
    for (int i = 0; i < cleanMac.length; ++i) {
      formattedMac += cleanMac[i];
      ++grouppedCharacters;
      if (grouppedCharacters == 2) {
        formattedMac += ":";
        grouppedCharacters = 0;
      }
    }
    if (cleanMac.length == 12) {
      formattedMac = formattedMac.substring(0, formattedMac.length - 1);
    }
    return formattedMac;
  }

  String clearNonMacCharacters(String mac) {
    return mac.replaceAll(RegExp('[^A-Fa-f0-9]'), "");
  }

  String mPreviousMac;
  String handleColonDeletion(String text, String formatMac, int selectionStart) {
    if (mPreviousMac != null && mPreviousMac.length > 1) {
      int previousColonCount = colonCount(mPreviousMac);
      int currentColonCount = colonCount(text);

      if (currentColonCount < previousColonCount) {
        formatMac = formatMac.substring(0, selectionStart - 1) + formatMac.substring(selectionStart);
        String cleanMac = clearNonMacCharacters(formatMac);
        formatMac = formatMacAddress(cleanMac);
      }
    }
    return formatMac;
  }

  int colonCount(String formatMac) {
    return formatMac.replaceAll(RegExp("[^:]"), "").length;
  }

  void macChange(String text, TextEditingController et) {
    String cleanMac = clearNonMacCharacters(text.toUpperCase());
    String formatMac = formatMacAddress(cleanMac);
    int selectionStart = et.selection.start;
    formatMac = handleColonDeletion(text, formatMac, selectionStart);
    int lengthDiff = formatMac.length - cleanMac.length;
    setMacEdit(cleanMac, formatMac, selectionStart, lengthDiff, et);
  }

  void setMacEdit(String cleanMac, String formattedMac, int start, int length, TextEditingController _etmac) {
    // _etmac.removeListener(() {});
    if (cleanMac.length <= 12) {
      _etmac.text = formattedMac;
      _etmac.selection = TextSelection.fromPosition(TextPosition(offset: _etmac.text.length));
      mPreviousMac = formattedMac;
    } else {
      _etmac.text = formattedMac;
      _etmac.selection = TextSelection.fromPosition(TextPosition(offset: mPreviousMac.length));
    }
    // _etmac.addListener(() => macChange(_etmac.text, _etmac));
  }
}
