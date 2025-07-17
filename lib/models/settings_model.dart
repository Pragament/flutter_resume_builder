enum CompressionOption { maxFileSize, quality }

class Settings {
  final double? maxFileSize;
  final double quality;
  final CompressionOption selectedOption;

  Settings({
    this.maxFileSize,
    required this.quality,
    required this.selectedOption,
  });

  Settings copyWith({
    double? maxFileSize,
    double? quality,
    CompressionOption? selectedOption,
  }) {
    return Settings(
      maxFileSize: maxFileSize ?? this.maxFileSize,
      quality: quality ?? this.quality,
      selectedOption: selectedOption ?? this.selectedOption,
    );
  }
}
