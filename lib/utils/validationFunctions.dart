// Validation functions
String? validateName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Παρακαλώ εισάγετε το όνομα σας.';
  }
  return null;
}

String? validateLastName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Παρακαλώ εισάγετε το επώνυμο σας.';
  }
  return null;
}

String? validatePhone(String? value) {
  if (value == null || value.isEmpty) {
    return 'Παρακαλώ εισάγετε τον αριθμό τηλεφώνου σας.';
  }
  if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
    return 'Ο αριθμός τηλεφώνου δεν είναι έγκυρος.';
  }
  return null;
}

String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Παρακαλώ εισάγετε το email σας.';
  }
  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
    return 'Το email δεν είναι έγκυρο.';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Παρακαλώ εισάγετε τον κωδικό σας.';
  }
  if (value.length < 6) {
    return 'Ο κωδικός πρέπει να είναι τουλάχιστον 6 χαρακτήρες.';
  }
  return null;
}
