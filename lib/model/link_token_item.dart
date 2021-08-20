import 'dart:convert';

LinkTokenItem linkTokenItemFromJson(String str) => LinkTokenItem.fromJson(json.decode(str));

String linkTokenItemToJson(LinkTokenItem data) => json.encode(data.toJson());

class LinkTokenItem {
  LinkTokenItem({
    required this.linkToken,
    required this.expiration,
    required this.requestId,
  });

  String linkToken;
  DateTime expiration;
  String requestId;

  factory LinkTokenItem.fromJson(Map<String, dynamic> json) => LinkTokenItem(
    linkToken: json["link_token"],
    expiration: DateTime.parse(json["expiration"]),
    requestId: json["request_id"],
  );

  Map<String, dynamic> toJson() => {
    "link_token": linkToken,
    "expiration": expiration.toIso8601String(),
    "request_id": requestId,
  };
}