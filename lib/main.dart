import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart';
import 'package:local_auth/local_auth.dart';
import 'package:plaid_flutter/plaid_flutter.dart';
import 'package:plaid_n_face/model/balance_item.dart' as balance;
import 'package:plaid_n_face/model/identity_item.dart';
import 'package:plaid_n_face/model/link_token_item.dart';
import 'package:plaid_n_face/model/request_model/exchange_token_request_item.dart';
import 'package:plaid_n_face/model/request_model/link_token_request_item.dart';
import 'package:plaid_n_face/provider/identity_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'model/exchange_token_item.dart';
import 'model/request_model/identity_request_item.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox("plaid");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "test_app1",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChangeNotifierProvider(
        create: (context) => IdentityProvider(),
        child: MyHomePage(title: "test_app1"),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late PlaidLink _plaidLinkToken;
  LocalAuthentication _localAuth = LocalAuthentication();
  String _authorized = 'Not Authorized';
  bool _authenticated = false;
  late IdentityProvider _identityProvider;
  bool _showIdentity = false;

  @override
  void initState() {
    super.initState();
    _identityProvider = Provider.of<IdentityProvider>(context, listen: false);
    _localAuth.isDeviceSupported().then(
          (isSupported) => setState(() => isSupported
              ? _SupportState.supported
              : _SupportState.unsupported),
        );
    _authenticateWithBiometrics();
  }

  void fetchLinkToken() async {
    Map<String, String> heads = {
      'Content-Type': 'application/json',
      'Accept': '*/*',
    };
    Map<String, dynamic> requestData = {
      "client_id": "611de248ad468b0010a07461",
      "secret": "db784d78c6b690cf8d75c441ab1755",
      "user": {"client_user_id": "611de248ad468b001015123"},
      "client_name": "Codonnier",
      "country_codes": ["US"],
      "language": "en",
      "products": ["auth"]
    };
    LinkTokenRequestItem requestItem =
        LinkTokenRequestItem.fromJson(requestData);
    await post(Uri.parse("https://sandbox.plaid.com/link/token/create"),
            headers: heads, body: jsonEncode(requestItem))
        .then((value) {
      _identityProvider.setLoading(false);
      if (value.statusCode == 200) {
        LinkTokenItem item = LinkTokenItem.fromJson(jsonDecode(value.body));

        LinkTokenConfiguration linkTokenConfiguration = LinkTokenConfiguration(
          token: item.linkToken,
        );

        _plaidLinkToken = PlaidLink(
          configuration: linkTokenConfiguration,
          onSuccess: _onSuccessCallback,
          onEvent: _onEventCallback,
          onExit: _onExitCallback,
        );

        _plaidLinkToken.open();
        log(item.toJson().toString(), name: "LinkToken");
      } else {
        throw Exception('Failed to generate link token.');
      }
    }).onError((error, stackTrace) {
      _identityProvider.setLoading(false);
      log(error.toString(), name: "error");
      log(stackTrace.toString(), name: "stackTrace");
      throw Exception('Failed to generate link token.');
    });
  }

  void fetchAccessToken(String publicToken) async {
    Map<String, String> heads = {
      'Content-Type': 'application/json',
      'Accept': '*/*',
    };
    Map<String, dynamic> requestData = {
      "client_id": "611de248ad468b0010a07461",
      "secret": "db784d78c6b690cf8d75c441ab1755",
      "public_token": publicToken
    };
    ExchangeTokenRequestItem requestItem =
        ExchangeTokenRequestItem.fromJson(requestData);
    await post(
            Uri.parse("https://sandbox.plaid.com/item/public_token/exchange"),
            headers: heads,
            body: jsonEncode(requestItem))
        .then((value) {
      if (value.statusCode == 200) {
        ExchangeTokenItem item =
            ExchangeTokenItem.fromJson(jsonDecode(value.body));

        log(item.toJson().toString(), name: "ExchangeToken");
        _identityProvider.setAccessToken(item.accessToken);
        fetchIdentity(item.accessToken);
      } else {
        throw Exception('Failed to get access token.');
      }
    }).onError((error, stackTrace) {
      log(error.toString(), name: "error");
      log(stackTrace.toString(), name: "stackTrace");
      throw Exception('Failed to get access token.');
    });
  }

  Future<Map<String, dynamic>> fetchAccBalance(String accessToken) async {
    Map<String, String> heads = {
      'Content-Type': 'application/json',
      'Accept': '*/*',
    };
    Map<String, dynamic> requestData = {
      "client_id": "611de248ad468b0010a07461",
      "secret": "db784d78c6b690cf8d75c441ab1755",
      "access_token": accessToken
    };
    IdentityRequestItem requestItem = IdentityRequestItem.fromJson(requestData);
    var response = await post(
            Uri.parse("https://sandbox.plaid.com/accounts/balance/get"),
            headers: heads,
            body: jsonEncode(requestItem))
        .then((value) {
      if (value.statusCode == 200) {
        balance.BalanceItem item =
            balance.BalanceItem.fromJson(jsonDecode(value.body));

        log(item.toJson().toString(), name: "Acc Balance");
        return value;
      } else {
        throw Exception('Failed to get balance.');
      }
    }).onError((error, stackTrace) {
      log(error.toString(), name: "error");
      log(stackTrace.toString(), name: "stackTrace");
      throw Exception('Failed to get balance.');
    });
    return {"response": response};
  }

  void fetchIdentity(String accessToken) async {
    Map<String, String> heads = {
      'Content-Type': 'application/json',
      'Accept': '*/*',
    };
    Map<String, dynamic> requestData = {
      "client_id": "611de248ad468b0010a07461",
      "secret": "db784d78c6b690cf8d75c441ab1755",
      "access_token": accessToken
    };
    IdentityRequestItem requestItem = IdentityRequestItem.fromJson(requestData);
    await post(Uri.parse("https://sandbox.plaid.com/identity/get"),
            headers: heads, body: jsonEncode(requestItem))
        .then((value) {
      _identityProvider.setLoading(false);
      if (value.statusCode == 200) {
        IdentityItem item = IdentityItem.fromJson(jsonDecode(value.body));

        log(item.toJson().toString(), name: "AccIdentity");
        var account =
            item.accounts.firstWhere((account) => account.subtype == "savings");
        showData(account);

        _showIdentity = true;
        _identityProvider.setAccountLinked(true);
        _identityProvider.setIdentity(item);
      } else {
        throw Exception('Failed to get balance.');
      }
    }).onError((error, stackTrace) {
      _identityProvider.setLoading(false);
      log(error.toString(), name: "error");
      log(stackTrace.toString(), name: "stackTrace");
      throw Exception('Failed to get balance.');
    });
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      setState(() {
        _authorized = 'Authenticating';
      });
      _authenticated = await _localAuth.authenticate(
          localizedReason:
              'Scan your fingerprint (or face or whatever) to authenticate',
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: true);
      setState(() {
        _authorized = 'Authenticating';
      });
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _authorized = "Error - ${e.message}";
      });
      return;
    }
    if (!mounted) return;

    final String message =
        _authenticated ? 'Biometrics Authorized' : 'Not Authorized';
    setState(() {
      _authorized = message;
    });
    if (_authenticated) {
      if (_identityProvider.plaidAccessToken.isNotEmpty) {
        _identityProvider.setLoading(true);
        _identityProvider.setAccountLinked(true);
        fetchIdentity(_identityProvider.plaidAccessToken);
      }
    }
  }

  void _onSuccessCallback(String publicToken, LinkSuccessMetadata metadata) {
    _identityProvider.setLoading(true);
    log(metadata.description(), name: "onSuccess: $publicToken");
    fetchAccessToken(publicToken);
  }

  void _onEventCallback(String event, LinkEventMetadata metadata) {
    log(metadata.description(), name: "onEvent: $event");
  }

  void _onExitCallback(LinkError? error, LinkExitMetadata metadata) {
    log(metadata.description(), name: "onExit metadata");

    if (error != null) {
      print("onExit error: ${error.description()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Current State: $_authorized\n'),
                Visibility(
                  visible: !_authenticated,
                  child: ElevatedButton(
                    child: Text("Retry Authentication"),
                    onPressed: _authenticateWithBiometrics,
                  ),
                ),
                Visibility(
                    visible: _authenticated,
                    child: Consumer<IdentityProvider>(
                      builder: (context, value, child) {
                        return ElevatedButton(
                          child: Text(value.accountLinked
                              ? "Linked"
                              : "Link with Bank Account"),
                          onPressed:
                              value.accountLinked ? null : fetchLinkToken,
                        );
                      },
                    )),
                SizedBox(height: 35),
                Consumer<IdentityProvider>(
                  builder: (context, value, child) {
                    return Visibility(
                      visible: _showIdentity,
                      child: Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.85,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFFAF2AFF),
                                      Color(0xFF28CAFB),
                                    ]),
                                borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              children: [
                                QrImage(
                                  data: value.identity,
                                  size: 250,
                                  gapless: true,
                                  backgroundColor: Colors.white,
                                  errorStateBuilder: (context, error) {
                                    return Container(
                                      child: Center(
                                        child: Text(
                                          "Uh oh! Something went wrong...",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  "${value.name}".toUpperCase(),
                                  style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 20,
                                      decoration: TextDecoration.underline),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            "\$ ${value.availableBalance}",
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                                fontSize: 16),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            "Available Balance",
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w300,
                                                color: Colors.white,
                                                fontSize: 16),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            "\$ ${value.currentBalance}",
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                                fontSize: 16),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            "Current Balance",
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w300,
                                                color: Colors.white,
                                                fontSize: 16),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Consumer<IdentityProvider>(
            builder: (context, value, child) {
              return Visibility(
                visible: value.loading,
                child: Container(
                  color: Colors.black45,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void showData(Account account) {
    log("${account.balances.current}", name: "current");
    log("${account.balances.available}", name: "available");
    log("${account.owners[0].names[0]}", name: "name");
  }
}

enum _SupportState {
  supported,
  unsupported,
}
