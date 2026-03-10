import 'package:flutter/material.dart';

/// A simple Dart syntax highlighter that creates a [TextSpan] tree with
/// appropriate color coding for keywords, strings, comments, etc.
class DartSyntaxHighlighter {
  const DartSyntaxHighlighter({
    this.keywordColor = const Color(0xFF1976D2),
    this.stringColor = const Color(0xFF388E3C),
    this.commentColor = const Color(0xFF757575),
    this.numberColor = const Color(0xFF7B1FA2),
    this.classColor = const Color(0xFF7C4DFF),
    this.functionColor = const Color(0xFF00796B),
    this.defaultColor = const Color(0xFF212121),
    this.typeColor = const Color(0xFF303F9F),
  });

  final Color keywordColor;
  final Color stringColor;
  final Color commentColor;
  final Color numberColor;
  final Color classColor;
  final Color functionColor;
  final Color defaultColor;
  final Color typeColor;

  static const Set<String> _keywords = {
    'abstract',
    'as',
    'assert',
    'async',
    'await',
    'break',
    'case',
    'catch',
    'class',
    'const',
    'continue',
    'covariant',
    'default',
    'deferred',
    'do',
    'dynamic',
    'else',
    'enum',
    'export',
    'extends',
    'extension',
    'external',
    'factory',
    'false',
    'final',
    'finally',
    'for',
    'function',
    'get',
    'hide',
    'if',
    'implements',
    'import',
    'in',
    'interface',
    'is',
    'late',
    'library',
    'mixin',
    'new',
    'null',
    'of',
    'on',
    'operator',
    'part',
    'required',
    'rethrow',
    'return',
    'set',
    'show',
    'static',
    'super',
    'switch',
    'sync',
    'this',
    'throw',
    'true',
    'try',
    'typedef',
    'var',
    'void',
    'while',
    'with',
    'yield',
  };

  static const Set<String> _types = {
    'bool',
    'double',
    'int',
    'num',
    'Object',
    'String',
    'List',
    'Map',
    'Set',
    'Future',
    'Stream',
    'Iterable',
    'Widget',
    'BuildContext',
    'Key',
    'Color',
    'MaterialColor',
    'IconData',
    'Size',
    'Offset',
    'Rect',
    'Duration',
    'Curve',
    'Animation',
    'ValueNotifier',
  };

  static const Set<String> _builtInFunctions = {
    'print',
    'debugPrint',
    'runApp',
    'setState',
    'mounted',
    'context',
    'Theme',
    'MediaQuery',
    'Navigator',
    'showDialog',
    'showModalBottomSheet',
    'ScaffoldMessenger',
  };

  TextSpan highlight(String code) {
    final spans = <TextSpan>[];
    final buffer = StringBuffer();
    var i = 0;

    String? currentStringDelimiter;
    bool inSingleLineComment = false;
    bool inMultiLineComment = false;

    void flushBuffer([Color? color]) {
      if (buffer.isEmpty) return;
      final text = buffer.toString();
      buffer.clear();
      spans.add(TextSpan(
        text: text,
        style: color != null ? TextStyle(color: color) : null,
      ));
    }

    while (i < code.length) {
      final char = code[i];
      final nextChar = i + 1 < code.length ? code[i + 1] : null;

      // Handle comments
      if (currentStringDelimiter == null &&
          !inSingleLineComment &&
          !inMultiLineComment) {
        if (char == '/' && nextChar == '/') {
          flushBuffer();
          inSingleLineComment = true;
          buffer.write(char);
          i++;
          continue;
        }
        if (char == '/' && nextChar == '*') {
          flushBuffer();
          inMultiLineComment = true;
          buffer.write(char);
          i++;
          continue;
        }
      }

      if (inSingleLineComment) {
        buffer.write(char);
        if (char == '\n') {
          flushBuffer(commentColor);
          inSingleLineComment = false;
        }
        i++;
        continue;
      }

      if (inMultiLineComment) {
        buffer.write(char);
        if (char == '*' && nextChar == '/') {
          buffer.write(nextChar);
          flushBuffer(commentColor);
          inMultiLineComment = false;
          i += 2;
          continue;
        }
        i++;
        continue;
      }

      // Handle strings
      if (currentStringDelimiter == null) {
        if (char == '"' || char == "'" || char == '`') {
          flushBuffer();
          currentStringDelimiter = char;
          buffer.write(char);
          i++;
          continue;
        }
      } else {
        buffer.write(char);
        if (char == currentStringDelimiter && code[i - 1] != '\\') {
          flushBuffer(stringColor);
          currentStringDelimiter = null;
        } else if (char == '\n' && currentStringDelimiter != '`') {
          // Multi-line string handling
        }
        i++;
        continue;
      }

      // Handle numbers
      if (_isDigit(char) ||
          (char == '.' &&
              nextChar != null &&
              _isDigit(nextChar) &&
              (i == 0 || !_isIdentifierPart(code[i - 1])))) {
        // Check if it's a number or just part of an identifier
        if (buffer.isEmpty || !_isIdentifierPart(buffer.toString().lastChar)) {
          flushBuffer();
          while (i < code.length &&
              (_isDigit(code[i]) ||
                  code[i] == '.' ||
                  code[i] == 'e' ||
                  code[i] == 'E' ||
                  code[i] == '+' ||
                  code[i] == '-')) {
            buffer.write(code[i]);
            i++;
          }
          flushBuffer(numberColor);
          continue;
        }
      }

      // Handle identifiers and keywords
      if (_isIdentifierStart(char)) {
        flushBuffer();
        while (i < code.length && _isIdentifierPart(code[i])) {
          buffer.write(code[i]);
          i++;
        }
        final word = buffer.toString();
        buffer.clear();

        if (_keywords.contains(word)) {
          spans
              .add(TextSpan(text: word, style: TextStyle(color: keywordColor)));
        } else if (_types.contains(word)) {
          spans.add(TextSpan(text: word, style: TextStyle(color: typeColor)));
        } else if (_builtInFunctions.contains(word)) {
          spans.add(
              TextSpan(text: word, style: TextStyle(color: functionColor)));
        } else if (word.isNotEmpty && word[0] == word[0].toUpperCase()) {
          // Likely a class name
          spans.add(TextSpan(text: word, style: TextStyle(color: classColor)));
        } else {
          spans
              .add(TextSpan(text: word, style: TextStyle(color: defaultColor)));
        }
        continue;
      }

      // Handle @ annotations
      if (char == '@') {
        flushBuffer();
        while (i < code.length && _isIdentifierPart(code[i])) {
          buffer.write(code[i]);
          i++;
        }
        final annotation = buffer.toString();
        buffer.clear();
        spans.add(
            TextSpan(text: annotation, style: TextStyle(color: classColor)));
        continue;
      }

      buffer.write(char);
      i++;
    }

    // Flush remaining buffer with appropriate color
    if (buffer.isNotEmpty) {
      if (currentStringDelimiter != null) {
        flushBuffer(stringColor);
      } else if (inSingleLineComment || inMultiLineComment) {
        flushBuffer(commentColor);
      } else {
        flushBuffer();
      }
    }

    return TextSpan(
      children: spans,
      style: TextStyle(color: defaultColor, fontFamily: 'monospace'),
    );
  }

  static bool _isDigit(String char) =>
      char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57;

  static bool _isIdentifierStart(String char) {
    final code = char.codeUnitAt(0);
    return (code >= 65 && code <= 90) || // A-Z
        (code >= 97 && code <= 122) || // a-z
        code == 95; // _
  }

  static bool _isIdentifierPart(String char) {
    final code = char.codeUnitAt(0);
    return _isIdentifierStart(char) || (code >= 48 && code <= 57);
  }
}

extension on String {
  String get lastChar => isEmpty ? '' : this[length - 1];
}

/// A widget that displays syntax-highlighted Dart code.
class SyntaxHighlightedCode extends StatelessWidget {
  const SyntaxHighlightedCode({
    super.key,
    required this.code,
    this.style,
    this.scrollDirection = Axis.vertical,
  });

  final String code;
  final TextStyle? style;
  final Axis scrollDirection;

  @override
  Widget build(BuildContext context) {
    final highlighter = DartSyntaxHighlighter(
      defaultColor: Theme.of(context).colorScheme.onSurface,
    );

    return SingleChildScrollView(
      scrollDirection: scrollDirection,
      child: SizedBox(
        width: double.infinity,
        child: SelectableText.rich(
          highlighter.highlight(code),
          style: style ??
              TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
      ),
    );
  }
}
