// To parse this JSON data, do
//
//     final balanceItem = balanceItemFromJson(jsonString);

import 'dart:convert';

BalanceItem balanceItemFromJson(String str) => BalanceItem.fromJson(json.decode(str));

String balanceItemToJson(BalanceItem data) => json.encode(data.toJson());

class BalanceItem {
  BalanceItem({
    required this.accounts,
    required this.item,
    required this.requestId,
  });

  List<Account> accounts;
  Item item;
  String requestId;

  factory BalanceItem.fromJson(Map<String, dynamic> json) => BalanceItem(
    accounts: List<Account>.from(json["accounts"].map((x) => Account.fromJson(x))),
    item: Item.fromJson(json["item"]),
    requestId: json["request_id"],
  );

  Map<String, dynamic> toJson() => {
    "accounts": List<dynamic>.from(accounts.map((x) => x.toJson())),
    "item": item.toJson(),
    "request_id": requestId,
  };
}

class Account {
  Account({
    required this.accountId,
    required this.balances,
    required this.mask,
    required this.name,
    required this.officialName,
    required this.subtype,
    required this.type,
  });

  String accountId;
  Balances balances;
  String mask;
  String name;
  String? officialName;
  String subtype;
  String type;

  factory Account.fromJson(Map<String, dynamic> json) => Account(
    accountId: json["account_id"],
    balances: Balances.fromJson(json["balances"]),
    mask: json["mask"],
    name: json["name"],
    officialName: json["official_name"] == null ? null : json["official_name"],
    subtype: json["subtype"],
    type: json["type"],
  );

  Map<String, dynamic> toJson() => {
    "account_id": accountId,
    "balances": balances.toJson(),
    "mask": mask,
    "name": name,
    "official_name": officialName == null ? null : officialName,
    "subtype": subtype,
    "type": type,
  };
}

class Balances {
  Balances({
    required this.available,
    required this.current,
    required this.isoCurrencyCode,
    required this.limit,
    this.unofficialCurrencyCode,
  });

  int? available;
  num current;
  String isoCurrencyCode;
  int? limit;
  String? unofficialCurrencyCode;

  factory Balances.fromJson(Map<String, dynamic> json) => Balances(
    available: json["available"] == null ? null : json["available"],
    current: json["current"],
    isoCurrencyCode: json["iso_currency_code"],
    limit: json["limit"] == null ? null : json["limit"],
    unofficialCurrencyCode: json["unofficial_currency_code"],
  );

  Map<String, dynamic> toJson() => {
    "available": available == null ? null : available,
    "current": current,
    "iso_currency_code": isoCurrencyCode,
    "limit": limit == null ? 0 : limit,
    "unofficial_currency_code": unofficialCurrencyCode == null ? "" : unofficialCurrencyCode,
  };
}

class Item {
  Item({
    required this.availableProducts,
    required this.billedProducts,
    this.consentExpirationTime,
    this.error,
    required this.institutionId,
    required this.itemId,
    required this.updateType,
    required this.webhook,
  });

  List<String> availableProducts;
  List<String> billedProducts;
  dynamic consentExpirationTime;
  dynamic error;
  String institutionId;
  String itemId;
  String updateType;
  String webhook;

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    availableProducts: List<String>.from(json["available_products"].map((x) => x)),
    billedProducts: List<String>.from(json["billed_products"].map((x) => x)),
    consentExpirationTime: json["consent_expiration_time"],
    error: json["error"],
    institutionId: json["institution_id"],
    itemId: json["item_id"],
    updateType: json["update_type"],
    webhook: json["webhook"],
  );

  Map<String, dynamic> toJson() => {
    "available_products": List<dynamic>.from(availableProducts.map((x) => x)),
    "billed_products": List<dynamic>.from(billedProducts.map((x) => x)),
    "consent_expiration_time": consentExpirationTime,
    "error": error,
    "institution_id": institutionId,
    "item_id": itemId,
    "update_type": updateType,
    "webhook": webhook,
  };
}
