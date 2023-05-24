import 'dart:core';

String _switchCase(String c) {
  if (c == c.toUpperCase()) {
    return c.toLowerCase();
  }
  return c.toUpperCase();
}

class MethodsBases {
  static String calculate(String s) {
    if (s[0] == 'N') {
      return s
          .substring(4, s.length)
          .replaceAll('0', 'x')
          .replaceAll('1', '0')
          .replaceAll('x', '1');
    }
    final sParts = s.split(' ');
    String op = sParts[0];
    String s1 = sParts[1];
    switch (s.substring(0, 2)) {
      case 'LS':
        int x = int.tryParse(op.substring(2))!;
        if (x > s1.length) {
          return '0' * s1.length;
        }
        return s1.substring(x) + '0' * x;
      case 'RS':
        int x = int.tryParse(op.substring(2))!;
        if (x > s1.length) {
          return '0' * s1.length;
        }
        return '0' * x + s1.substring(0, s1.length - x);
      case 'LC':
        int x = int.tryParse(op.substring(2))! % s1.length;
        return s1.substring(x) + s1.substring(0, x);
      case 'RC':
        int x = int.tryParse(op.substring(2))! % s1.length;
        return s1.substring(s1.length - x) + s1.substring(0, s1.length - x);
      default:
        String s1 = sParts[0];
        String op = sParts[1];
        String s2 = sParts[2];
        switch (op) {
          case 'AND':
            String result = '';
            for (int i = 0; i < s1.length; i++) {
              if (s1[i] == '1' && s2[i] == '1') {
                result += '1';
              } else if (s1[i] == '0' || s2[i] == '0') {
                result += '0';
              } else {
                if (s1[i] == '0') {
                  result += s2[i];
                } else {
                  result += s1[i];
                }
              }
            }
            return result;
          case 'OR':
            String result = '';
            for (int i = 0; i < s1.length; i++) {
              if (s1[i] == '1' || s2[i] == '1') {
                result += '1';
              } else if (s1[i] == '0' && s2[i] == '0') {
                result += '0';
              } else {
                if (s1[i] == '0') {
                  result += s2[i];
                } else {
                  result += s1[i];
                }
              }
            }
            return result;
          case 'XOR':
            String result = '';
            for (int i = 0; i < s1.length; i++) {
              if (s1[i] == '0' && s2[i] == '1' ||
                  s1[i] == '1' && s2[i] == '0') {
                result += '1';
              } else if (s1[i] == '1' && s2[i] == '1' ||
                  s1[i] == '0' && s2[i] == '0') {
                result += '0';
              } else {
                if (s1[i] == '0') {
                  result += s2[i];
                } else if (s1[i] == '1') {
                  result += _switchCase(s2[i]);
                } else if (s2[i] == '0') {
                  result += s1[i];
                } else {
                  result += _switchCase(s1[i]);
                }
              }
            }

            return result;
        }
    }
    print('Errror');
    return 'ERR';
  }
}
