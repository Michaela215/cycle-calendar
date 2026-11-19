import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cycle_calendar/profile_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('US-04 Validace jména', () {
    test('Allowlist: povolené a zakázané vstupy', () {
      expect(ProfileStorage.isValidName('Míšo'), isTrue);
      expect(ProfileStorage.isValidName('Anna-Marie'), isTrue);
      expect(ProfileStorage.isValidName("O'Neil"), isTrue);
      expect(ProfileStorage.isValidName(''), isFalse);
      expect(ProfileStorage.isValidName('<script>'), isFalse);
      expect(ProfileStorage.isValidName('Míša123'), isFalse);
      expect(ProfileStorage.isValidName('a' * 31), isFalse);
    });

    test('Podvržené jméno v úložišti se nepoužije', () async {
      FlutterSecureStorage.setMockInitialValues({'user_name': '<script>'});
      final name = await ProfileStorage().loadName();
      expect(name, '');
    });
  });
}
