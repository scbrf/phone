import 'package:flutter/material.dart';

@immutable
class FairInfo {
  final String address;
  final String balance;
  final String gas;
  final int durationLimit;
  const FairInfo(this.address, this.balance, this.gas, this.durationLimit);
  static FairInfo fromJson(Map<String, dynamic> map) {
    return FairInfo(map["address"] ?? '', map['balance'] ?? '',
        map['gas'] ?? '', map['durationLimit'] ?? '');
  }

  static FairInfo empty() {
    return const FairInfo('', '', '', 0);
  }
}
