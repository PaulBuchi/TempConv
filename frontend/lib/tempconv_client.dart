import 'package:grpc/grpc_web.dart';
import 'src/generated/tempconv.pbgrpc.dart';

/// TempConvClient wraps the generated gRPC client and exposes simple methods.
class TempConvClient {
  late final TempConvServiceClient _stub;

  TempConvClient(String baseUrl) {
    final channel = GrpcWebClientChannel.xhr(Uri.parse(baseUrl));
    _stub = TempConvServiceClient(channel);
  }

  /// Convert Celsius to Fahrenheit. Returns the converted value.
  Future<double> cToF(double value) async {
    final req = TemperatureRequest()..value = value;
    final resp = await _stub.celsiusToFahrenheit(req);
    return resp.value;
  }

  /// Convert Fahrenheit to Celsius. Returns the converted value.
  Future<double> fToC(double value) async {
    final req = TemperatureRequest()..value = value;
    final resp = await _stub.fahrenheitToCelsius(req);
    return resp.value;
  }
}