// To parse this JSON data, do
//
//     final identityItem = identityItemFromJson(jsonString);

import 'dart:convert';

IdentityItem identityItemFromJson(String str) =>
    IdentityItem.fromJson(json.decode(str));

String identityItemToJson(IdentityItem data) => json.encode(data.toJson());

class IdentityItem {
  IdentityItem({
    required this.accounts,
    required this.item,
    required this.requestId,
  });

  List<Account> accounts;
  Item item;
  String requestId;

  factory IdentityItem.fromJson(Map<String, dynamic> json) => IdentityItem(
        accounts: List<Account>.from(
            json["accounts"].map((x) => Account.fromJson(x))),
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
    required this.owners,
    required this.subtype,
    required this.type,
  });

  String accountId;
  Balances balances;
  String mask;
  String name;
  String? officialName;
  List<Owner> owners;
  String subtype;
  String type;

  factory Account.fromJson(Map<String, dynamic> json) => Account(
        accountId: json["account_id"],
        balances: Balances.fromJson(json["balances"]),
        mask: json["mask"],
        name: json["name"],
        officialName: json["official_name"],
        owners: List<Owner>.from(json["owners"].map((x) => Owner.fromJson(x))),
        subtype: json["subtype"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "account_id": accountId,
        "balances": balances.toJson(),
        "mask": mask,
        "name": name,
        "official_name": officialName == null ? "" : officialName,
        "owners": List<dynamic>.from(owners.map((x) => x.toJson())),
        "subtype": subtype,
        "type": type,
      };
}

class Balances {
  Balances({
    required this.available,
    required this.current,
    required this.isoCurrencyCode,
    this.limit,
    this.unofficialCurrencyCode,
  });

  num? available;
  num? current;
  String isoCurrencyCode;
  num? limit;
  String? unofficialCurrencyCode;

  factory Balances.fromJson(Map<String, dynamic> json) => Balances(
        available: json["available"],
        current: json["current"],
        isoCurrencyCode: json["iso_currency_code"],
        limit: json["limit"],
        unofficialCurrencyCode: json["unofficial_currency_code"],
      );

  Map<String, dynamic> toJson() => {
        "available": available == null ? 0.0 : available,
        "current": current == null ? 0.0 : current,
        "iso_currency_code": isoCurrencyCode,
        "limit": limit == null ? 0.0 : limit,
        "unofficial_currency_code":
            unofficialCurrencyCode == null ? "" : unofficialCurrencyCode,
      };
}

class Owner {
  Owner({
    required this.addresses,
    required this.emails,
    required this.names,
    required this.phoneNumbers,
  });

  List<Address> addresses;
  List<Email> emails;
  List<String> names;
  List<Email> phoneNumbers;

  factory Owner.fromJson(Map<String, dynamic> json) => Owner(
        addresses: List<Address>.from(
            json["addresses"].map((x) => Address.fromJson(x))),
        emails: List<Email>.from(json["emails"].map((x) => Email.fromJson(x))),
        names: List<String>.from(json["names"].map((x) => x)),
        phoneNumbers: List<Email>.from(
            json["phone_numbers"].map((x) => Email.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "addresses": List<dynamic>.from(addresses.map((x) => x.toJson())),
        "emails": List<dynamic>.from(emails.map((x) => x.toJson())),
        "names": List<dynamic>.from(names.map((x) => x)),
        "phone_numbers":
            List<dynamic>.from(phoneNumbers.map((x) => x.toJson())),
      };
}

class Address {
  Address({
    required this.data,
    required this.primary,
  });

  Data data;
  bool primary;

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        data: Data.fromJson(json["data"]),
        primary: json["primary"],
      );

  Map<String, dynamic> toJson() => {
        "data": data.toJson(),
        "primary": primary,
      };
}

class Data {
  Data({
    required this.city,
    required this.country,
    required this.postalCode,
    required this.region,
    required this.street,
  });

  String city;
  String country;
  String postalCode;
  String region;
  String street;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        city: json["city"],
        country: json["country"],
        postalCode: json["postal_code"],
        region: json["region"],
        street: json["street"],
      );

  Map<String, dynamic> toJson() => {
        "city": city,
        "country": country,
        "postal_code": postalCode,
        "region": region,
        "street": street,
      };
}

class Email {
  Email({
    required this.data,
    required this.primary,
    required this.type,
  });

  String data;
  bool primary;
  String type;

  factory Email.fromJson(Map<String, dynamic> json) => Email(
        data: json["data"],
        primary: json["primary"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "data": data,
        "primary": primary,
        "type": type,
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
  DateTime? consentExpirationTime;
  String? error;
  String institutionId;
  String itemId;
  String updateType;
  String webhook;

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        availableProducts:
            List<String>.from(json["available_products"].map((x) => x)),
        billedProducts:
            List<String>.from(json["billed_products"].map((x) => x)),
        consentExpirationTime: json["consent_expiration_time"],
        error: json["error"],
        institutionId: json["institution_id"],
        itemId: json["item_id"],
        updateType: json["update_type"],
        webhook: json["webhook"],
      );

  Map<String, dynamic> toJson() => {
        "available_products":
            List<dynamic>.from(availableProducts.map((x) => x)),
        "billed_products": List<dynamic>.from(billedProducts.map((x) => x)),
        "consent_expiration_time": consentExpirationTime == null
            ? DateTime.now()
            : consentExpirationTime,
        "error": error == null ? "" : error,
        "institution_id": institutionId,
        "item_id": itemId,
        "update_type": updateType,
        "webhook": webhook,
      };
}
