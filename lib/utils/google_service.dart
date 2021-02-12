import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import "package:http/http.dart" as http;
import 'dart:convert' show json;
import 'package:pack_oph/global.dart' as g;
import 'package:pack_oph/models/preset.dart';

class GoogleService {
  Preset preset;
  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
    ],
  );
  GoogleSignInAccount _currentUser;
  bool _canAccessContact = false;
  List<dynamic> _contacts = [];
  String _token;

  GoogleSignInAccount currentUser() => _currentUser;
  bool isAccessContact() => _canAccessContact;
  List<dynamic> contactList() => _contacts;
  String token() => _token;

  void init(Preset preset, VoidCallback callback) {
    this.preset = preset;
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      //setState(() {

      _currentUser = account;
      //});
      if (_currentUser != null) {
        //handleGetContact();
      }
      callback();
    });

    //loginSilent();
    _googleSignIn.signInSilently(suppressErrors: true);
  }

  void loginSilent() {
    Future.delayed(Duration(milliseconds: 1000), () async {
      try {
        _googleSignIn.signInSilently(suppressErrors: true);
      } on PlatformException {}
    });
  }

  Future<void> handleGetContact() async {
    bool r = false;
    if (_googleSignIn.currentUser != null) {
      if (_googleSignIn.scopes
              .where((x) =>
                  x == 'https://www.googleapis.com/auth/contacts.readonly')
              .toList()
              .length ==
          0) {
        _googleSignIn.scopes
            .add('https://www.googleapis.com/auth/contacts.readonly');
        //canAccessContact=r;
      }
      r = await _googleSignIn.requestScopes(_googleSignIn.scopes);
      //if (r) {
      /*
      setState(() {
        _contactText = "Loading contact info...";
      });
      if (appAuth.getHostGUID()=='' && _currentUser!=null) {
        _currentUser.authentication.then((auth) async {
          String token=auth.accessToken;
          print(token);
          bool r=await appAuth.gSignIn(token);        
          print(r);
        });
      }
      */
      //}
      if (r) {
        r = false;
        final http.Response response = await http.get(
          'https://people.googleapis.com/v1/people/me/connections'
          '?personFields=emailAddresses,names,photos,phoneNumbers',
          headers: await _currentUser.authHeaders,
        );
        if (response.statusCode != 200) {
          /*
          setState(() {
            _contactText = "People API gave a ${response.statusCode} "
                "response. Check logs for details.";
          });
          */
          //print('People API ${response.statusCode} response: ${response.body}');
          //return r;
        } else {
          Map<String, dynamic> data = json.decode(response.body);
          _contacts = data['connections'];
          r = true;
          //final String namedContact = _pickFirstNamedContact(data);
          //setState(() {
          /*
            if (namedContact != null) {
              _contactText = "I see you know $namedContact!";
            } else {
              _contactText = "No contacts to display.";
            }
            */
          _canAccessContact = true;
          //});
        }
      }
    }
    //return r;
  }

  Future<bool> handleSignIn(
      {bool isForce = false, VoidCallback callback}) async {
    bool r = false;
    if (_googleSignIn.currentUser == null || isForce) {
      _googleSignIn.scopes.removeRange(1, _googleSignIn.scopes.length);

      _currentUser = await _googleSignIn.signIn();
      if (_currentUser.authentication == null || _token == null) {
        if (_currentUser != null)
          _currentUser.authentication.then((auth) async {
            _token = auth.accessToken;
            preset.gToken = _token;
            callback();
            r = true;
          });
      }
    }

    //try {
    if (_currentUser.authentication == null || _token == null) {
      if (_currentUser != null)
        _currentUser.authentication.then((auth) async {
          _token = auth.accessToken;
          callback();
          r = true;
        });
    } else {
      callback();
    }
    return r;
  }

  Future<void> handleSignOut(VoidCallback callback) async {
    _canAccessContact = false;

    _contacts = [];
    if (_googleSignIn.currentUser != null) {
      await _googleSignIn.disconnect();
      callback();
    }
    _currentUser = null;
  }
}
