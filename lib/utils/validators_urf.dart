bool isValidEmail(String email) {
  return RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  ).hasMatch(email);
}

String? validateEmail(value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your email';
  }
  if (!isValidEmail(value)) {
    return 'Please enter a valid email';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required.';
  }

  // Minimum length check
  if (value.length < 8) {
    return 'Password must be at least 8 characters long.';
  }

  // Uppercase letter check
  if (!RegExp(r'[A-Z]').hasMatch(value)) {
    return 'Password must contain at least one uppercase letter.';
  }

  // Lowercase letter check
  if (!RegExp(r'[a-z]').hasMatch(value)) {
    return 'Password must contain at least one lowercase letter.';
  }

  // Number check
  if (!RegExp(r'[0-9]').hasMatch(value)) {
    return 'Password must contain at least one number.';
  }

  // Special character check (customize the allowed special characters as needed)
  if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
    return 'Password must contain at least one special character.';
  }

  return null; // Password is valid
}
