/// A collection of form field validators to ensure data integrity
class Validators {
  /// Validates that the field is not empty
  static String? required(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  /// Validates that the field is a valid email address
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Allow empty if not required
    }

    // RFC 5322 compliant email regex
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$",
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validates that the field is a valid password
  /// (at least 8 characters with a mix of letters, numbers, and special characters)
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Allow empty if not required
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  /// Validates that the field matches a specific value (useful for password confirmation)
  static String? Function(String?) matches(String? original, String fieldName) {
    return (String? confirmation) {
      if (confirmation == null || confirmation.isEmpty) {
        return null; // Allow empty if not required
      }

      if (confirmation != original) {
        return 'Doesn\'t match $fieldName';
      }

      return null;
    };
  }

  /// Validates that the field is within a certain length range
  static String? Function(String?) length(int min, int max) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return null; // Allow empty if not required
      }

      if (value.length < min) {
        return 'Must be at least $min characters';
      }

      if (value.length > max) {
        return 'Must be less than $max characters';
      }

      return null;
    };
  }

  /// Validates that the field is a number
  static String? number(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Allow empty if not required
    }

    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }

    return null;
  }

  /// Validates that the field is an integer
  static String? integer(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Allow empty if not required
    }

    if (int.tryParse(value) == null) {
      return 'Please enter a valid integer';
    }

    return null;
  }

  /// Validates that the field is within a numeric range
  static String? Function(String?) range(double min, double max) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return null; // Allow empty if not required
      }

      final number = double.tryParse(value);
      if (number == null) {
        return 'Please enter a valid number';
      }

      if (number < min) {
        return 'Value must be at least $min';
      }

      if (number > max) {
        return 'Value must be at most $max';
      }

      return null;
    };
  }

  /// Validates that the field only contains letters
  static String? letters(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Allow empty if not required
    }

    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Please enter only letters';
    }

    return null;
  }

  /// Validates that the field only contains letters and numbers
  static String? alphanumeric(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Allow empty if not required
    }

    if (!RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(value)) {
      return 'Please enter only letters and numbers';
    }

    return null;
  }

  /// Validates that the field is a valid phone number
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Allow empty if not required
    }

    // Basic phone validation (adjust for your region)
    final cleanedValue = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!RegExp(r'^[+]?[0-9]{10,15}$').hasMatch(cleanedValue)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validates that the field is a valid URL
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Allow empty if not required
    }

    final urlRegex = RegExp(
      r'^(https?:\/\/)?(www\.)?([-a-z0-9]{1,63}\.)*?[a-z0-9][-a-z0-9]{0,61}[a-z0-9]\.[a-z]{2,6}(\/[-\w@\+\.~#\?&\/=%]*)?$',
      caseSensitive: false,
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  /// Validates that the field matches a specific pattern
  static String? Function(String?) pattern(RegExp regex, String errorMessage) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return null; // Allow empty if not required
      }

      if (!regex.hasMatch(value)) {
        return errorMessage;
      }

      return null;
    };
  }

  /// Validates that the field has a minimum number of words
  static String? Function(String?) minWords(int count) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return null; // Allow empty if not required
      }

      final words = value.trim().split(RegExp(r'\s+'));
      if (words.length < count) {
        return 'Please enter at least $count words';
      }

      return null;
    };
  }

  /// Combines multiple validators
  static String? Function(String?) compose(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) {
          return result;
        }
      }

      return null;
    };
  }

  /// Creates a required version of any validator
  static String? Function(String?) requiredWith(String? Function(String?) validator) {
    return (String? value) {
      final requiredCheck = required(value);
      if (requiredCheck != null) {
        return requiredCheck;
      }

      return validator(value);
    };
  }

  /// Validates a username (alphanumeric with some special characters)
  static String? username(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Allow empty if not required
    }

    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }

    if (value.length > 20) {
      return 'Username must be less than 20 characters';
    }

    if (!RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, dots, underscores, and hyphens';
    }

    return null;
  }

  /// Validates that the field does not exceed a max word count
  static String? Function(String?) maxWords(int count) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return null; // Allow empty if not required
      }

      final words = value.trim().split(RegExp(r'\s+'));
      if (words.length > count) {
        return 'Please enter no more than $count words';
      }

      return null;
    };
  }
}