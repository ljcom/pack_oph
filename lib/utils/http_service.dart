import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../oph_core.dart';

class HttpService {
  String _msg;
  String httpError() => _msg;
  //Oph.curPreset Oph.curPreset;

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
      if (body != null) request.bodyFields = body;

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

  Future<void> loadAccount(String code,
      {String env, String guid, String hostguid}) async {
    var _msg = '';

    String action = 'account&code=' + code ??
        '' + '&env=' + env ??
        '' + '&guid=' + guid ??
        '';
    var url = Oph.curPreset.serverURL +
        Oph.curPreset.rootAccountId +
        '/' +
        Oph.curPreset.apiURL +
        '?suba=' +
        Oph.curPreset.accountId +
        '&mode=' +
        action;
    Map<String, String> body;
    //isLoading = true;

    if (hostguid != null && hostguid != '') {
      body = {'hostguid': hostguid};
      //request.bodyFields = body;

    }
    String value = '';
    if (body == null)
      value = await getXML(url);
    else
      value = await getXML(url, body: body);
    try {
      XmlDocument xmlDoc = XmlDocument.parse(value);
      //_msg = xmlDoc.findAllElements('message');
      //menu
      //Oph.curPreset.curState = {};
      Oph.curPreset.curState['needLogin'] =
          xmlDoc.findAllElements('needLogin').single.firstChild?.text;
      Oph.curPreset.isLogin = (Oph.curPreset.curState['needLogin'] != 'True');
      Oph.curPreset.curState['themeFolder'] =
          xmlDoc.findAllElements('themeFolder').single.firstChild?.text ?? '';
      Oph.curPreset.curState['themePage'] =
          xmlDoc.findAllElements('themePage').single.firstChild?.text ?? '';
      Oph.curPreset.curState['signInPage'] =
          xmlDoc.findAllElements('signInPage').single.firstChild?.text ?? '';
      //Oph.curPreset.curState['userName'] =
      //xmlDoc.findAllElements('userName').single.firstChild?.text ?? '';
      Oph.curPreset.curState['cartID'] =
          xmlDoc.findAllElements('cartID').single.firstChild?.text ?? '';

      _msg = xmlDoc.findAllElements('hostGUID').single.firstChild?.text ?? '';
      Oph.curPreset.hostguid = _msg;
      //} catch (e) {}
    } on XmlParserException catch (e) {
      print(e.message);
    }
  }
}
