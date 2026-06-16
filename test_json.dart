import 'dart:convert';
import 'dart:io';

void main() {
  final dir = Directory('assets/data/quotes');
  if (!dir.existsSync()) {
    print('Directory does not exist');
    return;
  }
  
  int total = 0;
  int invalid = 0;
  
  for (final file in dir.listSync()) {
    if (file is File && file.path.endsWith('.json')) {
      total++;
      try {
        final content = file.readAsStringSync();
        json.decode(content);
      } catch (e) {
        print('Invalid JSON in ${file.path}: $e');
        invalid++;
      }
    }
  }
  
  print('Total JSON files: $total');
  print('Invalid JSON files: $invalid');
}
