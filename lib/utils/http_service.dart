import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import '../models/preset.dart';

class HttpService {
  String _msg;
  String httpError() => _msg;
  Preset preset;

  void init(Preset preset) {
    preset = preset;
  }

  Future<String> getXML(String url,
      {Map<String, String> body, Map<String, String> headers}) async {
    String value;
    if (kIsWeb) {
      var headers = {
        'content-type': 'application/x-www-form-urlencoded',
        //'Access-Control-Allow-Origin': '*',
        //'Access-Control-Allow-Credentials': 'true',
        //'Access-Control-Allow-Headers':
        //'Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
        //'Access-Control-Allow-Methods': 'POST, OPTIONS'
      };
      http.Response response;
      if (body != null)
        response = await http
            .post(url, headers: headers, body: body)
            .catchError((error, stackTrace) {
          _msg = error;
        });
      else
        response = await http.post(url, headers: headers).catchError((error) {
          _msg = error;
        });
      value = response.body;
    } else {
      http.Request request = new http.Request('POST', Uri.parse(url));

      request.bodyFields = body;
      //await client.send(request);
      var client = new http.Client();

      await client
          .send(request)
          .then((response) => response.stream.bytesToString().then((txt) {
                value = txt;
              }))
          .catchError((error) => _msg = error.toString());
    }
    return value;
  }

  Future<void> loadAccount({String code, String env, String guid}) async {
    var _msg = '';

    String action = 'account&code=' + code ??
        '' + '&env=' + env ??
        '' + '&guid=' + guid ??
        '';
    var url = preset.serverURL +
        preset.rootAccountId +
        '/' +
        preset.apiURL +
        '?suba=' +
        preset.accountId +
        '&mode=' +
        action;
    Map<String, String> body;
    //isLoading = true;

    if (preset.hostguid != null && preset.hostguid != '') {
      body = {'hostguid': preset.hostguid};
      //request.bodyFields = body;
    }

    String value = await getXML(url, body: body);
    var xmlDoc = xml.parse(value);
    //_msg = xmlDoc.findAllElements('message');
    //menu
    preset.curState = {};
    preset.curState['needLogin'] =
        xmlDoc.findAllElements('needLogin').single.firstChild.toString();
    preset.isLogin = (preset.curState['needLogin'] != 'True');
    preset.curState['themeFolder'] =
        xmlDoc.findAllElements('themeFolder').single.firstChild.toString();
    preset.curState['themePage'] =
        xmlDoc.findAllElements('themePage').single.firstChild.toString();
    preset.curState['signInPage'] =
        xmlDoc.findAllElements('signInPage').single.firstChild.toString();
    preset.curState['userName'] =
        xmlDoc.findAllElements('userName').single.firstChild.toString();
    preset.curState['cartID'] =
        xmlDoc.findAllElements('cartID').single.firstChild.toString();

    _msg = xmlDoc.findAllElements('hostGUID').single.firstChild.toString();
    preset.hostguid = _msg;
    //} catch (e) {}
  }
}
