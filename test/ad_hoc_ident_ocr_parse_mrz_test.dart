import 'package:ad_hoc_ident/ad_hoc_ident.dart';
import 'package:ad_hoc_ident_ocr_parse_mrz/ad_hoc_ident_ocr_parse_mrz.dart';
import 'package:test/test.dart';

void main() {
  test('successfully parses an mrz without any required adjustments', () async {
    const docNum = 'LZ6311T47';
    const docExpiryStr = '311031';
    final docExpiry = DateTime.parse('20$docExpiryStr');
    const mrzLines = [
      'IDD<<${docNum}5<<<<<<<<<<<<<<<',
      '8308126<${docExpiryStr}5D<<2108<<<<<<<9',
      'MUSTERMANN<<ERIKA<<<<<<<<<<<<<'
    ];
    final expectedResult = AdHocIdentity(
        type: 'ocr.mrz',
        identifier: '$docNum${docExpiry.toUtc().toIso8601String()}');
    final parser = MrzTextIdentityParser();

    final detectedIdentity = await parser.parse([mrzLines]);

    expect(detectedIdentity, expectedResult);
  });
}
