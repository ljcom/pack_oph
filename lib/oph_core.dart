library pack_oph;

//import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:oph_core/models/oph.dart';
import 'package:oph_core/models/preset.dart';
import 'package:oph_core/utils/auth_service.dart';
import 'package:oph_core/utils/browse_service.dart';
//import 'package:oph_core/utils/http_service.dart';
//import 'package:pack_oph/utils/form_element.dart';
//import './global.dart' as g;

class Oph {
  static Preset _preset;
  static void init(
      //Preset preset,
      {String serverURL,
      String indexURL,
      String apiURL,
      String autosuggestURL,
      String reportURL,
      String documentURL,
      String rootAccountId,
      String apiKey,
      Color color1,
      Color color2,
      Color color3,
      Color color4,
      double imgRatio}) {
    _preset = Preset();
    //_preset = preset;
    Preset.setServer(_preset,
        serverURL: serverURL,
        indexURL: indexURL,
        apiURL: apiURL,
        autosuggestURL: autosuggestURL,
        reportURL: reportURL,
        documentURL: documentURL,
        rootAccountId: rootAccountId,
        apiKey: apiKey);
    Preset.setColor(_preset,
        color1: color1,
        color2: color2,
        color3: color3,
        color4: color4,
        imgRatio: imgRatio);

    _preset.appAuth = AuthService(_preset);
    _preset.dataList = BrowseList([]);
  }

  static Future<void> addToList(
    String name,
    String code, {
    String q = '',
    String f = '',
    String o = '',
    int p = 1,
    int r = 20,
    int s = 0,
  }) async {
    await BrowseList.add(_preset.dataList, _preset.accountId, name, code,
        q: q, f: f, o: o, p: p, r: r, s: s, preset: _preset);
  }

  static getList(String name) {
    return BrowseList.getList(_preset.accountId, name, _preset.dataList);
  }

  static setCallback(Function() callback) {
    _preset.dataList.callback = callback;
  }

  static setErrorback(Function errorback) {
    _preset.dataList.errorback = errorback;
  }

  static AuthService auth() => _preset.appAuth;
  static BrowseHead getHead(String name) =>
      getList(name) != null ? getList(name).getHead() : null;
  //static fetchData(String name) => getList(name).fetchData();
  static Preset get curPreset => _preset;
  static fetchData(
    String name, {
    bool nextPage = false,
    String q = '',
    String f = '',
    String o = '',
    int p = 1,
    int r = 20,
    int s = 0,
    bool isForced = false,
  }) =>
      getList(name) != null
          ? getList(name).fetchData(
              nextPage: nextPage,
              q: q,
              f: f,
              o: o,
              p: p,
              r: r,
              s: s,
              isForced: isForced,
            )
          : null;
  static String getValFromCaption(BrowseRow r, String caption) {
    return BrowseService.getValFromCaption(r, caption);
  }

  //static FormService() =FormService();

  //static BrowseService =BrowseService;
  //static FormEl=FormEl;
}
