import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:local_auth/local_auth.dart';
import 'package:plaid_flutter/plaid_flutter.dart';
import 'package:plaid_n_face/link_token_item.dart';
import 'package:plaid_n_face/request_item.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Palid Demo",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: "Palid"),
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
  LocalAuthentication localAuth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

  Future<Map<String, dynamic>> fetchLinkToken() async {
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
    RequestItem requestItem = RequestItem.fromJson(requestData);
    var response = await post(
            Uri.parse("https://sandbox.plaid.com/link/token/create"),
            headers: heads,
            body: jsonEncode(requestItem))
        .then((value) {
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
        log(item.toJson().toString(), name: "item");
        return value;
      } else {
        throw Exception('Failed to generate link token.');
      }
    }).onError((error, stackTrace) {
      log(error.toString(), name: "error");
      log(stackTrace.toString(), name: "stackTrace");
      throw Exception('Failed to generate link token.');
    });
    return {"response": response};
  }

  @override
  void initState() {
    super.initState();
    localAuth.isDeviceSupported().then(
          (isSupported) => setState(() => _supportState = isSupported
          ? _SupportState.supported
          : _SupportState.unsupported),
    );
  }

  Future<void> _checkBiometrics() async {
    late bool canCheckBiometrics;
    try {
      canCheckBiometrics = await localAuth.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> _getAvailableBiometrics() async {
    late List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      availableBiometrics = <BiometricType>[];
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _availableBiometrics = availableBiometrics;
    });
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await localAuth.authenticate(
          localizedReason: 'Let OS determine authentication method',
          useErrorDialogs: true,
          stickyAuth: true);
      setState(() {
        _isAuthenticating = false;
      });
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
        _authorized = "Error - ${e.message}";
      });
      return;
    }
    if (!mounted) return;

    setState(
            () => _authorized = authenticated ? 'Authorized' : 'Not Authorized');
  }

  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await localAuth.authenticate(
          localizedReason:
          'Scan your fingerprint (or face or whatever) to authenticate',
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: true);
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Authenticating';
      });
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
        _authorized = "Error - ${e.message}";
      });
      return;
    }
    if (!mounted) return;

    final String message = authenticated ? 'Authorized' : 'Not Authorized';
    setState(() {
      _authorized = message;
    });
  }

  void _cancelAuthentication() async {
    await localAuth.stopAuthentication();
    setState(() => _isAuthenticating = false);
  }

  void _onSuccessCallback(String publicToken, LinkSuccessMetadata metadata) {
    print("onSuccess: $publicToken, metadata: ${metadata.description()}");
  }

  void _onEventCallback(String event, LinkEventMetadata metadata) {
    print("onEvent: $event, metadata: ${metadata.description()}");
  }

  void _onExitCallback(LinkError? error, LinkExitMetadata metadata) {
    print("onExit metadata: ${metadata.description()}");

    if (error != null) {
      print("onExit error: ${error.description()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    // fetchLinkToken();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 30),
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_supportState == _SupportState.unknown)
                CircularProgressIndicator()
              else if (_supportState == _SupportState.supported)
                Text("This device is supported")
              else
                Text("This device is not supported"),
              Divider(height: 100),
              Text('Can check biometrics: $_canCheckBiometrics\n'),
              ElevatedButton(
                child: const Text('Check biometrics'),
                onPressed: _checkBiometrics,
              ),
              Divider(height: 100),
              Text('Available biometrics: $_availableBiometrics\n'),
              ElevatedButton(
                child: const Text('Get available biometrics'),
                onPressed: _getAvailableBiometrics,
              ),
              Divider(height: 100),
              Text('Current State: $_authorized\n'),
              (_isAuthenticating)
                  ? ElevatedButton(
                onPressed: _cancelAuthentication,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Cancel Authentication"),
                    Icon(Icons.cancel),
                  ],
                ),
              )
                  : Column(
                children: [
                  ElevatedButton(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Authenticate'),
                        Icon(Icons.perm_device_information),
                      ],
                    ),
                    onPressed: _authenticate,
                  ),
                  ElevatedButton(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_isAuthenticating
                            ? 'Cancel'
                            : 'Authenticate: biometrics only'),
                        Icon(Icons.fingerprint),
                      ],
                    ),
                    onPressed: _authenticateWithBiometrics,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _SupportState {
  unknown,
  supported,
  unsupported,
}
