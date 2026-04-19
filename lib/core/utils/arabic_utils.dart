class ArabicUtils {
  const ArabicUtils._();

  static String normalizeDigits(String input) {
    const arabicIndic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    var output = input;
    for (var i = 0; i < arabicIndic.length; i++) {
      output = output.replaceAll(arabicIndic[i], western[i]);
    }
    return output;
  }
}
