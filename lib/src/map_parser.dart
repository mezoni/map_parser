part of map_parser;

typedef dynamic ParserCallback(String key, dynamic value, dynamic prevValue);

/* Fast structure parser */
class MapParser {
  List<String> errors = [];

  Map<String, ParserCallback> format;

  String _acceptedPath;

  String _fullPath;

  bool _notCallback = false;

  String _pathWithName;

  String _pathWithMult;

  MapParser(this.format);

  void parse(dynamic input, dynamic output) {
    if (input is List) {
      parseList(input, output);
    } else if (input is Map) {
      parseMap(input, output);
    } else {
      throw new ArgumentError("input: $input");
    }
  }

  void parseList(List input, dynamic output) {
    errors = [];
    if (input == null) {
      throw new ArgumentError("input: $input");
    }

    for (var element in input) {
      _plunge('', '', '-', element, output);
    }
  }

  void parseMap(Map input, dynamic output) {
    errors = [];
    if (input == null) {
      throw new ArgumentError("input: $input");
    }

    for (var key in input.keys) {
      var value = input[key];
      _plunge('', '', key, value, output);
    }
  }

  void _plunge(String prevFullPath, String prevAccPath, String curKey, dynamic value, dynamic prevValue) {
    var acceptedPath = '';
    var curFullPath = prevFullPath.isEmpty ? curKey : '$prevFullPath.$curKey';
    var curPathWithName = '';
    var curPathWithMult = '';
    var sep = prevAccPath.isEmpty ? '' : ':';
    if (value is List) {
      curPathWithName = '$prevAccPath$sep[$curKey]';
      curPathWithMult = '$prevAccPath$sep[*]';
    } else if (value is Map) {
      curPathWithName = '$prevAccPath$sep{$curKey}';
      curPathWithMult = '$prevAccPath$sep{*}';
    } else {
      curPathWithName = '$prevAccPath$sep"$curKey"';
      curPathWithMult = '$prevAccPath$sep"*"'; // ???
    }

    var callback;
    if (format.containsKey(curPathWithName)) {
      acceptedPath = curPathWithName;
      callback = format[curPathWithName];
    } else if (format.containsKey(curPathWithMult)) {
      acceptedPath = curPathWithMult;
      callback = format[curPathWithMult];
    }

    _acceptedPath = acceptedPath;
    _pathWithName = curPathWithName;
    _pathWithMult = curPathWithMult;
    _fullPath = curFullPath;
    var curValue;
    if (!acceptedPath.isEmpty) {
      if (!_notCallback) {
        if (callback != null) {
          if (value is List || value is Map || value == null) {
            curValue = callback(curKey, value, prevValue);
          } else {
            //curValue = callback(curKey, '$value', prevValue);
            curValue = callback(curKey, value, prevValue);
          }
        }
      }

      if (value is List) {
        for (var val in value) {
          _plunge(curFullPath, acceptedPath, '*', val, curValue);
        }
      } else if (value is Map) {
        for (var key in value.keys) {
          _plunge(curFullPath, acceptedPath, key, value[key], curValue);
        }
      }
    } else {
      errors.insert(0, curPathWithName);
    }
  }
}
