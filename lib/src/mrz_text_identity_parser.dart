import 'package:ad_hoc_ident/ad_hoc_ident.dart';
import 'package:ad_hoc_ident_ocr/ad_hoc_ident_ocr.dart';
import 'package:mrz_parser/mrz_parser.dart';

import 'mrz_format.dart';

/// Tries to parse text data to an [AdHocIdentity].
///
/// Parsable data needs to conform to the MRZ standard.
class MrzTextIdentityParser implements OcrIdentityParser {
  final Set<MrzFormat> validFormats;

  /// Creates an [MrzTextIdentityParser].
  ///
  /// The text is checked against the [validFormats]' line length and line
  /// count before evaluating the actual contents. Special characters are
  /// mapped to the placeholder character '<' and whitespace is removed.
  MrzTextIdentityParser({
    this.validFormats = MrzFormat.commonMrzFormats,
  });

  @override
  Future<AdHocIdentity?> parse(List<List<String>> blocksAndLines) async {
    if (blocksAndLines.isEmpty ||
        blocksAndLines.every(
          (block) => block.isEmpty,
        )) {
      return null;
    }

    final allowedLineLengths =
        validFormats.map((format) => format.lineLength).toSet();

    final Map<int, List<String>> formatCompliantLines = {};

    // flatten, trim, check valid length, adjust characters and group by length
    blocksAndLines
        .map((block) => block.map((line) => line.split(RegExp(r'\\n'))))
        .fold(
            const Iterable<String>.empty(),
            (block1, block2) => block1.followedBy(block2.fold(
                const Iterable<String>.empty(),
                (previousValue, splitLines) =>
                    previousValue.followedBy(splitLines))))
        .map(
            (line) => line.replaceAll(' ', '').replaceAll(RegExp('_|\\W'), '<'))
        .forEach((line) {
      if (allowedLineLengths.contains(line.length)) {
        final compliantLines = formatCompliantLines[line.length] ??= [];
        compliantLines.add(line);
      }
    });

    if (formatCompliantLines.isEmpty) {
      return null;
    }

    for (MrzFormat format in validFormats) {
      final lines = formatCompliantLines[format.lineLength];
      if (lines == null || lines.length < format.lineCount) {
        continue;
      }

      // check the group, assuming the detected lines are in correct order
      // to avoid iterating all possible line permutations
      for (int i = 0; i <= lines.length - format.lineCount; i++) {
        final selectedLines = lines.getRange(i, i + format.lineCount).toList();
        final MRZResult? mrz = MRZParser.tryParse(selectedLines);
        if (mrz != null) {
          return _mrzToIdentity(mrz);
        }
      }
    }

    return null;
  }

  AdHocIdentity _mrzToIdentity(MRZResult result) {
    final identity = AdHocIdentity(
        type: 'ocr.mrz',
        identifier: result.documentNumber +
            result.expiryDate.toUtc().toIso8601String());
    return identity;
  }
}
