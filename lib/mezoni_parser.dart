library mezoni_parser;

typedef dynamic ParserCallback(String key, dynamic value, dynamic prevValue);

/* Fast structure parser */
class MezoniParser {
  List<String> errors = [];

  Map<String, ParserCallback> format;

  bool notCallback = false;

  MezoniParser(this.format);

  void parse(dynamic data, dynamic initialValue) {
    errors = [];
    if(data is List) {
      for(var val in data) {
        _plunge('', '', '-', val, initialValue);
      }
    } else if(data is Map) {
      for(var key in data.keys) {
        var value = data[key];
        _plunge('', '', key, data[key], initialValue);
      }
    }
  }

  String glbAcceptedPath;
  String glbFullPath;
  String glbPathWithName;
  String glbPathWithMult;

  void _plunge(String prevFullPath, String prevAccPath, curKey, value,
    prevValue) {
    var curPathWithName = '';
    var curPathWithMult = '';
    var acceptedPath = '';
    var curFullPath = prevFullPath.isEmpty ? curKey : '$prevFullPath.$curKey';

    var sep = prevAccPath.isEmpty ? '' : ':';

    if(value is List) {
      curPathWithName = '$prevAccPath$sep[$curKey]';
      curPathWithMult = '$prevAccPath$sep[*]';
    } else if(value is Map) {
      curPathWithName = '$prevAccPath$sep{$curKey}';
      curPathWithMult = '$prevAccPath$sep{*}';
    } else {
      curPathWithName = '$prevAccPath$sep"$curKey"';
      curPathWithMult = '$prevAccPath$sep"*"'; // ???
    }

    var callback;
    if(format.containsKey(curPathWithName)) {
      acceptedPath = curPathWithName;
      callback = format[curPathWithName];
    } else if(format.containsKey(curPathWithMult)) {
      acceptedPath = curPathWithMult;
      callback = format[curPathWithMult];
    }

    glbAcceptedPath = acceptedPath;
    glbPathWithName = curPathWithName;
    glbPathWithMult = curPathWithMult;
    glbFullPath = curFullPath;

    var curValue;
    if(!acceptedPath.isEmpty) {
      if(!notCallback) {
        if(callback != null) {
          if(value is List || value is Map || value == null) {
            curValue = callback(curKey, value, prevValue);
          } else {
            curValue = callback(curKey, '$value', prevValue);
          }
        }
      }

      if(value is List) {
        for(var val in value) {
          _plunge(curFullPath, acceptedPath, '*', val, curValue);
        }
      } else if(value is Map) {
        for(var key in value.keys) {
          _plunge(curFullPath, acceptedPath, key, value[key], curValue);
        }
      }
    } else {
      errors.insert(0, curPathWithName);
    }
  }
}
