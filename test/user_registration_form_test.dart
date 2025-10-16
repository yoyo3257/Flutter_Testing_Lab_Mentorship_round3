import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_lab/utils/validators_urf.dart';

void main() {
  group('User Registration form test', () {
    group('validatePassword', () {
      test('returns error when password is empty', () {
        expect(validatePassword(''), 'Password is required.');
      });

      test('returns error when password is too short', () {
        expect(
          validatePassword('Ab1@'),
          'Password must be at least 8 characters long.',
        );
      });

      test('missing uppercase', () {
        expect(
          validatePassword('password1@'),
          'Password must contain at least one uppercase letter.',
        );
      });

      test('missing lowercase', () {
        expect(
          validatePassword('PASSWORD1@'),
          'Password must contain at least one lowercase letter.',
        );
      });

      test('missing number', () {
        expect(
          validatePassword('Password@'),
          'Password must contain at least one number.',
        );
      });

      test('missing special char', () {
        expect(
          validatePassword('Password1'),
          'Password must contain at least one special character.',
        );
      });

      test('valid password returns null', () {
        expect(validatePassword('Password1@'), null);
      });
    });

    group('validate Email', () {
      test('Empty email field', () {
        expect(validateEmail(''), 'Please enter your email');
      });
      test('validate Email', () {
        expect(validateEmail('yasminhany@gmail.com'), null);
      });
      test('validate Email', () {
        expect(validateEmail('yasminhany@gma'), 'Please enter a valid email');
      });
    });
  });

}
