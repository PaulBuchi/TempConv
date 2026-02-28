import 'package:flutter/material.dart';
import 'tempconv_client.dart';

void main() {
  runApp(const TempConvApp());
}

class TempConvApp extends StatelessWidget {
  const TempConvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TempConv',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TempConvHomePage(),
    );
  }
}

class TempConvHomePage extends StatefulWidget {
  const TempConvHomePage({super.key});

  @override
  State<TempConvHomePage> createState() => _TempConvHomePageState();
}

class _TempConvHomePageState extends State<TempConvHomePage> {
  final TextEditingController _controller = TextEditingController();
  String _result = '';
  String _error = '';
  bool _cToF = true;

  late final TempConvClient _client;

  @override
  void initState() {
    super.initState();
    // Determine the API base URL from environment. Fallback to relative path.
    const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8080');
    // Append the service prefix for gRPC (Envoy routes /api.tempconv.TempConvService/)
    final endpoint = '$apiBaseUrl';
    _client = TempConvClient(endpoint);
  }

  Future<void> _convert() async {
    setState(() {
      _error = '';
      _result = '';
    });
    final input = double.tryParse(_controller.text);
    if (input == null) {
      setState(() {
        _error = 'Please enter a valid number';
      });
      return;
    }
    try {
      double res;
      if (_cToF) {
        res = await _client.cToF(input);
      } else {
        res = await _client.fToC(input);
      }
      setState(() {
        _result = res.toStringAsFixed(2);
      });
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TempConv')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Enter temperature',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Celsius → Fahrenheit'),
                    leading: Radio<bool>(
                      value: true,
                      groupValue: _cToF,
                      onChanged: (bool? value) {
                        if (value != null) {
                          setState(() => _cToF = value);
                        }
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('Fahrenheit → Celsius'),
                    leading: Radio<bool>(
                      value: false,
                      groupValue: _cToF,
                      onChanged: (bool? value) {
                        if (value != null) {
                          setState(() => _cToF = value);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _convert,
              child: const Text('Convert'),
            ),
            const SizedBox(height: 16),
            if (_result.isNotEmpty)
              Text(
                'Result: $_result',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            if (_error.isNotEmpty)
              Text(
                _error,
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}