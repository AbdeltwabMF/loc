import 'package:flutter/services.dart';

class PowerService {
  static const MethodChannel _channel = MethodChannel(
    'xyz.abdeltwab.loc/power',
  );

  Future<bool> isBatteryExempt() async {
    try {
      return await _channel.invokeMethod<bool>('isBatteryExempt') ?? true;
    } on Object {
      return true;
    }
  }

  Future<bool> requestBatteryExemption() async {
    try {
      if (await isBatteryExempt()) return true;
      return await _channel.invokeMethod<bool>('requestBatteryExemption') ??
          false;
    } on Object {
      return false;
    }
  }
}
