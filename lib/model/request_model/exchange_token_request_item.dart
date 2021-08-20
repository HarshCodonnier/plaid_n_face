// To parse this JSON data, do
//
//     final exchangeTokenRequestItem = exchangeTokenRequestItemFromJson(jsonString);

import 'dart:convert';

ExchangeTokenRequestItem exchangeTokenRequestItemFromJson(String str) => ExchangeTokenRequestItem.fromJson(json.decode(str));

String exchangeTokenRequestItemToJson(ExchangeTokenRequestItem data) => json.encode(data.toJson());

class ExchangeTokenRequestItem {
  ExchangeTokenRequestItem({
    required this.clientId,
    required this.secret,
    required this.publicToken,
  });

  String clientId;
  String secret;
  String publicToken;

  factory ExchangeTokenRequestItem.fromJson(Map<String, dynamic> json) => ExchangeTokenRequestItem(
    clientId: json["client_id"],
    secret: json["secret"],
    publicToken: json["public_token"],
  );

  Map<String, dynamic> toJson() => {
    "client_id": clientId,
    "secret": secret,
    "public_token": publicToken,
  };
}
