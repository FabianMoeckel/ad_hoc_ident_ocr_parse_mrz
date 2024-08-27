/// Defines a MRZ format by its line length and line count.
class MrzFormat {
  /// All three supported MRZ formats.
  static const Set<MrzFormat> commonMrzFormats = {
    threeLine,
    twoLineShort,
    twoLineLong,
  };

  /// TD1 MRZ format.
  static const MrzFormat threeLine = MrzFormat(lineLength: 30, lineCount: 3);

  /// TD2 OR MRV-B MRZ format.
  static const MrzFormat twoLineShort = MrzFormat(lineLength: 36, lineCount: 2);

  /// TD3 OR MRV-A MRZ format.
  static const MrzFormat twoLineLong = MrzFormat(lineLength: 44, lineCount: 2);

  /// The characters per line of this format.
  final int lineLength;

  /// The number of lines of this format.
  final int lineCount;

  /// Creates a new MRZ format with the specified [lineLength] and [lineCount]].
  ///
  /// Consider using the static constants instead of creating your own MRZ
  /// format instance. The given [MrzTextIdentityParser] implementation
  /// only supports these formats.
  const MrzFormat({required this.lineLength, required this.lineCount});
}
