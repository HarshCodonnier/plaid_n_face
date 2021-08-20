// To parse this JSON data, do
//
//     final exchangeTokenRequestItem = exchangeTokenRequestItemFromJson(jsonString);

import 'dart:convert';

ExchangeTokenItem exchangeTokenItemFromJson(String str) => ExchangeTokenItem.fromJson(json.decode(str));

String exchangeTokenItemToJson(ExchangeTokenItem data) => json.encode(data.toJson());

class ExchangeTokenItem {
  ExchangeTokenItem({
    required this.accessToken,
    required this.itemId,
    required this.requestId,
  });

  String accessToken;
  String itemId;
  String requestId;

  factory ExchangeTokenItem.fromJson(Map<String, dynamic> json) => ExchangeTokenItem(
    accessToken: json["access_token"],
    itemId: json["item_id"],
    requestId: json["request_id"],
  );

  Map<String, dynamic> toJson() => {
    "access_token": accessToken,
    "item_id": itemId,
    "request_id": requestId,
  };
}
