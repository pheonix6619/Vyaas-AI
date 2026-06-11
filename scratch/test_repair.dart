import 'dart:convert';

class PartialJsonParser {
  final String _input;
  int _pos = 0;

  PartialJsonParser(this._input);

  dynamic parse() {
    _skipWhitespace();
    if (_pos >= _input.length) return null;
    return _parseValue();
  }

  void _skipWhitespace() {
    while (_pos < _input.length) {
      final c = _input[_pos];
      if (c == ' ' || c == '\t' || c == '\n' || c == '\r') {
        _pos++;
      } else {
        break;
      }
    }
  }

  dynamic _parseValue() {
    _skipWhitespace();
    if (_pos >= _input.length) return null;
    final c = _input[_pos];
    if (c == '{') {
      return _parseObject();
    } else if (c == '[') {
      return _parseArray();
    } else if (c == '"') {
      return _parseString();
    } else if (c == 't' || c == 'f') {
      return _parseBool();
    } else if (c == 'n') {
      return _parseNull();
    } else if ((c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57) || c == '-') {
      return _parseNumber();
    }
    return null; // unrecognized
  }

  Map<String, dynamic> _parseObject() {
    final map = <String, dynamic>{};
    _pos++; // skip '{'
    while (true) {
      _skipWhitespace();
      if (_pos >= _input.length) return map;
      if (_input[_pos] == '}') {
        _pos++;
        return map;
      }
      
      // Parse key
      if (_input[_pos] != '"') {
        return map;
      }
      final key = _parseString();
      if (key == null) return map;

      _skipWhitespace();
      if (_pos >= _input.length || _input[_pos] != ':') {
        map[key] = null;
        return map;
      }
      _pos++; // skip ':'

      _skipWhitespace();
      if (_pos >= _input.length) {
        map[key] = null;
        return map;
      }

      final val = _parseValue();
      map[key] = val;

      _skipWhitespace();
      if (_pos >= _input.length) return map;
      if (_input[_pos] == ',') {
        _pos++;
      } else if (_input[_pos] == '}') {
        _pos++;
        return map;
      } else {
        return map;
      }
    }
  }

  List<dynamic> _parseArray() {
    final list = <dynamic>[];
    _pos++; // skip '['
    while (true) {
      _skipWhitespace();
      if (_pos >= _input.length) return list;
      if (_input[_pos] == ']') {
        _pos++;
        return list;
      }

      final val = _parseValue();
      if (val != null || _pos < _input.length) {
        list.add(val);
      }

      _skipWhitespace();
      if (_pos >= _input.length) return list;
      if (_input[_pos] == ',') {
        _pos++;
      } else if (_input[_pos] == ']') {
        _pos++;
        return list;
      } else {
        return list;
      }
    }
  }

  String? _parseString() {
    if (_pos >= _input.length || _input[_pos] != '"') return null;
    _pos++; // skip opening '"'
    final sb = StringBuffer();
    bool escaped = false;
    while (_pos < _input.length) {
      final c = _input[_pos];
      if (escaped) {
        if (c == 'n') sb.write('\n');
        else if (c == 't') sb.write('\t');
        else if (c == 'r') sb.write('\r');
        else sb.write(c);
        escaped = false;
        _pos++;
        continue;
      }
      if (c == '\\') {
        escaped = true;
        _pos++;
        continue;
      }
      if (c == '"') {
        _pos++; // skip closing '"'
        return sb.toString();
      }
      sb.write(c);
      _pos++;
    }
    return sb.toString();
  }

  bool? _parseBool() {
    if (_pos >= _input.length) return null;
    if (_input.startsWith('true', _pos)) {
      _pos += 4;
      return true;
    }
    if (_input.startsWith('false', _pos)) {
      _pos += 5;
      return false;
    }
    if (_input.startsWith('tr', _pos) || _input.startsWith('tru', _pos)) {
      _pos = _input.length;
      return true;
    }
    if (_input.startsWith('fa', _pos) || _input.startsWith('fal', _pos) || _input.startsWith('fals', _pos)) {
      _pos = _input.length;
      return false;
    }
    return null;
  }

  dynamic _parseNull() {
    if (_pos >= _input.length) return null;
    if (_input.startsWith('null', _pos)) {
      _pos += 4;
    } else {
      _pos = _input.length;
    }
    return null;
  }

  num? _parseNumber() {
    final start = _pos;
    while (_pos < _input.length) {
      final c = _input[_pos];
      if ((c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57) || c == '.' || c == '-' || c == '+' || c == 'e' || c == 'E') {
        _pos++;
      } else {
        break;
      }
    }
    final numStr = _input.substring(start, _pos);
    return num.tryParse(numStr);
  }
}

void main() {
  final cases = [
    '{"fullName": "John Doe", "projects": [{"title": "P1", "description": "mpactful tech projects blending creativity, analytics, and collaboration.",',
    '{"fullName": "John Doe", "projects": [{"title": "P1", "description": "mpactful tech projects blending',
    '{"fullName": "John Doe", "projects": [{"title": ',
    '{"fullName": "John Doe", "projects": [{"title"',
    '{"fullName": "John Doe", "projects": [',
    '{"fullName": "John Doe", "projects": [{"title": "P1"}], "skills": {"Lang": ["Dart", "Go',
  ];

  for (int i = 0; i < cases.length; i++) {
    final c = cases[i];
    print('\n--- Case ${i + 1} ---');
    print('Raw: $c');
    try {
      final parser = PartialJsonParser(c);
      final result = parser.parse();
      print('Parsed successfully: $result');
      print('As encoded JSON: ${jsonEncode(result)}');
    } catch (e) {
      print('FAILED with exception: $e');
    }
  }
}
