// To parse this JSON data, do
//
//     final requestItem = requestItemFromJson(jsonString);

import 'dart:convert';

LinkTokenRequestItem linkTokenRequestItemFromJson(String str) => LinkTokenRequestItem.fromJson(json.decode(str));

String linkTokenRequestItemToJson(LinkTokenRequestItem data) => json.encode(data.toJson());

class LinkTokenRequestItem {
  LinkTokenRequestItem({
    required this.clientId,
    required this.secret,
    required this.user,
    required this.clientName,
    required this.countryCodes,
    required this.language,
    required this.products,
  });

  String clientId;
  String secret;
  User user;
  String clientName;
  List<String> countryCodes;
  String language;
  List<String> products;

  factory LinkTokenRequestItem.fromJson(Map<String, dynamic> json) => LinkTokenRequestItem(
    clientId: json["client_id"],
    secret: json["secret"],
    user: User.fromJson(json["user"]),
    clientName: json["client_name"],
    countryCodes: List<String>.from(json["country_codes"].map((x) => x)),
    language: json["language"],
    products: List<String>.from(json["products"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "client_id": clientId,
    "secret": secret,
    "user": user.toJson(),
    "client_name": clientName,
    "country_codes": List<dynamic>.from(countryCodes.map((x) => x)),
    "language": language,
    "products": List<dynamic>.from(products.map((x) => x)),
  };
}

class User {
  User({
    required this.clientUserId,
  });

  String clientUserId;

  factory User.fromJson(Map<String, dynamic> json) => User(
    clientUserId: json["client_user_id"],
  );

  Map<String, dynamic> toJson() => {
    "client_user_id": clientUserId,
  };
}
