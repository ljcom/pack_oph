import 'dart:async';
import 'package:flutter/widgets.dart';
//import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
//import 'package:oph_core/global.dart' as g;
import 'package:oph_core/models/oph.dart';
import 'package:oph_core/utils/http_service.dart';
import 'package:oph_core/utils/form_service.dart';
import 'package:oph_core/oph_core.dart';

//import 'dart:math';

const timeout = 30;
HttpService httpSvc = HttpService();

class BrowseService {
  String accountId;
  String name;
  String code;
  BrowseService(this.accountId, this.name, this.code);
  BrowseHead _head;
  VoidCallback _callback;
  VoidCallback _errorback;
  String _err;
  String _msg = '';
  //String _hostguid = Oph.curPreset.hostguid;
  bool isLoading = false;
  String browseError() => _msg;
  List<Menu> getMenu() => _head.menu;
  Map<String, BrowseRow> getBrowseRow() => _head == null ? [] : _head.rows;
  BrowseHead getHead() => _head;

  void setContext({VoidCallback callback, VoidCallback errorback}) {
    if (_callback != null) _callback = callback;
    if (_errorback != null) _errorback = errorback;
  }

  Future<FormService> getForm(String guid, {bool reload: false}) async {
    FormService svc;
    if (guid == '00000000-0000-0000-0000-000000000000')
      _head.newSvc.init(_head.code, guid);
    else if (_head.rows[guid] != null) {
      svc = _head.rows[guid].frmSvc;
      if (!svc.isInit) {
        svc.init(_head.code, guid);
        svc.setContext(callback: _callback, errorback: _errorback);
        await svc.loadForm();
      } else if (reload) await svc.loadForm();
    }

    return svc;
  }

  Future<bool> verifyHost() async {
    var _msg = '';
    String action = '';
    if (Oph.curPreset.hostguid != '' && Oph.curPreset.hostguid != null) {
      action = 'verifyhost' + '&guid=' + Oph.curPreset.hostguid;
    }
    var url = Oph.curPreset.serverURL +
        Oph.curPreset.rootAccountId +
        '/' +
        Oph.curPreset.apiURL +
        '?suba=' +
        Oph.curPreset.accountId +
        '&mode=' +
        action;
    isLoading = true;
    String value = await httpSvc.getXML(url);
    XmlDocument xmlDoc = XmlDocument.parse(value);
    //menu
    _msg = xmlDoc.findAllElements('message').single.firstChild.toString();

    return (_msg == '2');
  }

  Future<BrowseHead> getBrowse({
    String code,
    int p = 1,
    int r = 20,
    String q = '',
    String f = '',
    String o = '',
    int s = 0,
  }) async {
    BrowseHead _head = BrowseHead(code: code, rows: {});
    _msg = '';
    if (code != '') {
      var search = (q != '' && q != null)
          ? '&bsearchtext=' + q.replaceAll('+', '%2B')
          : '';
      var sqlfilter = (f != '' && f != null) ? '&sqlfilter=' + f : '';
      var sqlorder = (o != '' && o != null) ? '&sortorder=' + o : '';
      var pgno = (p > 1) ? '&bpageno=' + p.toString() : '';
      var nbrows = (r != 20) ? '&brows=' + r.toString() : '';
      var sts = (s != null && s > 0) ? '&stateid=' + s.toString() : '';

      //await httpSvc.loadAccount(code: code);
      //if (await verifyHost()) {
      //if (Oph.curPreset.hostguid != null && Oph.curPreset.hostguid != '' && Oph.curPreset.isLogin) {
      await httpSvc.loadAccount(code, hostguid: Oph.curPreset.hostguid);
      if (Oph.curPreset.hostguid != null &&
          Oph.curPreset.hostguid != '' &&
          Oph.curPreset.isLogin) {
        var url = Oph.curPreset.serverURL +
            Oph.curPreset.rootAccountId +
            '/' +
            Oph.curPreset.apiURL +
            '?suba=' +
            Oph.curPreset.accountId +
            '&mode=browse&code=' +
            code +
            pgno +
            nbrows +
            search +
            sqlfilter +
            sqlorder +
            sts;

        var body = {'hostguid': Oph.curPreset.hostguid};
        isLoading = true;
        String value = await httpSvc.getXML(url, body: body);
        isLoading = false;
        if (value != '') {
          XmlDocument xmlDoc = XmlDocument.parse(value);
          //menu
          _msg = xmlDoc.findAllElements('message').toString();
          if (_msg.indexOf('You are not authorized') > 0) {
            Oph.curPreset.isLogin = false;
          } else if (_msg != '' && _msg != null) {
            _getUser(xmlDoc);
            _head.menu = _getMenu(xmlDoc);
            _head.state = _getState(xmlDoc);
            //browse
            var l1 = xmlDoc.findAllElements("row").toList();
            for (var f in l1) {
              String docstat = f
                  .findAllElements("docStatus")
                  .toList()[0]
                  .getAttribute("title");
              var l2 = f.findAllElements("field").toList();
              var guid = f.getAttribute("GUID").toString();
              Map<String, Field> _field = {};
              for (var i in l2) {
                var title = i.getAttribute("title").toString();
                var caption = i.getAttribute("caption").toString();
                var mandatory = i.getAttribute("mandatory").toString();
                var editor = i.getAttribute("editor").toString();
                var rawval = editor == 'datepicker'
                    ? i.getAttribute("date").toString()
                    : editor == 'select2'
                        ? i.getAttribute("guid").toString()
                        : i.text.toString();
                var val = i.text.toString();
                _field[caption] = Field(
                    title: title,
                    //caption: caption,
                    mandatory: int.parse(mandatory),
                    rawVal: rawval,
                    val: val);
              }
              BrowseRow row = BrowseRow(fields: _field, docStatus: docstat);
              row.frmSvc = FormService();
              row.frmSvc.init(_head.code, guid);
              _head.rows[guid] = row;
            }
          } else {
            isLoading = false;
            _msg = 'Empty ' + url + ' ' + httpSvc.httpError.toString();
            print('empty $code $_msg');
            _errorback();
          }
          print(code + ' loaded.');
        } else {
          if (_msg == null || _msg == '')
            _msg = "Unauthorized: " + url + ' ' + Oph.curPreset.hostguid;
          print(_msg);
        }
      }
    }
    return _head;
  }

  void _getUser(XmlDocument xmlDoc) {
    var info = xmlDoc.findAllElements("info").toList();
    for (var i in info) {
      var user = i.findAllElements("user").toList();
      if (user.length > 0) {
        var userName = user[0].findAllElements("userName").toList().length > 0
            ? user[0].findAllElements("userName").toList()[0].text
            : '';
        var userurl = user[0].findAllElements("userURL").toList().length > 0
            ? user[0].findAllElements("userURL").toList()[0].text
            : '';
        Oph.curPreset.curState['userName'] = userName;
        Oph.curPreset.curState['userURL'] = userurl;
      }
    }
  }

  List<Menu> _getMenu(XmlDocument xmlDoc) {
    List<Menu> _menu = [];
    var mn = xmlDoc.findAllElements("menu").toList();
    if (mn.length > 0)
      for (var mnx in mn) {
        var smn = mnx.findAllElements("submenu").toList();
        List<Submenu> _smn = [];
        String menuName = mnx.getAttribute("code").toString();
        for (var smnx in smn) {
          String smType = smnx.getAttribute("type");
          String desc = smnx
              .findAllElements("MenuDescription")
              .toList()[0]
              .text
              .toString();
          String caption =
              smnx.findAllElements("caption").toList()[0].text.toString();
          String pageURL =
              smnx.findAllElements("pageURL").toList()[0].text.toString();
          _smn.add(Submenu(
              type: smType, desc: desc, caption: caption, pageURL: pageURL));
        }
        _menu.add(Menu(menuName: menuName, submenu: _smn));
      }
    return _menu;
  }

  List<OState> _getState(XmlDocument xmlDoc) {
    List<OState> _state = [];
    var mn = xmlDoc.findAllElements("state").toList();
    if (mn.length > 0) {
      for (var mnx in mn) {
        String stcode = mnx.getAttribute("code").toString();
        String stname = mnx.getAttribute("name").toString();
        var smn = mnx.findAllElements("substate").toList();
        List<OSubState> substate = [];
        for (var smnx in smn) {
          //List<OSubState> _smn = [];
          String code = smnx.getAttribute("code").toString();
          int tRecord =
              int.tryParse(smnx.getAttribute("tRecord").toString()) ?? 0;
          String name = smnx.text.toString();
          substate.add(OSubState(code: code, name: name, tRecord: tRecord));
        }
        _state.add(OState(code: stcode, name: stname, substate: substate));
      }
    }
    return _state;
  }

  Future<void> init(
    String name,
    String code,
    VoidCallback callback,
    VoidCallback errorback, {
    String q = '',
    String f = '',
    String o = '',
    int p = 1,
    int r = 20,
    int s = 0,
  }) async {
    bool isDone = false;
    _head = BrowseHead(code: code, rows: {});
    name = name;
    code = code;
    _callback = callback;
    _errorback = errorback;
    _head.controller = ScrollController();
    //_head.controller.removeListener(() {});
    _head.controller.addListener(_scrollListener);
    _head.newSvc.init(_head.code, '00000000-0000-0000-0000-000000000000');

    if (r == 0) r = 20;
    if (_head != null && _head.rows.length == 0) {
      isDone = await fetchData(q: q, f: f, p: p, r: r, o: o, s: s);
    }
    return isDone;
  }

  void resetScroll() {
    _head.controller = ScrollController();
    _head.controller.removeListener(() {});
    _head.controller.addListener(_scrollListener);
  }

  _scrollListener() {
    if (_head.controller.offset >=
            _head.controller.position.maxScrollExtent * .85 &&
        !_head.controller.position.outOfRange) {
      //setState(() {
      print("reach the bottom");
      fetchData(nextPage: true);
      //});
    }
    if (_head.controller.offset <= _head.controller.position.minScrollExtent &&
        !_head.controller.position.outOfRange) {
      //setState(() {
      print("reach the top");
      //});
    }
  }

  Future<bool> fetchData({
    bool nextPage = false,
    String q = '',
    String f = '',
    String o = '',
    int p = 1,
    int r = 20,
    int s = 0,
    bool isForced = false,
  }) async {
    bool isDone = false;
    if (_head != null && (!isLoading || isForced)) {
      if (!nextPage) {
        if (q != _head.curSearch ||
            f != _head.curFilter ||
            o != _head.curOrder ||
            p != _head.pg ||
            s != _head.curStatus) {
          _head.curSearch = q;
          _head.curFilter = f;
          _head.curOrder = o;
          _head.pg = p;
          _head.nbrows = r;
          _head.curStatus = s;
          //nextPage=false;
          _head.rows.clear();
        }
      } else if (nextPage)
        _head.pg++;
      else if (_head.rows.length == 0) nextPage = true;

      //if (nextPage) {
      _head.isLoaded = false;
      await getBrowse(
        code: _head.code,
        p: _head.pg,
        r: _head.nbrows,
        q: _head.curSearch,
        f: _head.curFilter,
        o: _head.curOrder,
        s: _head.curStatus,
      ).then((x) {
        if (_head != null) {
          if (!nextPage) _head.rows.clear();
          _head.rows.addAll(x.rows);
          if (x.menu != null) _head.menu = List.from(x.menu);
          _head.isLoaded = true;
          isLoading = false;
          if (_callback != null) _callback();
          isDone = true;
        }
      });
      //}

    }
    return isDone;
  }

  String error() {
    return _err;
  }

  Future<bool> function(String action, String guid) async {
    bool b = false;
    if (_head.rows[guid] != null) {
      //FormService svc = _head.rows.where((r) => r.guid == guid).toList()[0];
      FormService svc = await getForm(guid);
      await svc.function(action: action);
    }
    return b;
  }

  static String getValFromCaption(BrowseRow r, String caption) {
    return //caption == 'guid'
        //? r.guid
        caption == 'docStatus'
            ? r.docStatus
            : r.fields[caption] != null
                ? r.fields[caption].val.toString()
                : null;
  }

  void dispose() {
    _head = null;
    _callback = null;
    _errorback = null;
  }
}
