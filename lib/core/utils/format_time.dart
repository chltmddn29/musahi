DateTime parsedTime(String dateString) {
  return DateTime.parse(dateString.replaceAll('/', '-'));
}