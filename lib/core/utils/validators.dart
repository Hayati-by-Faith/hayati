class Validators {
  const Validators._();

  static bool isRequired(String? value) {
    return value == null || value.trim().isEmpty;
  }

  static bool isValidHouseholdSize(String? value) {
    final parsed = int.tryParse(value ?? '');
    return parsed != null && parsed > 0;
  }
}
