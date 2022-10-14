import 'package:flutter/material.dart';

@immutable
class FairInfo {
  final String address;
  final String balance;
  final String gas;
  const FairInfo(this.address, this.balance, this.gas);
  static FairInfo fromJson(Map<String, dynamic> map) {
    return FairInfo(
        map["address"] ?? '', map['balance'] ?? '', map['gas'] ?? '');
  }

  static FairInfo empty() {
    return const FairInfo('', '', '');
  }
}
