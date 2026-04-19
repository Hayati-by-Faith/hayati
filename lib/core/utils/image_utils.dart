class ImageUtils {
  const ImageUtils._();

  static bool isSupportedExtension(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg');
  }
}
