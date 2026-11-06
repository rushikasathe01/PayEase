class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }

    if (!value.contains('@')) {
      return 'Please enter a valid email';
    }

    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    if (value.length < 6) {
      return 'Password must contain at least 6 characters';
    }

    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name';
    }

    return null;
  }
}
