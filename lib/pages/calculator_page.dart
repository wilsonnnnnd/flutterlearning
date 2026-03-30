import 'package:flutter/material.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _expr = '';
  String _result = '';

  void _append(String s) {
    setState(() {
      _expr += s;
    });
  }

  void _clear() {
    setState(() {
      _expr = '';
      _result = '';
    });
  }

  void _evaluate() {
    try {
      final val = _evalExpression(_expr);
      setState(() {
        _result = _formatDouble(val);
      });
    } catch (e) {
      setState(() {
        _result = '错误';
      });
    }
  }

  String _formatDouble(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toString();
  }

  double _evalExpression(String input) {
    final tokens = _tokenize(input);
    final rpn = _toRPN(tokens);
    return _evalRPN(rpn);
  }

  List<String> _tokenize(String s) {
    final List<String> out = [];
    final buffer = StringBuffer();
    String pushBuffer() {
      final str = buffer.toString();
      buffer.clear();
      return str;
    }

    for (int i = 0; i < s.length; i++) {
      final ch = s[i];
      if (RegExp(r'[0-9.]').hasMatch(ch)) {
        buffer.write(ch);
      } else if (RegExp(r'[+\-*/()]').hasMatch(ch)) {
        if (buffer.isNotEmpty) out.add(pushBuffer());
        out.add(ch);
      } else {
        // ignore other chars/spaces
        if (buffer.isNotEmpty) out.add(pushBuffer());
      }
    }
    if (buffer.isNotEmpty) out.add(pushBuffer());
    return out;
  }

  List<String> _toRPN(List<String> tokens) {
    final output = <String>[];
    final ops = <String>[];
    int prec(String op) {
      if (op == '+' || op == '-') return 1;
      if (op == '*' || op == '/') return 2;
      return 0;
    }

    for (final t in tokens) {
      if (RegExp(r'^\d+(\.\d+)?$').hasMatch(t)) {
        output.add(t);
      } else if (RegExp(r'[+\-*/]').hasMatch(t)) {
        while (ops.isNotEmpty &&
            RegExp(r'[+\-*/]').hasMatch(ops.last) &&
            prec(ops.last) >= prec(t)) {
          output.add(ops.removeLast());
        }
        ops.add(t);
      } else if (t == '(') {
        ops.add(t);
      } else if (t == ')') {
        while (ops.isNotEmpty && ops.last != '(') {
          output.add(ops.removeLast());
        }
        if (ops.isNotEmpty && ops.last == '(') {
          ops.removeLast();
        }
      }
    }
    while (ops.isNotEmpty) {
      output.add(ops.removeLast());
    }
    return output;
  }

  double _evalRPN(List<String> rpn) {
    final stack = <double>[];
    for (final t in rpn) {
      if (RegExp(r'^\d+(\.\d+)?$').hasMatch(t)) {
        stack.add(double.parse(t));
      } else if (RegExp(r'[+\-*/]').hasMatch(t)) {
        if (stack.length < 2) throw Exception('Invalid');
        final b = stack.removeLast();
        final a = stack.removeLast();
        switch (t) {
          case '+':
            stack.add(a + b);
            break;
          case '-':
            stack.add(a - b);
            break;
          case '*':
            stack.add(a * b);
            break;
          case '/':
            stack.add(a / b);
            break;
        }
      }
    }
    if (stack.length != 1) throw Exception('Invalid');
    return stack.first;
  }

  Widget _buildButton(String label, {Color? color, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Colors.grey[200],
          foregroundColor: Colors.black,
          padding: const EdgeInsets.all(20),
        ),
        onPressed: onTap ?? () => _append(label),
        child: Text(label, style: const TextStyle(fontSize: 20)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttons = [
      ['7', '8', '9', '/'],
      ['4', '5', '6', '*'],
      ['1', '2', '3', '-'],
      ['0', '.', '(', '+'],
      [')', 'C', '=', '']
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Calculator')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            color: Colors.black12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_expr, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 8),
                Text(_result, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(12),
              crossAxisCount: 4,
              childAspectRatio: 1.4,
              children: buttons.expand((row) => row).map((label) {
                if (label == '') return const SizedBox.shrink();
                if (label == 'C') {
                  return _buildButton(label, color: Colors.orange[300], onTap: _clear);
                }
                if (label == '=') {
                  return _buildButton(label, color: Colors.green[300], onTap: _evaluate);
                }
                return _buildButton(label);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
