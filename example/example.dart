library parser;

import 'dart:json' as JSON;
import '../lib/mezoni_parser.dart';

part 'web_app_parser.dart';
part 'data.dart';

void main() {
  var parser = new WebAppParser();
  var data = JSON.parse(jsonData);
  var webapp = parser.parse(data);

  if(parser.errors.length > 0) {
    parser.errors.forEach((error) {
      print(error);
    });

    return;
  }

  var sep = '-------------------';

  print('Servlet count: ${webapp.servlet.length}');
  print(sep);

  webapp.servlet.forEach((servlet) {
    print('Servlet: ${servlet.name}');
  });
  print(sep);

  webapp.servlet.forEach((servlet) {
    print('Servlet: ${servlet.name}');
    print('Servlet params (${servlet.initParams.length})');
    servlet.initParams.keys.forEach((key) {
      print('  $key: ${servlet.initParams[key]}');
    });
    print(sep);
  });

  print('Mappings:');
  webapp.mappings.keys.forEach((key) {
    print('  $key: ${webapp.mappings[key].url}');
  });
  print(sep);
}
