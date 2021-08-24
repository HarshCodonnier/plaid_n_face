import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:plaid_n_face/model/identity_item.dart';

class IdentityProvider with ChangeNotifier {
  bool _loading = false;
  late IdentityItem _identityItem;
  Account? _account;
  bool _accountLinked = false;
  String _identity = "";

  bool get loading => _loading;

  bool get accountLinked => _accountLinked;

  IdentityItem get item => _identityItem;

  String get identity => _identity;

  void setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  void setAccountLinked(bool accountLinked) {
    _accountLinked = accountLinked;
  }

  void setAccessToken(String accessToken) {
    var plaidBox = Hive.box("plaid");
    plaidBox.put("plaid_access_token", accessToken);
  }

  void setIdentity(IdentityItem identityItem) {
    _identityItem = identityItem;
    _account = _identityItem.accounts
        .firstWhere((account) => account.subtype == "savings");
    _identity =
        "Name: $name\nAvailable Balance: $availableBalance\nCurrent Balance: $currentBalance";
    notifyListeners();
  }

  String get availableBalance {
    return _account == null ? "" : _account!.balances.available.toString();
  }

  String get currentBalance {
    return _account == null ? "" : _account!.balances.current.toString();
  }

  String get name {
    return _account == null ? "" : _account!.owners[0].names[0];
  }

  String get plaidAccessToken {
    var plaidBox = Hive.box("plaid");
    return plaidBox.get("plaid_access_token") == null
        ? ""
        : plaidBox.get("plaid_access_token");
  }
}
