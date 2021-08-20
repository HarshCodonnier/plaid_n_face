// To parse this JSON data, do
//
//     final balanceRequestItem = balanceRequestItemFromJson(jsonString);

import 'dart:convert';

IdentityRequestItem identityRequestItemFromJson(String str) => IdentityRequestItem.fromJson(json.decode(str));

String identityRequestItemToJson(IdentityRequestItem data) => json.encode(data.toJson());

class IdentityRequestItem {
  IdentityRequestItem({
    required this.clientId,
    required this.secret,
    required this.accessToken,
  });

  String clientId;
  String secret;
  String accessToken;

  factory IdentityRequestItem.fromJson(Map<String, dynamic> json) => IdentityRequestItem(
    clientId: json["client_id"],
    secret: json["secret"],
    accessToken: json["access_token"],
  );

  Map<String, dynamic> toJson() => {
    "client_id": clientId,
    "secret": secret,
    "access_token": accessToken,
  };
}
