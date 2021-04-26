import 'dart:async';
//import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:oph_core/models/preset.dart';
import 'package:oph_core/utils/http_service.dart';
//import 'package:oph_core/models/preset.dart';
//import 'dart:math';

const int timeout = 30;
HttpService httpSvc = HttpService();

class AuthService {
  Preset preset;
  AuthService(this.preset);

  String _userid = '';
  String _pwd = '';
  String _msg = '';
  //String _acctid = '';
  String _suba = '';
  //String _hostguid = '';
  //String _loginName='';
  //String _loginImage='';

  String loginError() => _msg;
  String getUserId() => _userid;
  String getPwd() => _pwd;
  String getHostGUID() => preset.hostguid;

  void init(Preset _preset) {
    preset = _preset;
  }
  //void setAccountId(acct) {
  //_acctid = acct;
  //}

  void setSuba(suba) {
    _suba = suba;
  }

  void setUserId(userid) {
    _userid = userid;
  }

  void setPwd(pwd) {
    _pwd = pwd;
  }

/*
  Future<bool> login2() async {
    bool result = false;

    if (_userid != '' && _pwd != '') {
      var url = preset.serverURL +
          preset.rootAccountId +
          '/' +
          preset.apiURL +
          '?suba=' +
          _suba +
          '&mode=signin'; //"http://springroll.operahouse.systems/raifitbdg/ophcore/api/default.aspx?mode=signin";
      print(url);

      var headers = {
        'content-type': 'application/x-www-form-urlencoded',
        //'Access-Control-Allow-Origin': '*',
        //'Access-Control-Allow-Credentials': 'true',
        //'Access-Control-Allow-Headers':
        //'Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
        //'Access-Control-Allow-Methods': 'POST, OPTIONS'
      };
      var body = {'userid': _userid, 'pwd': _pwd};

      http.Response response =
          await http.post(url, headers: headers, body: body);
      //var request = new http.Request('POST', Uri.parse(url));

      String value = response.body;
      XmlDocument xmlDoc = xml.parse(value);
      //_msg = xmlDoc.findAllElements('message');
      var _h =
          xmlDoc.findAllElements("hostGUID").map((node) => node.text).toList();
      if (_h.length > 0) {
        preset.hostguid = _h[0];
        print(preset.hostguid);
        //preset.hostguid = _hostguid;
        result = true;
      } else {
        var _m =
            xmlDoc.findAllElements("message").map((node) => node.text).toList();
        if (_m.length > 0) _msg = _m[0];
      }
    }
    return result;
  }
*/
  // Login
  Future<bool> login() async {
    bool result = false;

    if (_userid != '' && _pwd != '') {
      var url = preset.serverURL +
          preset.rootAccountId +
          '/' +
          preset.apiURL +
          '?suba=' +
          _suba +
          '&mode=signin'; //"http://springroll.operahouse.systems/raifitbdg/ophcore/api/default.aspx?mode=signin";
      print(url);

      Map<String, String> body = {'userid': _userid, 'pwd': _pwd};
      String value = await httpSvc.getXML(url, body: body);
      XmlDocument xmlDoc = XmlDocument.parse(value);
      var _h =
          xmlDoc.findAllElements("hostGUID").map((node) => node.text).toList();
      var _u =
          xmlDoc.findAllElements("userGUID").map((node) => node.text).toList();
      if (_h.length > 0) {
        preset.hostguid = _h[0];
        preset.accountId = _suba;
        print(preset.hostguid);
        result = true;
      } else {
        var _m =
            xmlDoc.findAllElements("message").map((node) => node.text).toList();
        if (_m.length > 0) _msg = _m[0];
        print(_msg);
      }
      if (_u.length > 0) {
        preset.userguid = _u[0];
      }
    }
    return result;
  }

  Future<bool> gSignIn(String token, String email) async {
    bool r = false;
    if (token != null) {
      String url = preset.serverURL +
          preset.rootAccountId +
          '/' +
          preset.apiURL +
          '?suba=' +
          preset.accountId +
          '&mode=gconnect&gid=' +
          token +
          '&email=' +
          email +
          '&suba=' +
          preset.accountId;
      String value = await httpSvc.getXML(url);
      //var client = new http.Client();
      //var request = new http.Request('POST', Uri.parse(url));

      //var body = {};

      //request.bodyFields = body;
      //print(url);
      //await client
      //.send(request)
      //.then((response) => response.stream.bytesToString().then((value) {
      //print(value.toString());
      if (value != '') {
        XmlDocument xmlDoc = XmlDocument.parse(value);
        //_msg = xmlDoc.findAllElements('message');
        var _h = xmlDoc
            .findAllElements("hostGUID")
            .map((node) => node.text)
            .toList();
        if (_h.length > 0) {
          preset.hostguid = _h[0];
          //preset.hostguid = _hostguid;
          print(preset.hostguid);
          r = true;
        } else {
          var _m = xmlDoc
              .findAllElements("message")
              .map((node) => node.text)
              .toList();
          if (_m.length > 0) _msg = _m[0];
        }
      } else {
        r = false;
      }
      //}))
      //.catchError((error) => _msg = error.toString());
    }
    return r;
  }

  // Logout
  Future<void> logout() async {
    // Simulate a future for response after 1 second.

    return await new Future<void>.delayed(new Duration(seconds: 1));
  }

  Future<bool> signUp(
      String suba, String companyname, String username, String email) async {
    bool result = false;

    if (suba != '' && email != '') {
      var url = preset.serverURL +
          preset.rootAccountId +
          '/' +
          preset.apiURL +
          '?suba=' +
          suba +
          '&mode=signup'; //"http://springroll.operahouse.systems/raifitbdg/ophcore/api/default.aspx?mode=signin";
      print(url);
      var body = {
        'newaccountid': suba,
        'companyname': companyname,
        'adminname': username,
        'emailaddress': email,
      };

      String value = await httpSvc.getXML(url, body: body);
      if (value != '') {
        XmlDocument xmlDoc = XmlDocument.parse(value);
        //_msg = xmlDoc.findAllElements('message');

        var _m =
            xmlDoc.findAllElements("message").map((node) => node.text).toList();
        if (_m.length > 0) _msg = _m[0];
      } else
        result = true;
      //}))
      //.catchError((error) => _msg = error.toString());
    }
    return result;
  }
}
